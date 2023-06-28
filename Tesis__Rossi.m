format long g

%% Oferta
Y_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Anuales Publicadas','B2:T18'),0);
x_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Originales','C4:U72'));
z_1     = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Publicadas','W2:W62'),0);
Y = Y_mul(1:14,1:13);  
% Series de alta frecuencia 
x = x_mul(1:56,1:13);
z = z_1(1:56,:);

ta = 1;
% Frequency conversion 0
sc = 4;    
% Type of univariate disaggregation procedure
opMethod = 3;
% Type of univariate disaggregation procedure: estimation method
type = 1;
% Multivariate temporal disaggregation
res = rossi(Y,x,z,ta,sc,opMethod,type);
% Printed output
z = res.y;
z_of = z;
format_1 = '%13.6f';
 format long g
  %csvwrite('D:\Tesis SUT\Results\Denton - Multivariado\hat_y_S.csv',z);
   dlmwrite('D:\Tesis SUT\Results\Multivariado - Rossi\hat_y_S.csv',z, 'precision', format_1);
file_out = 'rossi.out';   
tdprint(res,file_out);
edit rossi.out;
% Graphs
% Graphs
%tdplot(res);
figure
vnames = {'Impuestos','Agro', 'Minas', 'Industría', 'Serv. Píblicos', 'Construcción','Comercio','Información','Financieras','Inmobiliarias','Serv. Admin','Admin. Pública','Artes'};
for j=1:size(x,2)
    subplot(4,4,j)
    plot([x(:,j) res.y_prelim(:,j) res.y(:,j)]);
    title(vnames(j));
    legend('HF Tracker','Prelim. Estimate','Estimate','Location','best');
end

%% Demanda


z_1     = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Publicadas','Z2:Z62'),0);
Y = Y_mul(1:14,14:19);  
% Series de alta frecuencia 
x = x_mul(1:56,14:19);
z = z_1(1:56,:);

ta = 1;
% Frequency conversion 
sc = 4;    
% Type of univariate disaggregation procedure
opMethod = 3;
% Type of univariate disaggregation procedure: estimation method
type = 1;
% Multivariate temporal disaggregation
res = rossi(Y,x,z,ta,sc,opMethod,type);
z = res.y;
z_dm = z;
format_1 = '%13.6f';
 format long g
  %csvwrite('D:\Tesis SUT\Results\Denton - Multivariado\hat_y_S.csv',z);
   dlmwrite('D:\Tesis SUT\Results\Multivariado - Rossi\hat_y_D.csv',z, 'precision', format_1);
% Printed output
file_out = 'rossi.out';   
tdprint(res,file_out);
edit rossi.out;
% Graphs
% Graphs
%tdplot(res);
figure
vnames = {'Hogares', 'ISFLSH', 'Gobierno', 'Exportaciones', 'Importaciones','FBK'};
for j=1:size(x,2)
    subplot(2,3,j)
    plot([x(:,j) res.y_prelim(:,j) res.y(:,j)]);
    title(vnames(j));
    legend('HF Tracker','Prelim. Estimate','Estimate','Location','best');
end
y = [z_of z_dm];
format_1 = '%13.6f';
 format long g
  %csvwrite('D:\Tesis SUT\Results\Denton - Multivariado\hat_y_S.csv',z);
   dlmwrite('D:\Tesis SUT\Results\Multivariado - Rossi\hat_y.csv',y, 'precision', format_1);
