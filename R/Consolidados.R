library(zoo)
library(ggplot2)
library(readr)
library(readxl)
library(forecast)
library(tseries)

Y_pub <-   read_excel("D:/Tesis SUT/Data/Bases Tesis Originales.xlsx",sheet = "Bases Publicadas",col_names = FALSE,
                    range = "C3:U62")
Y_pub <- as.matrix(Y_pub)

Y_pre <-   read_excel("D:/Tesis SUT/Results/ALL.xlsx",sheet = "P",col_names = FALSE,
                           range = "C4:U63")
Y_pre <- as.matrix(Y_pre)

vector <- c("Chow y Lin","Fernandez",
            "Litterman","Santos Silva y Cardoso",
            "Proietti","Denton","Multivariado - Denton",
            "Multivariado - Rossi","Multivariado - Di Fonzo","ANN","LSMT",
            "Chollete_Dagum_Mult") 

#var <- vector[1] ## Para pruebas

equi <-  matrix(0,length(vector),2)
cor_becn <- cor_all <- matrix(0,length(vector),dim(Y_pub)[2])
resM_b <- resM_m <- res_b <- res_m <- matrix(0,dim(Y_pub)[2],length(vector))
rownames(equi)<- rownames(cor_all) <- rownames(cor_becn)<-vector

colnames(resM_b)<- colnames(resM_m)<- colnames(res_b)<- colnames(res_m) <- vector



for (var in vector) {

dir<- paste("D:/Tesis SUT/Results/",var,"/",sep = "")
hat_y <- read_csv(paste(dir,"hat_y.csv",sep = ""), 
                         col_names = FALSE)



# hat_residual <- read_csv(paste(dir,"hat_residual.csv",sep = ""), 
#                   col_names = FALSE)
Y_est <- as.matrix(hat_y)

#grow_orig <- ((Y_pre - lag(Y_pre))/lag(Y_pre))*100
#grow_rate <- ((Y_est - lag(Y_est))/lag(Y_est))*100


#corr_bench <- cor(grow_orig[2:56,],grow_rate[2:56,])
#### C�lculo de error cuadratico medio ## 
dif <- Y_pub[1:56,] - Y_est[1:56,]
dif_2 <- dif^2
ECM <-sqrt(colMeans(dif_2))

ABS_1 <- abs(dif)
MAE_bench <- colMeans(ABS_1)

  if(dim(Y_est)[1]>56){
    #corr_all <- cor(grow_orig[-1,],grow_rate[-1,])
    #cor_all[var,] <- diag(corr_all)
    V <- cor(Y_pub[57:60,],Y_est[57:60,])
    IN_dif <- Y_pub[57:60,] - Y_est[57:60,]
    IN_dif_2 <- IN_dif^2
    IN_ECM <-sqrt(colMeans(IN_dif_2))

    ABS_2 <- abs(IN_dif)
    MAE_fore <-colMeans(ABS_2)

    pib_de <-  sum(Y_est[57:60,1:13])
    pib_of <- sum(Y_est[57:60,14:19][,-5]) - sum(Y_est[57:60,18])
    equi[var,1] <- pib_of
    equi[var,2] <- pib_de
  }
resM_b[,var] <- ECM
resM_m[,var] <- MAE_bench
res_b[,var] <- IN_ECM
res_m[,var] <- MAE_fore
#cor_becn[var,] <- diag(corr_bench)
#cor_all[var,] <- diag(corr_all)


##### Comportamiento de los residuales
# Residual <- matrix(0,1,18)
# for (i in 1:18) {
#   y <- hat_residual[,i]
#   y_est <- ts(y, frequency=4, start=c(2005,1))
#   fit <- auto.arima(y_est)
#   Residual[1,i] <- as.character(fit)
  
#   # <- paste(var, i, sep = "")
#   #assign(nam, seas(y_est))
  
# }

# Residual


##### Guardar resultados 

#write.csv2(dif,file = paste(dir,"dif_bench.csv",sep = ""), dec = ".")
#write.csv2(ECM,file = paste(dir,"IN_RECM.csv",sep = ""), dec = ".")
#write.csv2(Residual,file = paste(dir,"Residuales.csv",sep = ""), dec = ".")
#write.csv2(MAE_bench,file = paste(dir,"MAE_fore.csv",sep = ""), dec = ".")
}
dir <- "D:/Tesis SUT/Results/"
write.csv2(resM_m,file = paste(dir,"MAE_Bench.csv",sep = ""), dec = ".")
write.csv2(res_m,file = paste(dir,"MAE_Forecast.csv",sep = ""), dec = ".")
write.csv2(resM_b,file = paste(dir,"RSME_Bench.csv",sep = ""), dec = ".")
write.csv2(res_b,file = paste(dir,"RSME_Forecats.csv",sep = ""), dec = ".")
write.csv2(cor_becn,file = paste(dir,"Corr_Bench.csv",sep = ""), dec = ".")
write.csv2(cor_all,file = paste(dir,"Corr_Forecast.csv",sep = ""), dec = ".")
write.csv2(equi,file = paste(dir,"Equilibrio.csv",sep = ""), dec = ".")



##### Almacenar series y graficar resultados #####



for (var in vector) {
  
  equi <-  matrix(0,dim(Y_pub)[1],length(vector))
  colnames(equi) <- vector
  
  dir<- paste("D:/Tesis SUT/Results/",var,"/",sep = "")
  hat_y <- read_csv(paste(dir,"hat_y.csv",sep = ""), 
                          col_names = FALSE)

  Y_est <- as.matrix(hat_y)
    for(i in 1:dim(Y_est)[2]){
      equi[,var] <- Y_est[,i]
    }
  }

i <- 4 
var <- vector[6] ## Para pruebas

for(i in 1:dim(Y_pub)[2]){
  
  equi <-  matrix(0,dim(Y_pub)[1],length(vector))
  colnames(equi) <- vector
  
  for(var in vector){
    dir<- paste("D:/Tesis SUT/Results/",var,"/",sep = "")
    hat_y <- read_csv(paste(dir,"hat_y.csv",sep = ""), 
                            col_names = FALSE)
    Y_est <- as.matrix(hat_y)
    equi[,var] <- cbind(Y_est[,i],equi[,var])[,1] 
  }


  vector2 <- c("Chow y Lin","Fernandez",
            "Litterman","Santos Silva y Cardoso",
            "Proietti","Denton","Multivariado - Denton",
            "Multivariado - Rossi","Multivariado - Di Fonzo","ANN","LSMT",
            "Chollete_Dagum_Mult","Real","Preliminar") 
  final <- cbind(equi,Y_pub[,i],Y_pre[,i])
  colnames(final) <- vector2
  dir <- "D:/Tesis SUT/Results/Consolidados/"
  write.csv2(final,file = paste(dir,"Consolidado",i,".csv",sep = ""), dec = ".")
}



 # Create a graph of the data using ggplot2 over time
library(ggplot2)
library(scales)
library(ggrepel)


data <- final[1:56,]

data <- data.frame(data)

ds <- cbind(final,quarterly_dates)
write.csv2(ds,file = paste(dir,"Consolidado.csv",sep = ""), dec = ".")

ggplot(data = final,
       mapping = aes(x = "quarterly_dates", y = "Real", color = "site")) +
 geom_line() +
 theme_bw()
dff <- ts(data=final[1:56,],start=c(2005,1),frequency=4)




library(ggplot2)

ts.plot(dff[,1:3],
         gpars = list(xlab = "Year",
                      ylab = "Value",
                      col = c("red", "blue", "green")))

# Plot the time series
ts.plot(dff[, 4:6], 
        gpars = list(xlab = "Año", 
                     ylab = "Miles de millones de pesos", 
                     col = c("red", "blue", "green")))

dff$date <- as.Date(paste(dff$year, dff$month, "01", sep = "-"))

# Add points
points(dff[, 4:6], pch = 19)

# Add labels
labels <- c("Series 1", "Series 2", "Series 3")
text(dff[, 4:6], labels, cex = 0.8)

# Draw different types of graphs
ts.plot(dff[, 4:6], type = "l", lty = 1)
ts.plot(dff[, 4:6], type = "b", lty = 2)
ts.plot(dff[, 4:6], type = "c", lty = 3)

ggplot(dff, aes(x = time(dff), y = dff[,1])) +
  geom_line() +
  geom_point() +
  labs(x = "Year", y = "Value") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_x_continuous(breaks = seq(2005, 2019, 1)) +
  scale_y_continuous(labels = comma) +
  ggtitle("Time Series Plot") +
  theme(plot.title = element_text(hjust = 0.5))



library(dplyr)
hat_y %>%
  mutate(growth_rate = (hat_y[,1] - lag(hat_y[,1])) / lag(hat_y[,1])) 
lag(hat_y[,1]
#########################################################################
#########################################################################

jarque.bera.test(dif[1:56,1])
plot(y)
nr <- ts(dif[1:56,7], frequency=4, start=c(2005,1))
auto.arima(nr)
plot(log(nr))
library("tempdisagg")
library("seasonal")
static(`Santos Silva y Cardoso2`)
view(`Santos Silva y Cardoso2`)
#########################################################################

ac <- 1
pl_est <- Y_est[,ac]
pl_pub <- Y_pub[,ac]

sum(pl_est[13:16])
sum(pl_pub[13:16])

date<-seq(as.Date("2005-01-01"), by="quarter", length.out = 60)
df <-  data.frame(date,pl_pub,pl_est)



 theme_set(theme_minimal())
 ggplot(df, aes(x=date)) + 
   geom_line(aes(y = pl_pub), color = "darkred") +
   geom_point(aes(y = pl_pub), color = "darkred")+
   geom_line(aes(y = pl_est), color="steelblue", linetype="twodash")+
   geom_point(aes(y = pl_est),color="steelblue") +
   xlab("") 

 
#############################  
 
 
library(car)
x<- hat_residual$X2
qqPlot(x)
hist(x, freq = FALSE, main = "Histogram and density")
jarque.bera.test(x)


dx <- density(x)

# Add density
lines(dx, lwd = 2, col = "red")

# Plot the density without histogram
plot(dx, lwd = 2, col = "red",
     main = "Density")

# Add the data-poins with noise in the X-axis
rug(jitter(x))



#################### Modelo ARIMA ################################
#### 


library(urca)
library(knitr)
library(foreign)
library(forecast)
library(FitAR)
library(lmtest)
library(e1071)
library(fpp)
library(urca)
library(tseries)
library(lmtest)
library(uroot)
library(fUnitRoots)
library(sarima)
library(tsoutliers)
library(forecast)



y <- hat_residual$X2
myts <- ts(y, frequency=4, start=c(2005,1))
plot(myts)


##### Prueba de raiz unitaria Dickey-Fuller ######

adf.test(myts)
adf.test(myts,k = 4)

dmyts <- diff(myts)
adf.test(dmyts)

plot(dmyts)

###### Prueba raiz unitaria estacional ############################

nsdiffs(dmyts)

###### Chequamos los ACF y PACF #########################

monthplot(dmyts)

acf(dmyts)
pacf(dmyts)

acf(dmyts,lag.max = 48, ci.type='ma')
pacf(dmyts,lag.max = 48, ci.type='ma')

modelo = Arima(myts, c(2, 1, 0),seasonal = list(order = c(0, 0, 1), period = 4),lambda = 1)
coeftest(modelo)

res_model <- modelo$residuals

########### Test de correlaci�n de los residuales  ############## 
acf(res_model)
pacf(res_model)

length(res_model)/4
sqrt(length(res_model))

Box.test(res_model, lag =36 , type = "Ljung-Box", fitdf = 8)

##########  Test de normalidad        ######

jarque.bera.test(res_model)

############ Cusum #############


###Estad�sticas CUSUM
res=res_model
cum=cumsum(res)/sd(res)
N=length(res)
cumq=cumsum(res^2)/sum(res^2)
Af=0.948 ###Cuantil del 95% para la estad?stica cusum
co=0.14013####Valor del cuantil aproximado para cusumsq para n/2
####Para el caso de la serie de pasajeros es aprox (144-12)/2=66
LS=Af*sqrt(N)+2*Af*c(1:length(res))/sqrt(N)
LI=-LS
LQS=co+(1:length(res))/N
LQI=-co+(1:length(res))/N

#CUSUM
plot(cum,type="l",ylim=c(min(LI),max(LS)),xlab="t",ylab="",main="CUSUM")
lines(LS,type="S",col="red")
lines(LI,type="S",col="red")


#CUSUM Square

plot(cumq,type="l",xlab="t",ylab="",main="CUSUMSQ")                      
lines(LQS,type="S",col="red")                                                   
lines(LQI,type="S",col="red")


########### Outliers ############

outliers_aut=tso(myts)
outliers_aut

resi= residuals(modelo)
plot(resi)
coef= coefs2poly(modelo)
outliers= locate.outliers(resi,coef)


n=length(myts)
xreg = outliers.effects(outliers,n )

tso=tso(myts,xreg=xreg,types=c("AO","LS"),tsmethod="arima",args.tsmethod=list(order=c(2,1,0),seasonal = list(order = c(1, 0, 0)),include.mean=F))
tso




################# Automaticos #####################
library(seasonal)
auto.arima(myts)
view(seas(myts))






#########################################################
############# Test de compatibilidad ####################
#########################################################




for (i in 2:19) {
  
  vector <- c("Chow y Lin","Fernandez","Litterman","Santos Silva y Cardoso","Proietti") 
  
  h = round((56)^(1/3)+1)
  
  var <- vector[1]
  var_2 <- vector[2] 
  
  value <- matrix(0,5,5)
  pvalue <- matrix(0,5,5)
  
  
  rownames(value) <- vector
  colnames(value) <- vector
  
  rownames(pvalue) <- vector
  colnames(pvalue) <- vector
  

for (var in vector) {
  for (var_2 in vector) {
    
  if (var != var_2) {
    
    dir1<- paste("D:/Tesis SUT/Results/",var,"/",sep = "")
    dir2<- paste("D:/Tesis SUT/Results/",var_2,"/",sep = "")
    
    
    dif_bench_1 <- read_delim(paste(dir1,"dif_bench.csv",sep = ""), 
               delim = ";", escape_double = FALSE, trim_ws = TRUE)
    dif_bench_2 <- read_delim(paste(dir2,"dif_bench.csv",sep = ""), 
                              delim = ";", escape_double = FALSE, trim_ws = TRUE)
    d_b1 <- ts(dif_bench_1[,i], frequency=4, start=c(2005,1))
    d_b2 <- ts(dif_bench_2[,i], frequency=4, start=c(2005,1))
    
    try(s<- dm.test(d_b1,d_b2, h = 5))
    value[var,var_2]= round(s$statistic,4)
    pvalue[var,var_2]= round(s$p.value,4)
  }
  }
  
}

dir <- "D:/Tesis SUT/Results/Pruebas/"
write.csv2(value,file = paste(dir,"va",i,".csv",sep = ""), dec = ".")
write.csv2(pvalue,file = paste(dir,"vap",i,".csv",sep = ""), dec = ".")

}




for (i in 2:19) {
vector <- c("Chow y Lin","Fernandez","Litterman","Santos Silva y Cardoso","Proietti") 
  h = round((56)^(1/3)+1)
  
  var <- vector[1]
  var_2 <- vector[2] 
  
  value <- matrix(0,5,5)
  pvalue <- matrix(0,5,5)
  
  
  rownames(value) <- vector
  colnames(value) <- vector
  
  rownames(pvalue) <- vector
  colnames(pvalue) <- vector
  
  
  for (var in vector) {
    for (var_2 in vector) {
      
      if (var != var_2) {
        
        dir1<- paste("D:/Tesis SUT/Results/",var,"/",sep = "")
        dir2<- paste("D:/Tesis SUT/Results/",var_2,"/",sep = "")
        
        
        dif_bench_1 <- read_delim(paste(dir1,"dif_fore.csv",sep = ""), 
                                  delim = ";", escape_double = FALSE, trim_ws = TRUE)
        dif_bench_2 <- read_delim(paste(dir2,"dif_fore.csv",sep = ""), 
                                  delim = ";", escape_double = FALSE, trim_ws = TRUE)
        d_b1 <- ts(dif_bench_1[,i], frequency=4, start=c(2019,1))
        d_b2 <- ts(dif_bench_2[,i], frequency=4, start=c(2019,1))
        
        try(s<- dm.test(d_b1,d_b2, h = 1))
        value[var,var_2]= round(s$statistic,4)
        pvalue[var,var_2]= round(s$p.value,4)
      }
    }
    
  }
  
  dir <- "D:/Tesis SUT/Results/Pruebas/Forecast/"
  write.csv2(value,file = paste(dir,"va",i,".csv",sep = ""), dec = ".")
  write.csv2(pvalue,file = paste(dir,"vap",i,".csv",sep = ""), dec = ".")
  
}