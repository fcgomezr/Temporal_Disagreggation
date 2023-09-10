
library(readxl)
library(pracma)

vec <- function(Y) {
  # PURPOSE: Create a matrix stacking the columns of Y
  # ------------------------------------------------------------
  # SYNTAX: Y_big <- vec(Y)
  # ------------------------------------------------------------
  # OUTPUT: Y_big = matrix of columns of Y
  # ------------------------------------------------------------
  # INPUT: Y = an nxM matrix of original series, columnwise
  # ------------------------------------------------------------
  
  # Data dimension
  M <- ncol(Y)
  
  Y_big <- Y[,1]   # Starting the recursion
  j <- 2
  while (j <= M) {
    Y_big <- c(Y_big, Y[,j])
    j <- j + 1
  }
  
  return(Y_big)
}

desvec <- function(Zv, M) {
  # PURPOSE: Creates a matrix unstacking a vector
  # ------------------------------------------------------------
  # SYNTAX:  Z = desvec(Zv,M);
  # ------------------------------------------------------------
  # OUTPUT:  Z = matrix with M cols.
  # ------------------------------------------------------------
  # INPUT: Zv    : a vector nx1 
  #        M     : number of cols.
  
  n <- dim(Zv)[1]
  
  if (length(dim(Zv)[2]) != 1) {
    stop(" *** NUMBER OF COLUMNS GREATER THAN ONE *** ")
  }
  
  N <- round(n/M)
  
  Z <- matrix(Zv[1:N], ncol = 1)
  
  j <- 2
  while (j <= M) {
    Z <- cbind(Z, Zv[((j-1)*N+1):(j*N)])
    j <- j + 1
  }
  
  return(Z)
}




Y_mul <- round(read_excel("D:/Tesis SUT/Data/Bases Tesis Originales.xlsx", 
               sheet = "Bases Anuales Publicadas", 
               range = "B2:T16"), 0)
x_mul <- round(read_excel("D:/Tesis SUT/Data/Bases Tesis Originales.xlsx", 
               sheet = "Bases Originales", 
               range = "C3:U63"))
rt  <- as.matrix(round(read_excel("D:/Tesis SUT/Data/Bases Tesis Originales.xlsx", 
               sheet = "Bases Originales", 
               range = "C1:U1",
               col_names = FALSE),0))


x_mul <- x_mul[1:60,]
# Vectorizamos las matrices
Y <- as.data.frame((vec(as.data.frame(Y_mul))))
x <- as.data.frame((vec(as.data.frame(x_mul))))

fy <- dim(Y_mul)[1] # Número de años
fp <- dim(Y_mul)[2] # Número de sectores
ta <- 4 # Número de trimestres por año 
nq <- dim(x_mul)[1] # Número de trimestres

qext <- nq - fy*ta

#Matriz de agregación temporal
C <- kronecker(diag(fy),t(rep(1,ta)))
C <- cbind(C,matrix(0,nrow = fy,ncol = qext))

mt <- matrix(0, nrow = nq,ncol = fp)
J1 <- matrix(0, nrow = nq*fp,ncol = nq)
for(i in 1:nq){
mtt <- mt 
mtt[i,] = rt
J1[,i] <-  vec(mtt)
}
#write diag(rt) in the diagonal of a matrix of zeros
# Alternativa 
dl <- kronecker(rt,diag(nq))

diag(nq)

J <- t(J1)

J <- dl
###########

# Matriz de agregación H_2
A <- diag(fp)
J2 <- kronecker(A,C)

H <- rbind(J2,J)

T <- H %*% as.matrix(x)



dir <- "D:/Tesis SUT/Results/Chollete_Dagum_Mult/"
# Define the number of matrices and their size
n_matrices <- fp
matrix_size <- 60

# Create a matrix with zeros
m <- matrix(0, nrow=n_matrices*matrix_size, ncol=n_matrices*matrix_size)

# Fill the diagonal blocks with matrices using a loop
for (i in 1:n_matrices) {
  start_row <- (i-1)*matrix_size+1
  end_row <- i*matrix_size
  start_col <- (i-1)*matrix_size+1
  end_col <- i*matrix_size
  file <- paste(dir, "w_ar", i, ".csv", sep = "")
  Vmat <- read.csv(file,header=FALSE)
  Vmat <- as.matrix(Vmat)
    m[start_row:end_row, start_col:end_col] <- Vmat
}
V_h <- m
V_l <- H %*% V_h %*% t(H)
V_l_i <- pinv(V_l)
L <- V_h %*%  t(H) %*%  V_l_i # Matriz de filtros

U <- Y - T # Residuos
U<-as.matrix(U)
U <- rbind(U, -as.matrix(T[267:326,]))


y_est <- x + L %*% U # Estimación de la serie original
## COU 
y_1 <- desvec(as.matrix(y_est), fp)
write.csv2(y_1, file = "D:/Tesis SUT/Results/Chollete_Dagum_Mult/y_Ch_4.csv")

## Supply Use Table 
s <- y_1[,1:12]

## Demand Use Table

d <- y_1[,13:18]

## Equilibrium

des = rowSums(s) - rowSums(d) # Equilibrio


g <-  t(as.matrix(y_est)) %*% t(H)
g <-  H%*%(as.matrix(y_est))
round(Y-g,0) 
