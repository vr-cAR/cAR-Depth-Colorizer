#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

#include <iostream>
#include <cstdio>

const float DMIN = 250;
const float DMAX = 8000;
// const float DMIN = 5.0 / 65535.0;
// const float DMAX = 10000.0 / 65535.0;
// const float DMIN = 0.3;
// const float DMAX = 16.0;

struct colorize_functor
{
    __host__ __device__
        int operator()(const short& depth) const { 
            // float disp = 1.0 / depth;
            // float disp_max = 1.0 / DMIN;
            // float disp_min = 1.0 / DMAX;
            // float dnormal = (disp - disp_min) / (disp_max - disp_min);
            float d = depth;
            if (depth < DMIN) d = DMIN;
            if (depth > DMAX) d = DMAX;

            // Gonna make it between 0-1 for now
            float dnormal = (d - DMIN) / (DMAX - DMIN) // * 1529;
            printf("Running with depth: %d normalized to %f\n", depth, dnormal);
            

            // return 0;
            // return depth;

            uint8_t pr = 50;
            // if ((0 <= dnormal && dnormal <= 255) || (1275 < dnormal && dnormal <= 1529)) {
            //     pr = 255;
            // } else if (255 < dnormal && dnormal <= 510) {
            //     pr = 255 - dnormal;
            // } else if ( 510 < dnormal && dnormal <= 1020) {
            //     pr = 0;
            // }
            // else if ( 1020 < dnormal && dnormal <= 1275) {
            //     pr = dnormal - 1020;
            // }
            // else {
            //     printf("pr not set with dnormal: %f\n", dnormal);
            // }

            uint8_t pg = 50;
            // if (0 < dnormal && dnormal <= 255) {
            //     pg = dnormal;
            // }
            // else if (255 < dnormal && dnormal <= 510) {
            //     pg = 255;
            // }
            // else if (510 < dnormal && dnormal <= 765) {
            //     pg = 765 - dnormal;
            // }
            // else if (765 < dnormal && dnormal < 1529) {
            //     pg = 0;
            // }
            // else {
            //     printf("pg not set with dnormal: %f\n", dnormal);
            // }

            uint8_t pb = 50;
            // if (0 < dnormal && dnormal <= 765) {
            //     pb = dnormal;
            // }
            // else if (765 < dnormal && dnormal <= 1020) {
            //     pb = 765 - dnormal;
            // }
            // else if (1020 < dnormal && dnormal <= 1275) {
            //     pb = 255;
            // }
            // else if (1275 < dnormal && dnormal <= 1529) {
            //     pb = 1529 - dnormal;
            // }
            // else {
            //     printf("pb not set with dnormal: %f\n", dnormal);
            // }
            // pr = 1;
            // pg = 2;
            // pb = 3;

            // RGBA
            int to_ret = 0;
            to_ret |= pr;
            to_ret <<= 8;
            to_ret |= pg;
            to_ret <<= 8;
            to_ret |= pb;
            to_ret <<= 8;
            to_ret |= 255;
            return to_ret;
        }
};


uint8_t* colorize(const uint16_t* input, size_t len) {
    // Depth 16 
    thrust::host_vector<short> h_input(len);
    for (int i = 0; i < len; i++) {
        h_input[i] = input[i];
    }
    std::cout << "input: " << h_input[0] << " " << h_input[1] << " " << h_input[2] << " " << h_input[3] << std::endl;
    thrust::device_vector<short> d_input(len);
    d_input = h_input;
    std::cout << "dinput: " << d_input[0] << " " << d_input[1] << " " << d_input[2] << " " << d_input[3] << std::endl;
    // Output RGBA
    thrust::device_vector<int> d_output(len);
    thrust::transform(d_input.begin(), d_input.end(), d_output.begin(), colorize_functor());
    std::cout << "doutput: " << d_output[0] << " " << d_output[1] << " " << d_output[2] << " " << d_output[3] << std::endl;
    thrust::host_vector<int> h_output(len);
    std::cout << "houtput: " << h_output[0] << " " << h_output[1] << " " << h_output[2] << " " << h_output[3] << std::endl;
    thrust::copy(d_output.begin(), d_output.end(), h_output.begin());

    int* output = new int[len * 4];
    for (int i = 0; i < len; i++) {
        output[i] = h_output[i];
    }
    return (uint8_t*)output;
}

int main() {
    uint16_t input[8] = { 100, 200, 400, 800, 1600, 3200, 6400, 12800 };
    uint8_t* output = colorize(input, 8);
    for (int i = 0; i < 8; i++) {
        std::cout << (int)output[i * 4] << " " << (int)output[i * 4 + 1] << " " << (int)output[i * 4 + 2] << " " << (int)output[i * 4 + 3] << std::endl;
    }
    return 0;
}