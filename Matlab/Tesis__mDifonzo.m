format long g
%% Oferta
Y_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Anuales Publicadas','B2:T18'),0);
x_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Originales','C4:U72'));
z_1     = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Publicadas','W2:W62'),0);
Y = Y_mul(1:14,1:13);  
% Series de alta frecuencia 
x = x_mul(1:60,1:13);
z = z_1(1:56,:);

% Type of aggregation
ta = 1;
% Frequency conversion 
sc = 4;    
% Model for the innovations: white noise (0), random walk (1)
type = 1;
% Number of high frequency indicators linked to each low frequency
% aggregate
f = ones(1,size(x,2));
% Multivariate temporal disaggregation
res = difonzo(Y,x,z,ta,sc,type,f);
z = res.y;
z_of = z;
%Save the info   
format_1 = '%13.6f';
 format long g
  %csvwrite('D:\Tesis SUT\Results\Denton - Multivariado\hat_y_S.csv',z);
   dlmwrite('D:\Tesis SUT\Results\Multivariado - Di Fonzo\hat_y_S.csv',z, 'precision', format_1);

  % Printed output
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
    plot([res.y(:,j)],'-b');
    hold on
    plot([res.y(:,j)-res.d_y(:,j) res.y(:,j)+res.d_y(:,j)],':r');
    title(vnames(j));
end


%% Demanda


z_1     = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Publicadas','Z2:Z62'),0);
Y = Y_mul(1:14,14:19);  
% Series de alta frecuencia 
x = x_mul(1:60,14:19);
z = z_1(1:56,:);

% Type of aggregation
ta = 1;
% Frequency conversion 
sc = 4;    
% Model for the innovations: white noise (0), random walk (1)
type = 1;
% Number of high frequency indicators linked to each low frequency
% aggregate
f = ones(1,size(x,2));
% Multivariate temporal disaggregation
res = difonzo(Y,x,z,ta,sc,type,f);
z = res.y;
z_dm = z;
format_1 = '%13.6f';
 format long g
  %csvwrite('D:\Tesis SUT\Results\Denton - Multivariado\hat_y_S.csv',z);
   dlmwrite('D:\Tesis SUT\Results\Multivariado - Di Fonzo\hat_y_D.csv',z, 'precision', format_1);

edit rossi.out;
% Graphs
% Graphs
%tdplot(res);
figure
vnames = {'Hogares', 'ISFLSH', 'Gobierno', 'Exportaciones', 'Importaciones','FBK'};
for j=1:size(x,2)
    subplot(2,3,j)
    plot([res.y(:,j)],'-b');
    hold on
    plot([res.y(:,j)-res.d_y(:,j) res.y(:,j)+res.d_y(:,j)],':r');
    title(vnames(j));
end

y = [z_of z_dm];
format_1 = '%13.6f';
 format long g
  %csvwrite('D:\Tesis SUT\Results\Denton - Multivariado\hat_y_S.csv',z);
   dlmwrite('D:\Tesis SUT\Results\Multivariado - Di Fonzo\hat_y.csv',y, 'precision', format_1);
