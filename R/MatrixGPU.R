
#'@examples
#'matrixA<-matrix(as.integer(1),3000,2000)
#'matrixB<-matrix(as.integer(2),2000,4000)
#'reMat<-MatrixMul(matrixA,matrixB,"inst/lib/MatrixMul.so")

MatrixMul<-function(a,b,sharedFileFile){
  dyn.load(sharedFileFile)
  beginTime<-Sys.time()
  reMat=.Call("matrixMultiply",a,b)
  endTime<-Sys.time()
  print(endTime-beginTime)
  return(reMat)
}
MatrixMul_original<-function(a,b){
  beginTime<-Sys.time()
  matAB<-matrixA%*%matrixB
  endTime<-Sys.time()
  print(endTime-beginTime)
  return(matAB)
}
