% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/evaluateRisk.R
\name{evaluateRisk}
\alias{evaluateRisk}
\title{evaluateRisk}
\usage{
evaluateRisk(A0, A1, L2, Q2n, Q1n, g1n, g0n, abar, tolg)
}
\arguments{
\item{A0}{A \code{vector} treatment delivered at baseline.}

\item{A1}{A \code{vector} treatment deliver after \code{L1} is measured.}

\item{L2}{A \code{vector} outcome of interest.}

\item{Q2n}{A \code{vector} of estimates of Q_{2,0}}

\item{Q1n}{A \code{vector} of estimates of Q_{1,0}}

\item{g1n}{A \code{vector} of estimates of g_{1,0}}

\item{g0n}{A \code{vector} of estimates of g_{0,0}}

\item{abar}{A \code{vector} of length 2 indicating the treatment assignment 
that is of interest.}
}
\value{
A \code{numeric} value for the empirical risk
}
\description{
Function that returns empirical risk
}
