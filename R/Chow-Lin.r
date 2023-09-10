# Function to estimate Chow-Lin model
#
# Args:
#   Y: Low-frequency time series
#   x: High-frequency time series
#   ta: Temporal aggregation frequency
#   sc: Number of observations per low-frequency period
#   type: Type of model (1: AR(1), 2: MA(1), 3: ARMA(1,1))
#   opC: Option for intercept (0: no intercept, 1: intercept)
#   rl: Range of values for rho
#
# Returns:
#   res: A list of results
#
criterion_CL <- function(Y, x, ta, type, opC, rl, X, C, N, n) {

  # -----------------------------------------------------------
  # Initial checks
  if ((rl[1] <= -1.00) | (rl[1] >= rl[2] | (rl[2] >= 1.00))) {
    stop ('*** rl has invalid values ***');
  }

  # Parameters of grid search
  r <- linspace(rl[1], rl[2], rl[3])
  nr <- length(r)

  # Auxiliary matrix useful to simplify computations
  I <- diag(n)
  w <- I
  LL <- diag(-ones(n - 1, 1), -1)
  wls <- zeros(1, nr)
  loglik <- zeros(1, nr)
  val <- zeros(1, nr)

  # -----------------------------------------------------------
  # Evaluation of the objective function in the grid
  for (h in 1:nr) {
    Aux <- I + r[h] * LL
    Aux[1, 1] <- sqrt(1 - r[h] ^ 2)
    w <- solve(Aux %*% t(Aux))
    W <- C %*% w %*% t(C)
    iW <- solve(W)
    beta <- (X %*% iW %*% X) %*% (X %*% iW %*% Y)
    U <- Y - X %*% beta
    wls[h] <- U %*% iW %*% U
    sigma_a <- wls[h] / N
    # Likelihood function
    loglik[h] = (-N / 2) * log(2 * pi * sigma_a) - (1 / 2) * log(det(W)) - (N / 2)
    # Objective function
    val[h] = (1 - type) * (-wls[h]) + type * loglik[h]
  }

  # -----------------------------------------------------------
  # Determination of optimal rho
  [valmax, hmax] <- max(val)
  rho <- r[hmax]

  # -----------------------------------------------------------
  # Loading the structure
  # -----------------------------------------------------------
  res <- list()
  res$rho <- rho
  res$val <- val
  res$wls <- wls
  res$loglik <- loglik
  res$r <- r

  return(res)
}


aggreg_v <- function(op1, sc) {
  switch(op1,
         1, c <- rep(1, sc),
         2, c <- rep(1/sc, sc),
         3, c <- numeric(sc), c[sc] <- 1,
         4, c <- numeric(sc), c[1] <- 1,
         stop("*** IMPROPER TYPE OF TEMPORAL DISAGGREGATION ***"))
  return(c)
}

aggreg <- function(op1, N, sc) {
  # Purpose: Generate a temporal aggregation matrix
  #
  # Syntax: C <- aggreg(op1, N, sc)
  #
  # Output: C: N x (sc x N) temporal aggregation matrix
  #
  # Input:
  #   op1: type of temporal aggregation
  #     op1=1 ---> sum (flow)
  #     op1=2 ---> average (index)
  #     op1=3 ---> last element (stock) ---> interpolation
  #     op1=4 ---> first element (stock) ---> interpolation
  #   N: number of low frequency data
  #   sc: number of high frequency data points
  #     for each low frequency data points (freq. conversion)
  #
  # Library: aggreg_v
  #
  # See also: temporal_agg
  #
  # Note: Use aggreg_v_X for extended interpolation

  # Written by:
  #  Enrique M. Quilis

  # Version 1.1 [December 2018]

  # Generation of aggregation matrix C=I(N) <kron> c
  c <- aggreg_v(op1, sc)

  # Temporal aggregation matrix
  C <- kronecker(diag(N), c)

  return(C)
}

chowlin_W <- function(Y, x, ta, sc, type, opC, rl) {

  # Check input arguments
  if (opC != 0 && opC != 1) {
    stop("*** opC has an invalid value ***")
  }

  # Prepare the X matrix: including an intercept if opC==1
  if (opC == 1) {
    e <- rep(1, ncol(x))
    x <- cbind(e, x)
  }

  # Generate the aggregation matrix
  C <- aggreg(ta, length(Y), sc)

  # Expand the aggregation matrix to perform
  # extrapolation if needed.
  if (nrow(x) > sc * length(Y)) {
    pred <- nrow(x) - sc * length(Y)
    C <- rbind(C, matrix(0, pred, ncol(C)))
  }

  # Temporal aggregation of the indicators
  X <- C %*% x

  # Optimization of objective function (Lik. or WLS)
nrl <- length(rl)
switch(nrl,
"0" = {
rl <- c(0.05, 0.99, 50)
rex <- criterion_CL(Y, x, ta, type, opC, rl, X, C, length(Y), nrow(x))
rho <- rex$rho
r <- rex$r
},
"1" = {
rho <- rl
type <- 4
},
"3" = {
rex <- criterion_CL(Y, x, ta, type, opC, rl, X, C, length(Y), nrow(x))
rho <- rex$rho
r <- rex$r
},
{
stop("*** Grid search on rho is improperly defined. Check rl ***")
}
)

  # -----------------------------------------------------------
# Final estimation with optimal rho
# -----------------------------------------------------------

# Auxiliary matrix useful to simplify computations
I <- diag(n)
w <- I
LL <- diag(-ones(n - 1, 1), -1)

Aux <- I + rho * LL
Aux[1, 1] <- sqrt(1 - rho ^ 2)
w <- solve(Aux %*% t(Aux))
W <- C %*% w %*% t(C)
T <- tril(w)
T[1:(n + 1):end] <- 1
Wi <- solve(W)
beta <- solve(Wi %*% X %*% Y) %*% Wi %*% X
u <- Y - X %*% beta
sigma_a <- var(u)
L <- w %*% t(C) %*% Wi
y <- L %*% u

# -----------------------------------------------------------
# Information criteria
# Note: p is expanded to include the innovational parameter
aic <- -2 * loglik + 2 * (p + 1)
bic <- -2 * loglik + 2 * (p + 1) * log(N)

# -----------------------------------------------------------
# VCV matrix of high frequency estimates
sigma_beta <- sigma_a * solve(Wi %*% X %*% X)

VCV_y1 <- sigma_a * (eye(n) - L %*% C) * w
VCV_y2 <- (x - L %*% X) * sigma_beta * (x - L %*% X) %*% t()
VCV_y <- VCV_y1 + VCV_y2

d_y <- sqrt(diag(VCV_y))
y_li <- y - d_y
y_ls <- y + d_y

# Weighted least squares
wls <- t(u) %*% Wi %*% u

# Likelihood
loglik <- -N/2 * log(2 * pi * sigma_a) - 1/2 * log(det(W)) - N/2

# Estimation K of Guerrero(1990)
K <- t(u) %*% inv(C %*% T %*% t(T) %*% C) %*% u / sigma_a

# -----------------------------------------------------------
# Loading the structure
# -----------------------------------------------------------
res <- list()
res$meth <- 'Chow-Lin'
res$ta <- ta
res$N <- N
res$n <- n
res$pred <- pred
res$sc <- sc
res$type <- type
res$p <- p
res$opC <- opC
res$rl <- rl

# -----------------------------------------------------------
# Series
res$Y <- Y
res$x <- x
res$y <- y
res$y_dt <- d_y
res$y_lo <- y_li
res$y_up <- y_ls

# -----------------------------------------------------------
# Residuals
res$u <- u
res$U <- u

# -----------------------------------------------------------
# Parameters
res$beta <- beta
res$beta_sd <- sqrt(diag(sigma_beta))
res$beta_t <- beta / sqrt(diag(sigma_beta))
res$rho <- rho
res$sigma_a <- sigma_a

# -----------------------------------------------------------
# Information criteria
res$aic <- aic
res$bic <- bic
res$K <- K

# -----------------------------------------------------------
# Objective function
if (nrl == 1) {
  res$val <- data.frame()
  res$wls <- wls
  res$loglik <- loglik
  res$r <- data.frame()
} else {
  res$val <- rex$val
  res$wls <- rex$wls
  res$loglik <- rex$loglik
  res$r <- r
}

return(res)
}
