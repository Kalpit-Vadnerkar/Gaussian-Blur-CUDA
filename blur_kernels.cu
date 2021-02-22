#include "./gaussian_kernel.h" 


#define BLOCK 32

/*
The actual gaussian blur kernel to be implemented by 
you. Keep in mind that the kernel operates on a 
single channel.
 */
__global__ 
void gaussianBlur(unsigned char *d_in, unsigned char *d_out, 
        const int rows, const int cols, float *d_filter, const int filterWidth){
  int px = blockIdx.x * blockDim.x + threadIdx.x;
  int py = blockIdx.y * blockDim.y + threadIdx.y;
  int i = py * cols + px;
  if (px < cols && py < rows) {
    int pixval = 0;
    int fx = 0;
    int fy = 0;
    for(int blurRow = -(filterWidth / 2); blurRow < (filterWidth / 2) + 1; ++blurRow) {
        for(int blurCol = -(filterWidth / 2); blurCol < (filterWidth / 2) + 1; ++blurCol) {        
            int curRow = py + blurRow;
            int curCol = px + blurCol;
            if(curRow > -1 && curRow < rows && curCol > -1 && curCol < cols) {
            pixval += (d_in[curRow * cols + curCol] * d_filter[fx * filterWidth + fy]);
            fy++;
            }
        fx++;
        }
    }
    d_out[i] = (unsigned char) pixval;
  }
} 



/*
  Given an input RGBA image separate 
  that into appropriate rgba channels.
 */
__global__ 
void separateChannels(uchar4 *d_imrgba, unsigned char *d_r, unsigned char *d_g, unsigned char *d_b,
        const int rows, const int cols){

  int px = blockIdx.x * blockDim.x + threadIdx.x;
  int py = blockIdx.y * blockDim.y + threadIdx.y;
  if (px < cols && py < rows) {
    int i = py * cols + px;
    d_r[i] = d_imrgba[i].x;
    d_g[i] = d_imrgba[i].y;
    d_b[i] = d_imrgba[i].z;
  }
} 
 

/*
  Given input channels combine them 
  into a single uchar4 channel. 

  You can use some handy constructors provided by the 
  cuda library i.e. 
  make_int2(x, y) -> creates a vector of type int2 having x,y components 
  make_uchar4(x,y,z,255) -> creates a vector of uchar4 type x,y,z components 
  the last argument being the transperency value. 
 */
__global__ 
void recombineChannels(unsigned char *d_r, unsigned char *d_g, unsigned char *d_b, uchar4 *d_orgba,
        const int rows, const int cols){
  int px = blockIdx.x * blockDim.x + threadIdx.x;
  int py = blockIdx.y * blockDim.y + threadIdx.y;
  if (px < cols && py < rows) {
    int i = py * cols + px;
    d_orgba[i] = make_uchar4(d_b[i], d_g[i], d_r[i]);
  }
}

void your_gauss_blur(uchar4* d_imrgba, uchar4 *d_oimrgba, size_t rows, size_t cols, 
        unsigned char *d_red, unsigned char *d_green, unsigned char *d_blue, 
        unsigned char *d_rblurred, unsigned char *d_gblurred, unsigned char *d_bblurred,
        float *d_filter,  int filterWidth){
 


        dim3 blockSize(BLOCK, BLOCK, 1);
        dim3 gridSize((cols-1)/BLOCK + 1, (rows-1)/BLOCK + 1, 1);

        separateChannels<<<gridSize, blockSize>>>(d_imrgba, d_red, d_green, d_blue, rows, cols);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        gaussianBlur<<<gridSize, blockSize>>>(d_red, d_rblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        gaussianBlur<<<gridSize, blockSize>>>(d_green, d_gblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        gaussianBlur<<<gridSize, blockSize>>>(d_blue, d_bblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        recombineChannels<<<gridSize, blockSize>>>(d_rblurred, d_gblurred, d_bblurred, d_oimrgba, rows, cols);

        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());   

}




