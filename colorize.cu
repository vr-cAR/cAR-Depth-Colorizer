#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

#include <iostream>
#include <cstdio>
#include <algorithm>
#include <math.h>

// const float DMIN = 250;
// const float DMAX = 8000;
// const float DMIN = 5.0 / 65535.0;
// const float DMAX = 10000.0 / 65535.0;
// const float DMIN = 0.3;
// const float DMAX = 16.0;

//JOFWJEFOIWEJF
typedef struct {
    double r;       // a fraction between 0 and 1
    double g;       // a fraction between 0 and 1
    double b;       // a fraction between 0 and 1
} rgb;

typedef struct {
    double h;       // angle in degrees
    double s;       // a fraction between 0 and 1
    double v;       // a fraction between 0 and 1
} hsv;

static hsv   rgb2hsv(rgb in);
static rgb   hsv2rgb(hsv in);




hsv rgb2hsv(rgb in)
{
    hsv         out;
    double      min, max, delta;

    min = in.r < in.g ? in.r : in.g;
    min = min  < in.b ? min  : in.b;

    max = in.r > in.g ? in.r : in.g;
    max = max  > in.b ? max  : in.b;

    out.v = max;                                // v
    delta = max - min;
    if (delta < 0.00001)
    {
        out.s = 0;
        out.h = 0; // undefined, maybe nan?
        return out;
    }
    if( max > 0.0 ) { // NOTE: if Max is == 0, this divide would cause a crash
        out.s = (delta / max);                  // s
    } else {
        // if max is 0, then r = g = b = 0              
        // s = 0, h is undefined
        out.s = 0.0;
        out.h = NAN;                            // its now undefined
        return out;
    }
    if( in.r >= max )                           // > is bogus, just keeps compilor happy
        out.h = ( in.g - in.b ) / delta;        // between yellow & magenta
    else
    if( in.g >= max )
        out.h = 2.0 + ( in.b - in.r ) / delta;  // between cyan & yellow
    else
        out.h = 4.0 + ( in.r - in.g ) / delta;  // between magenta & cyan

    out.h *= 60.0;                              // degrees

    if( out.h < 0.0 )
        out.h += 360.0;

    return out;
}
rgb hsv2rgb(hsv in)
{
    double      hh, p, q, t, ff;
    long        i;
    rgb         out;

    if(in.s <= 0.0) {       // < is bogus, just shuts up warnings
        out.r = in.v;
        out.g = in.v;
        out.b = in.v;
        return out;
    }
    hh = in.h;
    if(hh >= 360.0) hh = 0.0;
    hh /= 60.0;
    i = (long)hh;
    ff = hh - i;
    p = in.v * (1.0 - in.s);
    q = in.v * (1.0 - (in.s * ff));
    t = in.v * (1.0 - (in.s * (1.0 - ff)));

    switch(i) {
    case 0:
        out.r = in.v;
        out.g = t;
        out.b = p;
        break;
    case 1:
        out.r = q;
        out.g = in.v;
        out.b = p;
        break;
    case 2:
        out.r = p;
        out.g = in.v;
        out.b = t;
        break;

    case 3:
        out.r = p;
        out.g = q;
        out.b = in.v;
        break;
    case 4:
        out.r = t;
        out.g = p;
        out.b = in.v;
        break;
    case 5:
    default:
        out.r = in.v;
        out.g = p;
        out.b = q;
        break;
    }
    return out;     
}

struct colorize_functor
{
    const float DMIN;
    const float DMAX;
    colorize_functor(float DMIN, float DMAX) : DMIN(DMIN), DMAX(DMAX) {}

    __host__ __device__
        int operator()(const short& depth) const { 
            float d = depth;
            if (depth < DMIN) d = DMIN;
            if (depth > DMAX) d = DMAX;
            float disp = 1.0 / d;
            float disp_max = 1.0 / DMIN;
            float disp_min = 1.0 / DMAX;
            float dnormal = (disp - disp_min) / (disp_max - disp_min);
            int d_bins = dnormal * 1529;
            // float d = depth;
            // if (depth < DMIN) d = DMIN;
            // if (depth > DMAX) d = DMAX;

            // Gonna make it between 0-1 for now
            printf("Running with depth: %d normalized to %f\n", depth, dnormal);
            
            // Convert HSV to RGB
            // hsv in = {dnormal * 360, 1, 1};
            
            // double      hh, p, q, t, ff;
            // long        i;
            // rgb         out;

            // if(in.s <= 0.0) {       // < is bogus, just shuts up warnings
            //     out.r = in.v;
            //     out.g = in.v;
            //     out.b = in.v;
            //     return 0;
            // }
            // hh = in.h;
            // if(hh >= 360.0) hh = 0.0;
            // hh /= 60.0;
            // i = (long)hh;
            // ff = hh - i;
            // p = in.v * (1.0 - in.s);
            // q = in.v * (1.0 - (in.s * ff));
            // t = in.v * (1.0 - (in.s * (1.0 - ff)));

            // switch(i) {
            // case 0:
            //     out.r = in.v;
            //     out.g = t;
            //     out.b = p;
            //     break;
            // case 1:
            //     out.r = q;
            //     out.g = in.v;
            //     out.b = p;
            //     break;
            // case 2:
            //     out.r = p;
            //     out.g = in.v;
            //     out.b = t;
            //     break;

            // case 3:
            //     out.r = p;
            //     out.g = q;
            //     out.b = in.v;
            //     break;
            // case 4:
            //     out.r = t;
            //     out.g = p;
            //     out.b = in.v;
            //     break;
            // case 5:
            // default:
            //     out.r = in.v;
            //     out.g = p;
            //     out.b = q;
            //     break;
            // }
            // uint8_t derp = -1;
            // printf("derp: %d\n", derp);
            // uint8_t derp2 = 256;
            // printf("derp2: %d\n", derp2);
            // uint8_t derp3 = 256 +  256 + 12;
            // printf("derp3: %d\n", derp3);
            // return (int)(out.r * 255) << 16 | (int)(out.g * 255) << 8 | (int)(out.b * 255);
            
            // My sus implementation
            // float H = dnormal * 360;
            
            // float S = 1;
            // float V = 1;
            // float M = 255 * V;
            // float m = M * (1 - S);
            // float z = (M - m) * abs(H / 60 - (int)(H / 60) + ((int)(H / 60) % 2) - 1);
            
            // int to_ret;
            // if (H < 60) {
            //     to_ret = (int)M << 16 | (int)(z + m) << 8 | (int)m;
            // } else if (H < 120) {
            //     to_ret = (int)(z + m) << 16 | (int)M << 8 | (int)m;
            // } else if (H < 180) {
            //     to_ret = (int)m << 16 | (int)M << 8 | (int)(z + m);
            // } else if (H < 240) {
            //     to_ret = (int)m << 16 | (int)(z+m) << 8 | (int)M;
            // } else if (H < 300) {
            //     to_ret = (int)(z + m) << 16 | (int)m << 8 | (int)M;
            // } else {
            //     to_ret = (int)M << 16 | (int)m << 8 | (int)(z + m);
            // }
            // printf("depth %d is mapped to hue: %f\n", depth, hsv.h);
            
            // return 0;
            // return depth;
            // return to_ret;

            int32_t pr = 0;
            if ((0 <= d_bins && d_bins <= 255) || (1275 < d_bins && d_bins <= 1529)) {
                pr = 255;
            } else if (255 < d_bins && d_bins <= 510) {
                pr = 255 - d_bins;
            } else if ( 510 < d_bins && d_bins<= 1020) {
                pr = 0;
            }
            else if ( 1020 < d_bins && d_bins <= 1275) {
                pr = d_bins - 1020;
            }
            else {
                printf("pr not set with d_bins: %d\n", d_bins);
            }

            int32_t pg = 50;
            if (0 <= d_bins && d_bins <= 255) {
                pg = d_bins;
            }
            else if (255 < d_bins && d_bins <= 510) {
                pg = 255;
            }
            else if (510 < d_bins && d_bins <= 765) {
                pg = 765 - d_bins;
            }
            else if (765 < d_bins && d_bins <= 1529) {
                pg = 0;
            }
            else {
                printf("pg not set with d_bins: %d\n", d_bins);
            }

            int32_t pb = 50;
            if (0 <= d_bins && d_bins <= 765) {
                pb = d_bins;
            }
            else if (765 < d_bins && d_bins <= 1020) {
                pb = 765 - d_bins;
            }
            else if (1020 < d_bins && d_bins <= 1275) {
                pb = 255;
            }
            else if (1275 < d_bins && d_bins <= 1529) {
                pb = 1529 - d_bins;
            }
            else {
                printf("pb not set with d_bins: %d\n", d_bins);
            }
            return (pr & 0xFF) << 16 | (pg & 0xFF) << 8 | (pb & 0xFF);
            // pr = 1;
            // pg = 2;
            // pb = 3;

            // RGBA
            // int to_ret = 0;
            // to_ret |= pr;
            // to_ret <<= 8;
            // to_ret |= pg;
            // to_ret <<= 8;
            // to_ret |= pb;
            // to_ret <<= 8;
            // to_ret |= 255;
            // return to_ret;
        }

};


int* colorize(const uint16_t* input, size_t len, float dmin, float dmax) {
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
    thrust::transform(d_input.begin(), d_input.end(), d_output.begin(), colorize_functor(dmin, dmax));
    std::cout << "doutput: " << d_output[0] << " " << d_output[1] << " " << d_output[2] << " " << d_output[3] << std::endl;
    thrust::host_vector<int> h_output(len);
    std::cout << "houtput: " << h_output[0] << " " << h_output[1] << " " << h_output[2] << " " << h_output[3] << std::endl;
    thrust::copy(d_output.begin(), d_output.end(), h_output.begin());

    int* output = new int[len];
    for (int i = 0; i < len; i++) {
        output[i] = h_output[i];
    }
    return output;
}





uint16_t to_depth(int rgb_int) {
    // Not sure if the orders are right
    uint8_t r = (rgb_int >> 16) & 0xFF;
    uint8_t g = (rgb_int >> 8) & 0xFF;
    uint8_t b = rgb_int & 0xFF;

    rgb in = {r / 255.0, g / 255.0, b / 255.0};
    hsv out = rgb2hsv(in);
    float H_norm = out.h / 360;

    // uint8_t M = std::max(r, std::max(g, b));
    // uint8_t m = std::min(r, std::min(g, b));

    // // float V = M / 255.0;
    // // float S = 0;
    // // if (M > 0) {
    // //     S = (M - m) / (float)M;
    // // }
    // float H = 0;
    // if (r >= b) {
    //     H = acos((r - 0.5 * g - 0.5 * b) / sqrt(r * r + g * g + b * b - r * g - r * b - g * b));
    // }
    // else {
    //     H = 360 - acos((r - 0.5 * g - 0.5 * b) / sqrt(r * r + g * g + b * b - r * g - r * b - g * b));
    // }
    // float H_norm = H / 360;
    printf("r:%d, g:%d, b:%d -> H_norm: %f\n",r,g,b, H_norm);
    return 0; // UNUSED
    // return DMIN + (DMAX - DMIN) * H_norm;
}

uint16_t to_depth_paper(int rgb_int, float dmin, float dmax) {
    int r = (rgb_int >> 16) & 0xFF;
    int g = (rgb_int >> 8) & 0xFF;
    int b = rgb_int & 0xFF;
    int drnormal;
    if (r >= g && r >= b && g >= b) {
        drnormal = g - b;
    }
    else if (r >= g && r >= b && g < b) {
        drnormal = g - b + 1529;
    }
    else if (g >= r && g >= b) {
        drnormal = b - r + 510;
    }
    else if (b >= g && b >= r){
        drnormal = r - g + 1020;
    }
    else {
        printf("OIWEJFOIJWEOFIEJWOJ Bad color: %d, %d, %d", r, g, b);
    }
    float disp_min = 1/dmax;
    float disp_max = 1/dmin;
    float recovered_depth = 1529.0 / (1529.0 * disp_min + (disp_max - disp_min) * drnormal);

    return recovered_depth;
}

uint8_t* exported_colorize(uint8_t* depth_buf, uint32_t depth_buf_len, float dmin, float dmax) {
    return (uint8_t*)colorize((uint16_t*)depth_buf, depth_buf_len / 2, dmin, dmax);
}

uint8_t* test(uint8_t* arr, uint32_t len) {
    for (int i = 0; i < len; i++) {
        std::cout << (int)arr[i] << std::endl;
        arr[i] += 1;
    }
    return arr;
}

int main() {
    uint16_t input[8] = {300, 301, 302, 310, 500, 1000, 6400, 12800 };
    float dmin = 250;
    float dmax = 5000;
    int* output = colorize(input, 8, dmin, dmax);
    for (int i = 0; i < 8; i++) {
        std::cout << "r:" << (output[i] >> 16 & 0xFF) << " g:" << (output[i] >> 8 & 0xFF) << " b:" << (output[i] & 0xFF) << std::endl;
    }
    // Convert back to depth
    for (int i = 0; i < 8; i++) {
        std::cout << to_depth_paper(output[i], dmin, dmax) << std::endl;
    }
    return 0;
}