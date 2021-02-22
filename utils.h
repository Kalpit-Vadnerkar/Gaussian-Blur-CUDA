#ifndef UTILS_H
#define UTILS_H
#include <cuda.h> // your system must have nvcc.
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include <cassert>
#include <math.h>
#include <cstdio> 
#include <iostream>

#define checkCudaErrors(ans) check( (ans), #ans, __FILE__, __LINE__)

template<typename T>
void check(T err, const char* const func, const char* const file, const int line){
    if(err != cudaSuccess){
        std::cerr << "CUDA error at:: " << file << ":" << line << std::endl;
        std::cerr << cudaGetErrorString(err) << " " << func << std::endl;
        exit(1);
    }
} 

template<typename T>
void printArray(T *arr, const int sz){

  for(int i = 0; i < sz; i++){ 
      if(i%9 == 0){ 
          std::cout <<"\n";
      }
     std::cout << arr[i] << "  "; 
  } 
  std::cout <<"\n";

}


#endif 
