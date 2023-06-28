function res = backtest(rex,Nh)
% PURPOSE: Backtesting of temporal disaggregation. 
% -----------------------------------------------------------------------
% SYNTAX: res = backtest(rex,Nh);
% -----------------------------------------------------------------------
% OUTPUT: res: a structure with...
%         rex  : reference structure
%         yh   : recursive estimations from FROM T=N+Nh T=N
%         yrev : revision as %, compared with final (full info) estimation
% -----------------------------------------------------------------------
% INPUT: rex: a structure generated by chowlin(), fernandez(), litterman()
%             or ssc()
%        Nh: 1x1 --> number of low-freq. to compute revisions
% -----------------------------------------------------------------------
% LIBRARY: chowlin, fernandez, litterman, ssc
% -----------------------------------------------------------------------
% NOTE: Revision of estimates when adding low-frequency data from T=N-Nh to
% T=N

% written by:
%  Enrique M. Quilis

% Version 2.2 [December 2018]

t0 = clock;

% ------------------------------------------------------------
% Loading the structure
Y 		= rex.Y;
x 		= rex.x(:,2:end); %Excluding intercept
ta 	    = rex.ta;
sc 	    = rex.sc;
type 	= rex.type;
opC     = rex.opC;
     
% ------------------------------------------------------------
% Data dimension
N = rex.N;     % Size of low-frequency input
n = rex.n;     % Size of high-frequency input
p = rex.p - 1; % Number of regressors (without intercept)

% ------------------------------------------------------------
% BACKTEST: REVISIONS OF ESTIMATES, AS Y EXPANDS (x all sample)
% ------------------------------------------------------------
x = x(1:sc*N,:);
yh = [];
for h=Nh:-1:0
    Yh = Y(1:end-h);
    % Calling temporal disaggregation function
    switch rex.meth
        case {'Chow-Lin'}
            rl   = rex.rl;
            res1 = chowlin(Yh,x,ta,sc,type,opC,rl);
        case {'Fernandez'}
            res1 = fernandez(Y,x,ta,sc,opC);
        case {'Litterman'}
            rl   = rex.rl;
            res1 = litterman(Yh,x,ta,sc,type,opC,rl);
        case {'Santos Silva-Cardoso'}
            rl   = rex.rl;
            res1 = ssc(Yh,x,ta,sc,type,opC,rl);
        otherwise
            error ('*** BACKTESTING IS NOT AVAILABLE FOR THIS METHOD ***');
    end
    % Generating yh
    yh = [yh res1.y];
end

% Computation of revisons as percentages
yrev = (yh - kron(ones(1,Nh+1),yh(:,end))) ./ yh;

% -----------------------------------------------------------
% Loading the structure
% -----------------------------------------------------------
% Reference structure
res.rex = rex;
% Sequence of estimates
res.yh = yh;
% Revisions of stimates
res.yrev = yrev;
% Elapsed time
res.et = etime(clock,t0);