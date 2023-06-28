function [] = td_print(res,file_sal)
% PURPOSE: Generate output of temporal disaggregation methods
% ------------------------------------------------------------
% SYNTAX: td_print(res,file_sal);
% ------------------------------------------------------------
% OUTPUT: file_sal: an ASCII file with detailed output of
% temporal disaggregation methods (td)
% ------------------------------------------------------------
% INPUT: res: structure generated by td programs
%        file_sal: name of the ASCII file for output
% ------------------------------------------------------------
% LIBRARY: rate, aggreg
% ------------------------------------------------------------
% SEE ALSO: chowlin, fernandez, litterman, td_plot

% written by:
%  Enrique M. Quilis

% Version 1.2 [December 2011]

% -----------------------------------------------------------
% -----------------------------------------------------------
% Loading the structure

meth=res.meth;

% -----------------------------------------------------------
% Basic parameters 
N=res.N;
n=res.n;
pred=res.pred;
sc=res.sc;
p=res.p;
et=res.et;
ta=res.ta;
type=res.type;

% -----------------------------------------------------------
% Series
Y = res.Y;
x = res.x;
y    = res.y;
d_y  = res.y_dt;
y_li = res.y_lo;
y_ls = res.y_up;

% -----------------------------------------------------------
% Residuals
u = res.u;
U = res.U;

% -----------------------------------------------------------
% Parameters
beta = res.beta;
beta_sd =res.beta_sd;
beta_t =res.beta_t;
rho = res.rho;

% -----------------------------------------------------------
% Information criteria
aic=res.aic;
bic=res.bic;

% -----------------------------------------------------------
% Selection of periodicity of high frequency data
% Low-frequency (lf) and high-frequency (hf) depends on the
% problem at hand. The default options are related to sc 
% according to:
%                       sc
%  :::::::::::::::::::::::::::::::::::::::::::::::::::::::
%               3                  4                12
%  :::::::::::::::::::::::::::::::::::::::::::::::::::::::
%  lf =         4                  1                 1
%  hf =        12                  4 = sc            12 = sc
%  :::::::::::::::::::::::::::::::::::::::::::::::::::::::
%

if (sc==3)
    lf = 4;
    hf = 12;
else
    lf = 1;
    hf = sc;
end 

% -----------------------------------------------------------
% Descriptive measures (one indicator case only)

if ((p == 1) & (res.opC == 0)) | ((p == 2) & (res.opC == 1))
   % Correlation between Y and X (levels)
   x_short=x(1:sc*N,1+res.opC);
   X=aggreg(res.ta,res.N,res.sc)*x_short;
   AUX=corrcoef(res.Y,X);
   c1=AUX(1,2);
   % Correlation between Y and X (yoy rates)
   TY=rate(Y,lf); TY=TY(lf+1:N);
   TX=rate(X,lf); TX=TX(lf+1:N);
   AUX=corrcoef(TY,TX);
   c2=AUX(1,2);
   % Correlation between y and x (levels)
   AUX=corrcoef(res.y,res.x(:,1+res.opC));
   c3=AUX(1,2);
   % Correlation between y and x (yoy rates)
   ty=rate(res.y,hf);
   tx=rate(res.x(:,1+res.opC),hf);
   AUX=corrcoef(ty(hf+1:n),tx(hf+1:n));
   c4=AUX(1,2);
   c5=std(ty(hf+1:n),1);
   c6=std(tx(hf+1:n),1);
end
% Correlation between y and x*beta 
xb=x*beta;
% ... levels
AUX=corrcoef(res.y,xb);
c7=AUX(1,2);
% ... yoy rates
ty=rate(res.y,hf);
txb=rate(xb,hf);
AUX=corrcoef(ty(hf+1:n),txb(hf+1:n));
c8=AUX(1,2);

% -----------------------------------------------------------
% Output on ASCII file

sep1='****************************************************';
sep ='----------------------------------------------------';

if (nargin == 1)
   fid = 1;
else 
   fid=fopen(file_sal,'w');
end

fprintf(fid,'\n ');
fprintf(fid,'%s \n',sep1);
fprintf(fid,' TEMPORAL DISAGGREGATION METHOD: %s \n ',meth);
fprintf(fid,'%s \n',sep1);
fprintf(fid,'\n ');
fprintf(fid,'%s\n',sep);
fprintf(fid,' Number of low-frequency observations : %4d\n ',N );
fprintf(fid,'Frequency conversion                 : %4d\n ',sc );
fprintf(fid,'Number of high-frequency observations: %4d\n ',n );
fprintf(fid,'Number of extrapolations             : %4d\n ',pred );
fprintf(fid,'Number of indicators                 : %4d\n ',p );
fprintf(fid,'%s \n',sep);
fprintf(fid,' Type of disaggregation: ');
switch ta
case 1
   fprintf(fid,'sum (flow). \n');
case 2
   fprintf(fid,'average (index). \n');
   case 3
   fprintf(fid,'interpolation (stock last). \n');
case 4
   fprintf(fid,'interpolation (stock first). \n');
end %of switch ta
fprintf(fid,'%s \n',sep);
fprintf(fid,' Estimation method: ');
switch type
case 0
   fprintf(fid,'Weighted least squares. \n');
case 1
   fprintf(fid,'Maximum likelihood. \n');
case 2
    fprintf(fid,'BLUE. \n');
case 3
    fprintf(fid,'Cochrane-Orcutt. \n');
case 4
    fprintf(fid,'GLS + Fixed innovational parameter. \n');
end %of switch ml
fprintf(fid,'%s\n',sep);
fprintf(fid,' ** High frequency model ** \n ');
beta_tot = [beta beta_sd beta_t];
fprintf(fid,' Beta parameters (columnwise): \n ');
fprintf(fid,'  * Estimate \n ');
fprintf(fid,'  * Std. deviation \n ');
fprintf(fid,'  * t-ratios \n ');
fprintf(fid,'%s \n',sep);
fprintf(fid,'%10.4f      %10.4f      %10.4f\n ',beta_tot' );
fprintf(fid,'%s \n',sep);
switch res.meth
    case {'Santos Silva-Cardoso'}
        fprintf(fid,' Dynamic parameter: %8.4f\n ',rho );
        beta_lr = beta./(1-rho);
        fprintf(fid,'%s\n',sep);
        fprintf(fid,' Long-run beta parameters (columnwise):\n ');
        fprintf(fid,'%10.4f \n ',beta_lr' );
        fprintf(fid,'%s\n',sep);
        trunc = [res.gamma(end) res.gamma_sd(end) res.gamma_t(end)];
        fprintf(fid,' Truncation remainder: expected y(0):\n ');
        fprintf(fid,'  * Estimate \n ');
        fprintf(fid,'  * Std. deviation \n ');
        fprintf(fid,'  * t-ratios \n ');
        fprintf(fid,'%s\n',sep);
        fprintf(fid,'%10.4f      %10.4f      %10.4f\n ',trunc' );
    case {'Proietti'}
        fprintf(fid,' Dynamic parameter: %8.4f\n ',rho );
        beta_lr = (beta(end-1)+beta(end)) /(1-rho);
        fprintf(fid,'%s\n',sep);
        fprintf(fid,' Long-run gain: ');
        fprintf(fid,'%10.4f \n ',beta_lr' );
        fprintf(fid,'%s\n',sep);
        trunc = [res.gamma(end) res.gamma_sd(end) res.gamma_t(end)];
        fprintf(fid,' Truncation remainder: expected y(0):\n ');
        fprintf(fid,'  * Estimate \n ');
        fprintf(fid,'  * Std. deviation \n ');
        fprintf(fid,'  * t-ratios \n ');
        fprintf(fid,'%s\n',sep);
        fprintf(fid,'%10.4f      %10.4f      %10.4f\n ',trunc' );
    case {'Chow-Lin','Litterman','Santos Silva-Cardoso','Proietti'}
        fprintf(fid,' Innovational parameter: %8.4f\n ',rho );
end
fprintf(fid,'%s \n',sep);
% Descriptive measures (one indicator case only)
if ((p == 1) & (res.opC == 0)) | ((p == 2) & (res.opC == 1))
    fprintf(fid,' AIC: %8.4f\n ',aic);
    fprintf(fid,'BIC: %8.4f\n ',bic);
    fprintf(fid,'%s \n',sep);
    fprintf(fid,'Low-frequency correlation (Y,X) \n ');
    fprintf(fid,' - levels     : %6.4f\n ',c1 );
    fprintf(fid,' - yoy rates  : %6.4f\n ',c2 );
    fprintf(fid,'%s\n',sep);
    fprintf(fid,'High-frequency correlation (y,x) \n ');
    fprintf(fid,' - levels     : %6.4f\n ',c3 );
    fprintf(fid,' - yoy rates  : %6.4f\n ',c4 );
    fprintf(fid,'%s\n',sep);
    fprintf(fid,'High-frequency volatility of yoy rates \n ');
    fprintf(fid,' - estimate   : %6.4f\n ',c5 );
    fprintf(fid,' - indicator  : %6.4f\n ',c6 );
    fprintf(fid,' - ratio      : %6.4f\n ',(c5/c6) );
    fprintf(fid,'%s\n',sep);
end
fprintf(fid,'High-frequency correlation (y,x*beta) \n ');
    fprintf(fid,' - levels     : %6.4f\n ',c7 );
    fprintf(fid,' - yoy rates  : %6.4f\n ',c8 );
    fprintf(fid,'%s\n',sep);
fprintf(fid,'\n ');
fprintf(fid,'Elapsed time: %8.4f\n ',et);

if (nargin == 1)
   % Do nothing
else 
   fclose(fid);
end

