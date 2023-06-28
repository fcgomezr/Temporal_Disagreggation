function [] = tduni_print(res,file_sal)
% PURPOSE: Save output of BFL or Denton temporal disaggregation methods
% ------------------------------------------------------------
% SYNTAX: tduni_print(res,file_sal);
% ------------------------------------------------------------
% OUTPUT: file with detailed output of BFL 
% or Denton (uniequational) temporal disaggregation methods
% ------------------------------------------------------------
% INPUT: res: structure generated by bfl or denton_uni programs
%        file_sal: name of ASCII file for output
% ------------------------------------------------------------
% LIBRARY: 
% ------------------------------------------------------------
% SEE ALSO: bfl, denton_uni, tduni_plot

% written by:
%  Enrique M. Quilis

% Version 1.3 [December 2018]

sep ='----------------------------------------------------';
sep1='****************************************************';

if (nargin == 1)
   fid = 1;
else 
   fid=fopen(file_sal,'w');
end

fprintf(fid,'\n ');
fprintf(fid,'%s \n',sep1);
fprintf(fid,' TEMPORAL DISAGGREGATION METHOD: %s \n ',res.meth);
switch res.meth
    case {'Denton'}
        fprintf(fid,' Type: %s \n ',res.meth1);
    otherwise
end
fprintf(fid,'%s \n',sep1);
fprintf(fid,' Number of low-frequency observations  : %4d\n ',res.N );
fprintf(fid,'Frequency conversion                  : %4d\n ',res.sc );
fprintf(fid,'Number of high-frequency observations : %4d\n ',res.N * res.sc );
switch res.meth
case {'Boot-Feibes-Lisman','Stram-Wei'}
   % No extrapolations
case {'Denton'}
   fprintf(fid,'Number of extrapolations              : %4d\n ',res.pred );   
end
fprintf(fid,'%s\n',sep);
fprintf(fid,' Degree of differencing                : %4d\n ',res.d );
fprintf(fid,' Type of disaggregation: ');
switch res.ta
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
fprintf(fid,'\n ');
fprintf(fid,'Elapsed time: %8.4f\n ',res.et);
fprintf(fid,'%s \n',sep);

if (nargin == 1)
   % Do nothing
else 
   fclose(fid);
end

