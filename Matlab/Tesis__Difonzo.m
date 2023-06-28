format long g
Y_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Anuales Publicadas','B2:T18'),0);
x_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Originales','C4:U72'));
z_1     = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Publicadas','W2:W62'),0);
Y = Y_mul(1:14,1:13);  
% Series de alta frecuencia 
x = x_mul(1:56,1:13);
z = z_1(1:56,:);

ta = 2;
% Frequency conversion 
sc = 4;    
% Type of univariate disaggregation procedure
opMethod = 3;
% Type of univariate disaggregation procedure: estimation method
type = 1;
% Number of high frequency indicators linked to each low frequency
% aggregate
f = ones(1,size(x,2));
% Multivariate temporal disaggregation
res = difonzo(Y,x,z,ta,sc,type,f);
% Printed output
% Printed output
file_out = 'difonzo.out';   
tdprint(res,file_out);
edit difonzo.out;
% Graphs
tdplot(res);


%% Demanda


z_1     = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Publicadas','Z2:Z62'),0);
Y = Y_mul(1:14,14:19);  
% Series de alta frecuencia 
x = x_mul(1:56,14:19);
z = z_1(1:56,:);
