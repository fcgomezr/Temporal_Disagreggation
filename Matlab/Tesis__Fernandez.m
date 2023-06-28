format long g

Y_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Anuales Publicadas','B2:T18'),0);
x_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Originales','C4:U72'));


beta = zeros(19,2);
beta_sd = zeros(19,2);
beta_t = zeros(19,2);


z = zeros(60,19);
z_u = zeros(60,19);
z_Xic = zeros(2,19);
s_k = zeros(2,19);

for ii = 1:19
    % Series desdes 2005 - 2018
    Y = Y_mul(1:14,ii);  
    
    % Series de alta frecuencia 
    x = x_mul(1:60,ii);
    
    % Desagregación temporal Metodó de Chow y Lin
    ta = 1;    % Type of aggregation
    
    sc = 4;    % Frequency conversion.
    op1 = 2;   % Variant: 1=additive, 2=proportional.
    opC = -1;
    res = fernandez(Y,x,ta,sc,opC);


    beta(ii,:) = (res.beta)';
    beta_sd(ii,:) = (res.beta_sd)';
    beta_t(ii,:) = (res.p)';
    
    %td_print(res,'td.sal'); % op1=1: series are printed in ASCII file
    %td_plot(res); 
    z(:,ii) = res.y;
    z_u(:,ii) =res.u;
    z_Xic(1,ii) = res.aic;
    z_Xic(2,ii) = res.bic;
    s_k(2,ii) = res.K;
end 

  csvwrite('D:\Tesis SUT\Results\Fernandez\hat_y.csv',z)
  csvwrite('D:\Tesis SUT\Results\Fernandez\hat_residual.csv',z_u)
  csvwrite('D:\Tesis SUT\Results\Fernandez\Test.csv',z_Xic)
  format_1 = '%13.6f';
  dlmwrite('D:\Tesis SUT\Results\Fernandez\Test Guerrero.csv',s_k, 'precision', format_1);



  csvwrite('D:\Tesis SUT\Results\Fernandez\beta.csv',beta);
  csvwrite('D:\Tesis SUT\Results\Fernandez\beta_sd.csv',beta_sd);
  csvwrite('D:\Tesis SUT\Results\Fernandez\beta_t.csv',beta_t);
