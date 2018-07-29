
#include <cuda.h>
//#include <cuda_runtime.h>
#include <stdlib.h>
#include "Rinternals.h"    

#define BLOCK_SIZE 32

// treat it as C code
extern "C" {
    SEXP matrixMultiply(SEXP ma,SEXP mb);
}
//#define BLOCKSIZE 192
__global__ void 
matrixMulCUDA(int *A,int *B,int *C,int m,int n,int k)
{
    int Cvalue=0;
    int row=blockIdx.y*blockDim.y+threadIdx.y;
    int col=blockIdx.x*blockDim.x+threadIdx.x;
    if(col<k && row<m){
    for(int e=0;e<n;++e)
    {
       Cvalue+=A[row*n+e]*B[e*k+col];
    }
    C[row*k+col]=Cvalue;
    }
}

SEXP matrixMultiply(SEXP ma,SEXP mb)
{
    SEXP maDim=getAttrib(ma,R_DimSymbol);
    SEXP mbDim=getAttrib(mb,R_DimSymbol);
    int Ax=INTEGER(maDim)[0];
    int Ay=INTEGER(maDim)[1];
    int Bx=INTEGER(mbDim)[0];
    int By=INTEGER(mbDim)[1];
    if(Ay!=Bx)
    {
    printf("error:matrix A's colsize not equal to B's rowsize.");
    exit(0);
    }
    int m=Ax;
    int n=Ay;
    int k=By;
    printf("Ax:%d\n",Ax);
    printf("Ay:%d\n",Ay);
    printf("Bx:%d\n",Bx);
    printf("By:%d\n",By);
    //double* tempA=REAL(ma);
    //double* tempB=REAL(mb);
    //float h_A[Ax*Ay];
    //float h_B[Bx*By];
    //for(int i=0;i<Ax*Ay;i++)
    //   h_A[i]=(float)tempA[i];
    //for(int j=0;j<Bx*By;j++)
    //   h_B[j]=(float)tempB[j];
    //float* h_C=(float *) malloc(Bx*Ay);
    //printf("%f",h_A[0]);
    int *h_A=INTEGER(ma);
    int *h_B=INTEGER(mb);
    int *h_C=(int *) malloc(m*k*sizeof(int));
    //printf("%d",h_A[1]);
    int *d_A;
    int *d_B;
    int *d_C;
    int size_A=m*n*sizeof(int);
    int size_B=n*k*sizeof(int);
    int size_C=m*k*sizeof(int);
    //printf("size_A:%d",size_A);
    //printf("size_B:%d",size_B);
    cudaMalloc((void **)&d_A,size_A);
    cudaMalloc((void **)&d_B,size_B);
    cudaMalloc((void **)&d_C,size_C);

    cudaMemcpy(d_A,h_A,size_A,cudaMemcpyHostToDevice);
    cudaMemcpy(d_B,h_B,size_B,cudaMemcpyHostToDevice);
    
    
    //dim3 dimBlock(BLOCK_SIZE,BLOCK_SIZE);
    //dim3 dimGrid(By/dimBlock.x,Ax/dimBlock.y);
    dim3 dimBlock(BLOCK_SIZE,BLOCK_SIZE);
    dim3 dimGrid((k+BLOCK_SIZE-1)/BLOCK_SIZE,(m+BLOCK_SIZE-1)/BLOCK_SIZE);
    matrixMulCUDA<<<dimGrid,dimBlock>>>(d_A,d_B,d_C,m,n,k);
    cudaDeviceSynchronize();
    cudaMemcpy(h_C,d_C,size_C,cudaMemcpyDeviceToHost);
    //cudaThreadSynchronize();
    //printf("%d",h_C[1]);
    SEXP reVec=PROTECT(allocMatrix(REALSXP,Ax,By));
    for(int i=0;i<Ax;i++)
        for(int j=0;j<By;j++)
        REAL(reVec)[i+Ax*j]=h_C[i+Ax*j];
    UNPROTECT(1);
    return reVec;
    //return ScalarReal(222);
}

