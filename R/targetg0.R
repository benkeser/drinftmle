#' targetg0
#' 
#' Function that targets g0n.
#' 
#' @param A0 A \code{vector} treatment delivered at baseline.
#' @param A1 A \code{vector} treatment deliver after \code{L1} is measured.
#' @param L2 A \code{vector} outcome of interest. 
#' @param Qn A \code{list} of current estimates of Q2n and Q1n
#' @param gn A \code{list} of current estimates of g1n and g0n
#' @param Qnr.gnr A \code{list} of current estimates of reduced dim. regressions
#' @param abar A \code{vector} of length 2 indicating the treatment assignment 
#' that is of interest. 
#' @param tolg A \code{numeric} indicating the truncation level for conditional treatment probabilities. 
#' @param tolQ A \code{numeric}
#' @param method A character either "covariate" or "weight"
#' @param return.models  A \code{boolean} indicating whether the fluctuation model should be 
#' returned with the output.  
#' @importFrom SuperLearner trimLogit
#' 
#' @return A list with named entries corresponding to the estimators of the 
#' fluctuated nuisance parameters evaluated at the observed data values. If 
#' \code{return.models = TRUE} output also includes the fitted fluctuation model. 

targetg0 <- function(
    A0, A1, L2, Qn, gn, Qnr.gnr, 
    abar, tolg, tolQ, return.models,tol.coef=1e1, method = "scaled",...
){
    #-------------------------------------------
    # making outcomes for logistic fluctuation
    #-------------------------------------------
    # length of output
    n <- length(gn$g0n)
    
    #-------------------------------------------
    # making covariates for fluctuation
    #-------------------------------------------
    # the "clever covariates" for g0n
    flucCov1 <- c(
        (Qnr.gnr$Qnr$Q1nr1 + Qnr.gnr$Qnr$Q1nr2) / gn$g0n^2
    )
    #-------------------------------------------
    # making covariates for prediction
    #-------------------------------------------
    # getting the values of the clever covariates evaluated at 
    # \bar{A} = abar. 
    # no need to change this one as it's not a function of A
    predCov1 <- flucCov1 
    
    #-------------------------------------------
    # fitting fluctuation submodel
    #-------------------------------------------
    if(method != "scaled"){
        #-------------------------------------------
        # making offsets for unscaled fluctuation
        #-------------------------------------------
        flucOff <- c(
            SuperLearner::trimLogit(gn$g0n, trim = tolg)
        )
        
        flucmod <- suppressWarnings(glm(
            formula = "out ~ -1 + offset(fo) + fc1",
            data = data.frame(out = as.numeric(A0==abar[1]), fo = flucOff, 
                              fc1 = flucCov1),
            family = binomial(), start = 0
        ))

        if(abs(flucmod$coefficients) < tol.coef){
            # get predictions 
            g0nstar <- predict(
                flucmod, 
                newdata = data.frame(out = 0, fo = flucOff,
                                     fc1 = predCov1),
                type = "response"
            )
        }else{
            g0nstar <- g0n
        }
    }else{
        #-------------------------------------------
        # making offsets for scaled fluctuation
        #-------------------------------------------
        flucOff <- c(
            SuperLearner::trimLogit((gn$g0n - tolg)/(1 - 2*tolg))
        )

        # use optim to perform minimization along submodel
        # to ensure fluctuated estimates in (tolg, 1 - tolg)
        flucmod <- optim(
            par = 0, fn = offnegloglik, gr = gradient.offnegloglik,
            method = "L-BFGS-B", lower = -tol.coef, upper = tol.coef,
            control = list(maxit = 10000),
            Y = (as.numeric(A0==abar[1]) - tolg)/(1 - 2*tolg), 
            offset = flucOff, weight = flucCov1
        )
        epsilon <- flucmod$par
        # rescale predictions 
        g0nstar <- plogis(flucOff +  epsilon * flucCov1)*(1 - 2*tolg) + tolg
    }    
 
    #--------------
    # output 
    #-------------
    out <- list(
        g0nstar = g0nstar,
        flucmod = NULL
    )
    if(return.models){
        out$flucmod = list(flucmod)
    }
    return(out)
}