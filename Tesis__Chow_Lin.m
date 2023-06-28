format long g
Y_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Anuales Publicadas','B2:T18'),0);
x_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Originales','C4:U72'));



z = zeros(60,19);
z_u = zeros(60,19);
z_Xic = zeros(2,19);
z_rho = zeros(2,19);


beta = zeros(19,2);
beta_sd = zeros(19,2);
beta_t = zeros(19,2);

s_k = zeros(2,19);
s_kp = zeros(2,19);
w=[];
W=[];
Wi=[];
for ii = 1:19
    % Series desdes 2005 - 2018
    Y = Y_mul(1:14,ii);  
    
    % Series de alta frecuencia 
    x = x_mul(1:60,ii);
    
    % Desagregación temporal Metodó de Chow y Lin
    ta = 1;    % Type of aggregation
    
    sc = 4;    % Frequency conversion.
    op1 = 2;   % Variant: 1=additive, 2=proportional.
    
    res = chowlin(Y,x,ta,sc,1,1, []);
    
    %td_print(res,'td.sal'); % op1=1: series are printed in ASCII file
    %td_plot(res); 
    z(:,ii) = res.y;
    z_u(:,ii) =res.u;
    z_Xic(1,ii) = res.aic;
    z_Xic(2,ii) = res.bic;
    z_rho(1,ii) = res.rho;
    s_k(2,ii) = res.K;
    beta(ii,:) = (res.beta)';
    beta_sd(ii,:) = (res.beta_sd)';
    beta_t(ii,:) = (res.p)';
    w=res.w;
    w_ar=res.w_ar;
    Wi=res.Wi;
    filename = sprintf('D:\\Tesis SUT\\Results\\Chow y Lin\\w_%d.csv',ii);
    csvwrite(filename,w);
    filename = sprintf('D:\\Tesis SUT\\Results\\Chow y Lin\\w_ar%d.csv',ii);
    csvwrite(filename,w_ar)
    
end 
format_1 = '%13.6f';
 format long g

  csvwrite('D:\Tesis SUT\Results\Chow y Lin\hat_y.csv',z);
  csvwrite('D:\Tesis SUT\Results\Chow y Lin\hat_residual.csv',z_u);
  csvwrite('D:\Tesis SUT\Results\Chow y Lin\Test.csv',z_Xic);
  csvwrite('D:\Tesis SUT\Results\Chow y Lin\Rho.csv',z_rho);
  dlmwrite('D:\Tesis SUT\Results\Chow y Lin\Test Guerrero.csv',s_k, 'precision', format_1);

  csvwrite('D:\Tesis SUT\Results\Chow y Lin\beta.csv',beta);
  csvwrite('D:\Tesis SUT\Results\Chow y Lin\beta_sd.csv',beta_sd);
  csvwrite('D:\Tesis SUT\Results\Chow y Lin\beta_t.csv',beta_t);


