
format long g

Y_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Anuales Publicadas','B2:T18'),0);
x_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Originales','C4:U72'));

z = zeros(56,19);
z_u = zeros(56,19);
z_Xic = zeros(56,19);


for ii = 1:19

    Y = Y_mul(1:13,ii);  
    
 % Series de alta frecuencia 
    x = x_mul(1:56,ii);

% Desagregación temporal Metodó de Dethon 
ta = 1;    % Type of aggregation
d = 2;     % Minimizing the volatility of d-differenced series.
sc = 4;    % Frequency conversion.
op1 = 2;   % Variant: 1=additive, 2=proportional.
res = denton(Y,x,ta,d,sc,op1); % Calling the function: output is loaded in a structure called res.

 z(:,ii) = res.y;
 z_u(:,ii) =res.u;

end

  csvwrite('D:\Tesis SUT\Results\Denton\hat_y.csv',z)
  csvwrite('D:\Tesis SUT\Results\Denton\hat_residual.csv',z_u)
  