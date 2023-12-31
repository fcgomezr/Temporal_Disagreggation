function res = chowlin_W(Y,x,ta,sc,type,opC,rl)
% PURPOSE: Temporal disaggregation using the Chow-Lin method
%          without pretesting for intercept
% ------------------------------------------------------------
% SYNTAX: res = chowlin_W(Y,x,ta,sc,type,opC,rl);
% ------------------------------------------------------------
% OUTPUT: res: a structure
%           res.meth    ='Chow-Lin';
%           res.ta      = type of disaggregation
%           res.type    = method of estimation
%           res.opC     = option related to intercept
%           res.N       = nobs. of low frequency data
%           res.n       = nobs. of high-frequency data
%           res.pred    = number of extrapolations
%           res.sc      = frequency conversion between low and high freq.
%           res.p       = number of regressors (including intercept)
%           res.Y       = low frequency data
%           res.x       = high frequency indicators
%           res.y       = high frequency estimate
%           res.y_dt    = high frequency estimate: standard deviation
%           res.y_lo    = high frequency estimate: sd - sigma
%           res.y_up    = high frequency estimate: sd + sigma
%           res.u       = high frequency residuals
%           res.U       = low frequency residuals
%           res.beta    = estimated model parameters
%           res.beta_sd = estimated model parameters: standard deviation
%           res.beta_t  = estimated model parameters: t ratios
%           res.rho     = innovational parameter
%           res.sigma_a = variance of shocks
%           res.aic     = Information criterion: AIC
%           res.bic     = Information criterion: BIC
%           res.val     = Objective function used by the estimation method
%           res.wls     = Weighted least squares as a function of rho
%           res.loglik  = Log likelihood as a function of rho
%           res.r       = grid of innovational parameters used by the estimation method
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
%        type: estimation method: 
%            type=0 ---> weighted least squares 	
%            type=1 ---> maximum likelihood
%        opC: 1x1 option related to intercept
%            opc = 0 : no intercept in hf model
%            opc = 1 : intercept in hf model
%        rl: innovational parameter
%            rl = []: 0x0 ---> rl=[0.05 0.99], 50 points grid
%            rl: 1x1 ---> fixed value of rho parameter
%            rl: 1x3 ---> [r_min r_max n_grid] search is performed
%                on this range, using a n_grid points grid
% ------------------------------------------------------------
% LIBRARY: aggreg, criterion_CL
% ------------------------------------------------------------
% SEE ALSO: litterman, fernandez, td_plot, td_print, chowlin_co
% ------------------------------------------------------------
% REFERENCE: Chow, G. and Lin, A.L. (1971) "Best linear unbiased 
% distribution and extrapolation of economic time series by related 
% series", Review of Economic and Statistics, vol. 53, n. 4, p. 372-375.
% Bournay, J. and Laroque, G. (1979) "Reflexions sur la methode 
% d'elaboration des comptes trimestriels", Annales de l'INSEE, n. 36, p. 3-30.

% ------------------------------------------------------------
% written by:
%  Enrique M. Quilis

% Version 3.4 [December 2018]

t0 = clock;

% ------------------------------------------------------------
% Data dimension
N = size(Y,1);    % Size of low-frequency input
[n,p] = size(x);    % Size of p high-frequency inputs (without intercept)

% ------------------------------------------------------------
% Initial checks
if ((opC ~= 0) && (opC ~= 1))
      error ('*** opC has an invalid value ***');
end

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
   pred = n - sc*N;           % Number of required extrapolations 
   C = [C zeros(N,pred)];
else
   pred = 0;
end

% -----------------------------------------------------------
% Temporal aggregation of the indicators
X = C*x;

% -----------------------------------------------------------
% Optimization of objective funcion (Lik. or WLS)
nrl = length(rl);
switch nrl
    case 0 
        rl = [0.05 0.99 50];
        rex = criterion_CL(Y,x,ta,type,opC,rl,X,C,N,n);
        rho = rex.rho;
        r   = rex.r;
    case 1 %Fixed innovational parameter
        rho = rl;
        type = 4;
    case 3
        rex = criterion_CL(Y,x,ta,type,opC,rl,X,C,N,n);
        rho = rex.rho;
        r   = rex.r;
    otherwise
        error('*** Grid search on rho is improperly defined. Check rl ***');
end

% -----------------------------------------------------------
% Final estimation with optimal rho
% -----------------------------------------------------------

% Auxiliary matrix useful to simplify computations
I = eye(n); w = I;
LL = diag(-ones(n-1,1),-1);

Aux 		= I + rho*LL;
Aux(1,1)    = sqrt(1-rho^2);
w 			= inv(Aux'*Aux);        % High frequency VCV matrix (without sigma_a)
w_1         = w * (1-rho^2);
W 			= C*w*C';               % Low frequency VCV matrix (without sigma_a)
T           = tril(w);              % Tmatriz triangular
T(1:n+1:end) = 1;
Wi 		    = inv(W);
beta 		= (X'*Wi*X)\(X'*Wi*Y);  % beta estimator
U 			= Y - X*beta;           % Low frequency residuals
wls 		= U'*Wi*U;              % Weighted least squares
sigma_a 	= wls/(N-p);         	% sigma_a estimator
L 			= w*C'*Wi;              % Filtering matrix
u 			= L*U;            

% -----------------------------------------------------------
% Temporally disaggregated time series
y = x*beta + u;

% -----------------------------------------------------------
% Information criteria
% Note: p is expanded to include the innovational parameter
aic = log(sigma_a) + 2*(p+1)/N;
bic = log(sigma_a) + log(N)*(p+1)/N;

% -----------------------------------------------------------
% VCV matrix of high frequency estimates
sigma_beta = sigma_a*inv(X'*Wi*X);

VCV_y1 =  sigma_a*(eye(n)-L*C)*w;
VCV_y2 = (x-L*X)*sigma_beta*(x-L*X)';  %If beta is fixed, this should be zero
VCV_y = VCV_y1 + VCV_y2;

d_y = sqrt((diag(VCV_y)));   % Std. dev. of high frequency estimates
y_li = y - d_y;           % Lower lim. of high frequency estimates
y_ls = y + d_y;           % Upper lim. of high frequency estimates

% Weighted least squares
wls = U' * Wi * U;                 % Weighted least squares

% Likelihood
loglik 	=(-N/2)*log(2*pi*sigma_a) - (1/2)*log(det(W)) - (N/2);
% Estimation K of Guerro(1990)
%K = (Y - C*x*beta)'* Wi *(Y - C*x*beta) /sigma_a  ;
%K =U'*inv(C*T*T'*C')*U /sigma_a  ;
%gfms = N -opC-1;
%p1 =1 - chi2cdf(K,gfms);
K =U'*inv(C*T*T'*C')*U   ;
% -----------------------------------------------------------
% Loading the structure
% -----------------------------------------------------------
res.meth='Chow-Lin';
% -----------------------------------------------------------
% Basic parameters 
res.ta        = ta;
res.N         = N;
res.n         = n;
res.pred      = pred;
res.sc        = sc;
res.type      = type;
res.p         = p;
res.opC       = opC;
res.rl        = rl;

res.w         = w;
res.W         = W;
res.Wi        = Wi;
res.w_ar        = w_1;


% -----------------------------------------------------------
% Series
res.Y         = Y;
res.x         = x;
res.y         = y;
res.y_dt      = d_y;
res.y_lo      = y_li;
res.y_up      = y_ls;
% -----------------------------------------------------------
% Residuals
res.u         = u;
res.U         = U;
% -----------------------------------------------------------
% Parameters
res.beta      = beta;
res.beta_sd   = sqrt(diag(sigma_beta));
res.beta_t    = beta./sqrt(diag(sigma_beta));
res.rho       = rho;
res.sigma_a   = sigma_a;
res.p         = round(1-tcdf(res.beta_t,n-1),3);
% -----------------------------------------------------------
% Information criteria
res.aic       = aic;
res.bic       = bic;
res.K         = K;
%res.gf        = gfms;
%res.p1        = p1;  
% -----------------------------------------------------------
% Objective function
if (nrl == 1)
   res.val       = [];
   res.wls  	 = wls;
   res.loglik 	 = loglik;
   res.r         = [];
else 
   res.val       = rex.val;
   res.wls  	 = rex.wls;
   res.loglik    = rex.loglik;
   res.r         = r;
end
% -----------------------------------------------------------
% Elapsed time
res.et        = etime(clock,t0);

