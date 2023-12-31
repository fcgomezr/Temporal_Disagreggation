function res = guerrero_W(Y,x,ta,sc,rexw,rexd,opC)
% PURPOSE: ARIMA-based temporal disaggregation: Guerrero method
%          without pretesting for intercept
% ------------------------------------------------------------
% SYNTAX: res = guerrero_W(Y,x,ta,sc,rexw,rexd,opC);
% ------------------------------------------------------------
% OUTPUT: res: a structure
%         res.meth     ='Guerrero';
%         res.ta       = type of disaggregation
%         res.opC     = option related to intercept
%         res.N        = nobs. of low frequency data
%         res.n        = nobs. of high-frequency data
%         res.pred     = number of extrapolations
%         res.sc        = frequency conversion between low and high freq.
%         res.p        = number of regressors (+ intercept)
%         res.Y        = low frequency data
%         res.x        = high frequency indicators
%         res.w        = scaled indicator (preliminary hf estimate)
%         res.y1       = first stage high frequency estimate
%         res.y        = final high frequency estimate
%         res.y_dt     = high frequency estimate: standard deviation
%         res.y_lo     = high frequency estimate: sd - sigma
%         res.y_up     = high frequency estimate: sd + sigma
%         res.delta    = high frequency discrepancy (y1-w)
%         res.u        = high frequency residuals (y-w)
%         res.U        = low frequency residuals (Cu)
%         res.beta     = estimated parameters for scaling x
%         res.k        = statistic to test compatibility
%         res.et       = elapsed time
% ------------------------------------------------------------
% INPUT: Y: Nx1 ---> vector of low frequency data
%        x: nxp ---> matrix of high frequency indicators (without intercept)
%        ta: type of disaggregation
%            ta=1 ---> sum (flow)
%            ta=2 ---> average (index)
%            ta=3 ---> last element (stock) ---> interpolation
%            ta=4 ---> first element (stock) ---> interpolation
%        sc: number of high frequency data points for each low frequency data points
%            Some examples:
%            sc= 4 ---> annual to quarterly
%            sc=12 ---> annual to monthly
%            sc= 3 ---> quarterly to monthly
%        rexw, rexd ---> a structure containing the parameters of ARIMA model
%            for indicator and discrepancy, respectively (see calT function)
% ------------------------------------------------------------
% LIBRARY: aggreg, calT, numpar, ols_regress
% ------------------------------------------------------------
% SEE ALSO: chowlin, litterman, fernandez, td_print, td_plot
% ------------------------------------------------------------
% REFERENCE: Guerrero, V. (1990) "Temporal disaggregation of time
% series: an ARIMA-based approach", International Statistical
% Review, vol. 58, p. 29-46.

% written by:
%  Enrique M. Quilis

% Version 2.0 [December 2018]

t0=clock;

% ------------------------------------------------------------
% Receiving inputs
% ------------------------------------------------------------
[N,M] = size(Y);    % Size of low-frequency input
[n,p] = size(x);    % Size of m high-frequency inputs (without intercept)

if (M > 1) | (sc <= 1) | (n < sc*N)
   error ('*** INADEQUATE DIMENSIONS OF INPUTS ***');
else
   clear M;
end

% Number of parameters in ARIMA model for w
rw = numpar(rexw);

% Number of parameters in ARIMA model for discrepancy
rd = numpar(rexd);

% ------------------------------------------------------------
% w: Scaling of indicators
% ------------------------------------------------------------
% Preparing the X matrix: including an intercept if opC==1
if (opC == 1)
   e=ones(n,1);   
   x=[e x];       % Expanding the regressor matrix
   p=p+1;         % Number of p high-frequency inputs (plus intercept)
end

% ------------------------------------------------------------
% Generating the aggregation matrix
C = aggreg(ta,N,sc);

% -----------------------------------------------------------
% Expanding the aggregation matrix to perform
% extrapolation if needed.
if (n > sc * N)
   pred=n-sc*N;           % Number of required extrapolations
   C=[C zeros(N,pred)];
else
   pred=0;
end

% -----------------------------------------------------------
% Temporal aggregation of the indicators
X=C*x;

% -----------------------------------------------------------
% Derivation of intermediate high-freq. series: w
% w (scaled indicator) is derived by means of OLS applied
% to the low-freq. data Y and X=Cx
% 
resbeta = ols_regress(Y,X);
beta = resbeta.beta;
beta_sd = resbeta.beta_se;
beta_t = resbeta.beta_t;

% Scaled indicator
w = x * beta;

% ------------------------------------------------------------
% T: Computing T matrix from phi-weights of ARIMA model of
%    w. Information contained in structure rexw
% ------------------------------------------------------------
T = calT(rexw,sc,n);

% -----------------------------------------------------------
% k: Testing the compatibility of Y and W=Cw.
% See Guerrero (1990), p. 38-39.
% Under null of compatibility k ---> chi-square with N-p df
% ------------------------------------------------------------
k = (Y-C*w)'*inv(C*T*T'*C')*(Y-C*w) / rexw.sigma;

% ------------------------------------------------------------
% y1: Preliminary estimation (assuming P=I)
% ------------------------------------------------------------
A1 = (T*T'*C') / (C*T*T'*C');
y1 = w + A1 * (Y - C*w);

% ------------------------------------------------------------
% b: Innovations of the preliminary discrepancy. This series
%    are the basis for testing P=I by means of testing
%    H0: b = white noise
% ------------------------------------------------------------
b = T \ (y1 - w);

% ------------------------------------------------------------
% P: Computing P matrix from phi-weights of ARIMA model of
%    y1-w. Information contained in structure rexd
% ------------------------------------------------------------
Th = calT(rexd,sc,n);

if ((rd+rexd.d+rexd.bd) == 0)  % Discrepancy is white noise
   P=eye(n);
else
   P = inv(T) * Th * Th' * inv(T');   % Note: Th*Th'=T*P*T'
end

% ------------------------------------------------------------
% y: Final estimation (including P)
% ------------------------------------------------------------
A = (T*P*T'*C') / (C*T*P*T'*C');
y = w + A * (Y - C*w);

% -----------------------------------------------------------
% Computing sigma: 1x1
u = y - w;
sigma = (u' * inv(T*P*T') * u) / (n-rd);

% -----------------------------------------------------------
% VCV matrix of high frequency estimates
VCV_y = sigma * (eye(n) - A*C) * (T*P*T');

d_y=sqrt(diag(VCV_y));     % Std. dev. of high frequency estimates
y_li=y-d_y;                % Lower lim. of high frequency estimates
y_ls=y+d_y;                % Upper lim. of high frequency estimates

% -----------------------------------------------------------
% Information criteria
aic=log(sigma)+2*p/N;
bic=log(sigma)+log(N)*p/N;

% -----------------------------------------------------------
% Loading the structure
% -----------------------------------------------------------
res.meth='Guerrero';
% -----------------------------------------------------------
% Basic parameters
res.ta        = ta;
res.type      = 2;       % BLUE
res.N         = N;
res.n         = n;
res.pred      = pred;
res.sc        = sc;
res.p         = p;
res.opC       = opC;
% -----------------------------------------------------------
% Series
res.Y         = Y;
res.x         = x;
res.w         = w;
res.y1        = y1;
res.y         = y;
res.y_dt      = d_y;
res.y_lo      = y_li;
res.y_up      = y_ls;
% -----------------------------------------------------------
% ARIMA models
res.rexw = rexw;   % Scaled indicator
res.rexd = rexd;   % Discrepancy
% -----------------------------------------------------------
% Discrepancy & residuals
res.delta     = y1-w;
res.u         = u;
res.U         = C*u;
% -----------------------------------------------------------
% Parameters
res.beta      = beta;
res.beta_sd   = beta_sd;
res.beta_t    = beta_t;
res.rho       = 1.00;
res.T         = T;
% -----------------------------------------------------------
% Information criteria
res.aic    = aic;  % For output convenience
res.bic    = bic;  % For output convenience
res.k      = k;    % Test of compatibility statistic
% -----------------------------------------------------------
% Elapsed time
res.et        = etime(clock,t0);
