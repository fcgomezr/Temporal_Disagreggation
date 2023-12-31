% PURPOSE: demo of sw()
%         Temporal disaggregation using the Stram-Wei method
%---------------------------------------------------
% USAGE: sw_d
%---------------------------------------------------
close all; clear all; clc;
% Low-frequency data: Spain's Exports of Goods. 1995 prices
Y =[ 20499
     23477
     25058
     27708
     31584
     31898
     30233
     32235
     34049
     36035
     39795
     44299
     47426
     52339
     62949
     69885
     77174
     90133
     96496
    102776
    113026
    115573 ];

% ---------------------------------------------
% Inputs for td library
% Type of aggregation
ta = 1;
% Minimizing the volatility of d-differenced series
d = 2;
% Frequency conversion
sc = 4;
% Number of observations of low-frequency input
N = length(Y);
% Number of observations of high-frequency output
n = sc*N;
% Defining the VCV matrix of stationary high-frequency time series
% Assumption of the example: IMA(d,2). For a comprehensive and more general analysis
% please consult Stram and Wei (1986)"Temporal aggregation in the ARIMA process",
% Journal of Time Series Analysis, vol. 7, núm. 4, p. 279-292.
% MA parameters
th1 =  0.9552;
th2 = -0.0015;
va = 0.87242 * ((223.5965)^2);
% ACF values
acf0 = va * (1+th1^2+th2^2);
acf1 = -va * th1 * (1-th2);
acf2 = -va * th2;
% Auxiliary vectors
a0(1:n-d) = acf0;
a1(1:n-d-1) = acf1;
a2(1:n-d-2) = acf2;
% High-frequency VCV matrix
v = 0.5*diag(a0) + diag(a1,-1) + diag(a2,-2);
v = v + tril(v)';
% Calling the function: output is loaded in a structure called res
res = sw(Y,ta,d,sc,v);
% ---------------------------------------------
% Outputs
% Printed output
file_sal = 'sw.out';
tdprint(res,file_sal);
edit sw.out;
% Graphics
tdplot(res);
