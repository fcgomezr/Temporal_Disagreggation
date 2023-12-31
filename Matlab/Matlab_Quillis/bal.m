function yb = bal(y,z)
% PURPOSE: Proportional adjustment of y to a given total z
% -----------------------------------------------------------------------------
% SYNTAX: yb = bal(y,z);
% -----------------------------------------------------------------------------
% OUTPUT: yb : nxM  --> balanced time series
% -----------------------------------------------------------------------
% INPUT: y: nxM  --> unbalanced time series
%        z: nx1 --> transversal constraint
% -----------------------------------------------------------------------
% LIBRARY: vec, desvec
% -----------------------------------------------------------------------
% SEE ALSO: ras, vanderploeg
% -----------------------------------------------------------------------
% REFERENCE: di Fonzo, T. (1994) "Temporal disaggregation of a system of 
% time series when the aggregate is known: optimal vs. adjustment methods",
% INSEE-Eurostat Workshop on Quarterly National Accounts, Paris, December.

% written by:
%  Enrique M. Quilis

% Version 1.2 [December 2018]

%--------------------------------------------------------
%       Preliminary checking

[n, m] = size(y);
[nz, mz] = size(z);

if ((n ~=  nz) |  (mz ~=  1) )
   error (' *** INCORRECT DIMENSIONS *** ');
else
    M = m;
    clear m nz mz;
end

%--------------------------------------------------------
%  **** CONSTRAINT MATRICES ***
%--------------------------------------------------------
% Required:
%              H1 ---> transversal aggregator
%
%---------------------------------------------------------------
%       Generate H1: n x nM
H1 = kron(ones(1,M),eye(n));

%---------------------------------------------------------------
%       Generate discrepancies disc: n x 1
disc = z - H1 * vec(y);

%---------------------------------------------------------------
%       Generate weights matrix w: nxM
w = y ./ kron(ones(1,M),(sum(y')'));

%---------------------------------------------------------------
%       Generate balanced series in stacked form
aux = vec(y) +  vec(w) .* vec(kron(ones(1,M),disc));

%---------------------------------------------------------------
%       Unstack balanced series
yb = desvec(aux,M); clear aux;
