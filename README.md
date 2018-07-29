
==================================
# RMatrixGPU
1.introduction
This is the Matrix Multiplication with CUDA in R language.
My GPU is GeForce GTX 1070.


2.How to run the codes?
1)compile the MatrixMul.cu by the following command:
nvcc -g -Xcompiler -fPIC -c MatrixMul.cu -arch=sm_35 -I/usr/include/R -I/usr/share/R/include
R CMD SHLIB MatrixMul.o -lcudart -L/usr/local/cuda-8.0/lib64

2)Run the R codes.


3.compare the speed of the GPU version with the normal version?


matrixA<-matrix(as.integer(1),3000,2000)
matrixB<-matrix(as.integer(2),2000,4000)

https://github.com/sechenmo/RMatrixGPU/blob/master/Screenshot%20from%202018-07-30%2000-30-06.png
