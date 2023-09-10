
QSUTB <- function(A_SUT,HF_IND,RT,RC,AC) {

## Procedure for 1-benchmark period
  a<- Sys.time()
  
  fq <- 4


## Required procedures

source("D:/Tesis SUT/QSUTB/chd.r")
source("D:/Tesis SUT/QSUTB/OmAR.r")
source("D:/Tesis SUT/QSUTB/Red_Mat.r")
source("D:/Tesis SUT/QSUTB/rdmt.r")
source("D:/Tesis SUT/QSUTB/MInv.r")
source("D:/Tesis SUT/QSUTB/RevRem.r")

library(Matrix)                                   ## Loading the Matrix library (sparse)
library(MASS)
library(matlib)

## =========================================================================================
## ============== DATA INPUTS ==============================================================
## =========================================================================================


setwd("D:/Tesis SUT/QSUTB/Data/")

RT  <- as.matrix(scan("./RT.txt"))
RTm <- matrix(RT,nrow=17,ncol=6)
RTM <- t(RTm)

RC  <- as.matrix(scan("./RC.txt"))
RCm <- matrix(RC,nrow=17,ncol=6)

RCM <- t(RCm)

AC <- scan("./AC.txt")
ACm <- matrix(AC,nrow=17,ncol=6)
ACM <- t(ACm)

IND <- scan("./IND.txt")
QSUTm <- matrix(IND,nrow=17)
QSUTM <- t(QSUTm)

DimIND <- dim(QSUTM)

ASUT  <- scan("./SUTs.txt")
ASUTm <- matrix(ASUT,nrow=17,ncol=18)
ASUTM <- t(ASUTm)

NOF <- dim(ACM)[1]
NOC <- dim(ACM)[2]

NOY <- dim(ASUTM)[1]/NOF
NOQ <- dim(QSUTM)[1]/NOF

D3Ind <- array(0,c(NOF,NOC,NOQ))
D3SUT <- array(0,c(NOF,NOC,NOY))

for (i in 1:NOY) {
  D3SUT[,,i] <- ASUTM[((NOF*i-NOF+1):(NOF*i)),]
}

for (i in 1:NOF) {
  D3Ind[i,,] <- t(QSUTM[((NOQ*i-NOQ+1):(NOQ*i)),])
}

SUTs3D <- c(D3SUT)
Ind3D  <- c(D3Ind)

setwd("D:/Tesis SUT/QSUTB/")

## =========================================================================================
## ====================== BENCHMARKING Module ==============================================
## =========================================================================================

AveSUT <- marginSums(abs(D3SUT),c(1,2))/NOY

DB <- rbind((2010:(2010+NOY-1)),1,(2010:(2010+NOY-1)),fq)
DB <- t(DB)

DI <- cbind(kronecker((2010:(2010+NOY)),matrix(1,fq,1)),kronecker(matrix(1,fq,1),1:fq))
DI <- DI[1:NOQ,]

D3BMK <- array(0,c(NOF,NOC,NOQ))      ## 3D container for the benchmarked series


for (i in 1:NOF) {
  for (j in 1:NOC) {
    if (AveSUT[i,j]>0) {
      D3BMK[i,j,] <- chd(cbind(DB,D3SUT[i,j,]),cbind(DI,D3Ind[i,j,]),.95,1,3)
    } else
      D3BMK[i,j,] <- D3BMK[i,j,]                     ## Loading the benchmarked series when benchmarks are available
  }
}

BInd3D <- c(aperm(D3BMK))

## =========================================================================================

## Containers

ECM <- array(0,c(NOF,NOC,NOQ))        # 3D HF matrix

R_H <- array(0,c(NOF*NOC*NOQ,NOF*NOQ))      # S-U -> Prod * fq
R_V <- array(0,c(NOF*NOC*NOQ,NOC*NOQ))      # Vertical -> Act * fq
R_T <- array(0,c(NOF*NOC*NOQ,NOF*NOC*NOY))      # Temporal -> Prod * Act

cc <- 0

for (r in 1:NOF) {
  for (t in 1:NOQ) {
    cc <- cc + 1
    HFT1_i <- ECM
    HFT1_i[r,,t] <- RTM[1,]
    R_H[,cc] <- c(aperm(HFT1_i)) ## Horizontal restrictions (1 Benchmarks)
  }
}

R_Hr <- Red_Mat(R_H) ## Horizontal restrictions (1 Benchmarks)
rH <- t(R_H)%*%BInd3D   ## Horizontal dicrepancies

##--------------------------------------------------------

cc <- 0

for (t in 1:NOQ) {
  for (m in 1:NOC) {
    cc <- cc + 1
    HFT1_i <- ECM
    HFT1_i[,m,t] <- RCM[,m]
    R_V[,cc] <- c(aperm(HFT1_i))
    }
}

R_V <- Red_Mat(R_V) ## Vertical restrictions (1 Benchmarks)
rV <- t(R_V)%*%BInd3D   ## Horizontal dicrepancies

##--------------------------------------------------------

ifq <- floor(NOQ/fq)
taggm <- kronecker(diag(ifq),array(1,c(fq,1)))
addP <- NOQ-dim(taggm)[1]

for (s in 1:addP) {
  taggm <- rbind(taggm,0)
}

cc <- 0

for (t in 1:NOY) {
  for (m in 1:NOC) {
    for (n in 1:NOF) {
      cc <- cc+1
      HFT1_i <- ECM
      HFT1_i[n,m,] <- taggm[,t]
      R_T[,cc] <- c(aperm(HFT1_i))
    }
  }
}

R_T <- Red_Mat(R_T) ## Temporal restrictions (1 Benchmarks)

rT <- t(R_T)%*%BInd3D-c(D3SUT)
rT[] <- 0

rS <- c(rH,rV,rT)

## Matrix J1 will all restrictions

J1 <- cbind(R_H,R_V,R_T)
#J1 <- cbind(R_H,R_T)

Jr1 <- Red_Mat(J1)

ClR  <- RRR(J1,Jr1)

resid <- t(ClR)%*%rS

J1 <- as(Jr1, "sparseMatrix")

resid <- as.matrix(resid)
  
##--------------------------------------------------------

if (max(ACM)>1) CR <- ACM else CR <- ACM*100

i1 <- (CR-100)^2

CAM <- 100-(10000-i1)^(1/2)		## Coefficient according as a non-linear function

D3AC <- ECM

for (t in 1:(NOQ)) {
  D3AC[,,t] <- CAM
}

Oe_i <- OmAR(.95,NOQ)
Oe <- kronecker(diag(NOF*NOC),Oe_i)

C <- diag(c(aperm(D3AC))*BInd3D)

Ve <- C %*% Oe %*% C

sVe <- as(Ve, "sparseMatrix")

Vd <- t(J1)%*%sVe%*%J1

Vd <- as.matrix(Vd)

Vd_1 <- S_Inv(Vd)



Out <- BInd3D + (Ve%*%J1)%*%(Vd_1%*%-resid)

Out <- as.matrix(Out)

Sal <- matrix(Out,NOQ)      ## Estimates as column time-series


b<- Sys.time() 
b-a  

write.table(Out, "D:/Tesis SUT/QSUTB/Data/sal_O.xls", sep="\t")

}



remove(RT,RTm,RC,RCm,AC,ACm,IND,QSUTm,ASUT,ASUTm,DimIND,ASUTM,QSUTM,Jr1,ClR,R_H,R_V,R_T,C,DB,DI,CAM,CR,ACM,AveSUT,
       HFT1_i,i1,J1,RCM,resid,rH,rT,RTM,rV,sVe,taggm,Vd_1,Ve,addP,cc,ECM,fq,i,ifq,j,m,NOC,NOF,NOQ,NOY,r,rS,s,t,n,
       Oe,Oe_i,R_Hr,Vd,D3AC,D3BMK,D3Ind,D3SUT)
