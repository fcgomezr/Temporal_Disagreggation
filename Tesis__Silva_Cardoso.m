format long g
Y_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Anuales Publicadas','B2:T18'),0);
x_mul = round(xlsread('D:\Tesis SUT\Data\Bases Tesis Originales.xlsx','Bases Originales','C4:U72'));



beta = zeros(19,2);
beta_sd = zeros(19,2);
beta_t = zeros(19,2);
z_rho = zeros(2,19);

z = zeros(60,19);
z_u = zeros(60,19);
z_Xic = zeros(2,19);
s_k = zeros(2,19);

for ii = 1:19
    % Series desdes 2005 - 2018
    Y = Y_mul(1:14,ii);  
    
    % Series de alta frecuencia 
    x = x_mul(1:60,ii);

% Type of aggregation
ta=1;
% Frequency conversion
s=4;
% Method of estimation
type=0;
% Intercept
opC = 1;
% Interval of rho for grid search
% rl = [];
% rl = 0.57;
rl = [-0.99 0.99 500];

% Note: the grid search applied in the undelying ssc procedure generates 
% a warning when phi=0. This warning is muted.
warning off MATLAB:nearlySingularMatrix
% Calling the function: output is loaded in a structure called res
res = ssc(Y,x,ta,s,type,opC,rl);

    z(:,ii) = res.y;
    z_u(:,ii) =res.u;
    z_Xic(1,ii) = res.aic;
    z_Xic(2,ii) = res.bic;
    s_k(2,ii) = res.K;
    z_rho(1,ii) = res.phi;

    beta(ii,:) = (res.beta)';
    beta_sd(ii,:) = (res.beta_sd)';
    beta_t(ii,:) = (res.p)';
end 


  csvwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\hat_y.csv',z)
  csvwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\hat_residual.csv',z_u)
  csvwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\Test.csv',z_Xic)

      format_1 = '%13.6f';
  dlmwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\Test Guerrero.csv',s_k, 'precision', format_1);

csvwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\Rho.csv',z_rho);
  csvwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\beta.csv',beta);
  csvwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\beta_sd.csv',beta_sd);
  csvwrite('D:\Tesis SUT\Results\Santos Silva y Cardoso\beta_t.csv',beta_t);