function [y] = temporal_agg(z,op1,sc)
% PURPOSE: Temporal aggregation of a time series 
% ------------------------------------------------------------
% SYNTAX: y = temporal_agg(z,op1,sc);
% ------------------------------------------------------------
% OUTPUT: y: Nx1 temporally aggregated series
% ------------------------------------------------------------
% INPUT:  z: nx1 ---> vector of high frequency data
%         op1: type of temporal aggregation 
%         op1=1 ---> sum (flow)
%         op1=2 ---> average (index)
%         op1=3 ---> last element (stock) ---> interpolation
%         op1=4 ---> first element (stock) ---> interpolation
%         sc: number of high frequency data points 
%            for each low frequency data points
%         Note: n = sc x N
% ------------------------------------------------------------
% LIBRARY: aggreg
% ------------------------------------------------------------
% See also: copylow, ssampler.
% ------------------------------------------------------------

% written by:
%  Enrique M. Quilis

% Version 2.1 [December 2018]

% Data dimension
n = size(z,1);

% ------------------------------------------------------------
% Computes the number of low frequency points. 
% Low frequency periods should be complete
N = fix(n/sc);
C=aggreg(op1,N,sc);

% -----------------------------------------------------------
% Expanding the aggregation matrix to perform
% extrapolation if needed.
if (n > sc * N)
   pred = n - sc*N;           % Number of required extrapolations 
   C=[C zeros(N,pred)];
else
   pred = 0;
end

y=C*z;
