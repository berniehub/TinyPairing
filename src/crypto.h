/**
 * Authors: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Sep, 2008
 */
#ifndef _CRYPTO_H_
#define _CRYPTO_H_

#include "sha1.h"

enum{
    // GF(3^CONSTANT_M)
    CONSTANT_M = 97,
    UINT_LEN = 8,
    UINT_MSB = 0x80,
    // (CONSTANT_M-1)/uint8_t + 1
    ELEMENT_LEN = 13,
    CPELEMENT_LEN = 20,
    // position of the non-zero term of the GF(3^m) irreducible polynomial F(x)
    //F(x) = x^97 + x^12 + 2
    VALUE_K = 12,
    //The maximum times tried to hash the (i+message) to the point
    HASH_BOUND = 8,
    //Chosn on the consideration of group order
    BIGINT_LEN = 19
};


typedef struct Element {
    uint8_t hi[ELEMENT_LEN];
    uint8_t lo[ELEMENT_LEN];
} Element;

typedef struct MidElement2{
    Element mid[3];
}MidElement2;

typedef struct ExtElement2{
    MidElement2 ext[2];
}ExtElement2;

typedef struct Point{
    Element x;
    Element y;
}Point;

typedef struct Point_proj{
    Element x;
    Element y;
    Element z;
}Point_proj;

static Element ELEMENT_ONE = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
    {1,0,0,0,0,0,0,0,0,0,0,0,0}};
static Element ELEMENT_ZERO = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0}};
static Point ZERO_POINT={{{0,0,0,0, 0,0,0,0,0,0XFF,0xFF,0xFF, 0x1},
    {0,0,0,0, 0,0,0,0, 0,0,0,0, 0}},
    {{0,0,0,0, 0,0,0,0, 0,0,0,0, 0},
        {0,0,0,0 ,0,0,0,0, 0,0,0,0, 0}}};
//generator point
static Point g0 = {{{0x0D,0x84,0xC0,0x12,0x50,0x11,0xA0,0x01,0x80,0xE1,0xE8,0xD4,0x1},
    {0x52,0x30,0x12,0x01,0xA4,0x6A,0x07,0x72,0x5B,0x1C,0x13,0x22,0x0}},
    {{0xC0,0x00,0x08,0x61,0x75,0x15,0x8A,0x10,0x56,0x00,0x04,0x41,0x01},
        {0x34,0xAD,0xD1,0x0E,0x80,0x60,0x54,0xAD,0x08,0x65,0x62,0x2C,0x00}}};
typedef uint8_t UInt;

typedef UInt CpElement[CPELEMENT_LEN];


//big integer
typedef UInt BigInt[BIGINT_LEN];

/*
 * The order of elliptic curve group we used is #E/7
 * HEX 7A46E0901F72546F8D3EBA717E08644135DE41
 * DEC 2726865189058261010774960798134976187171462721
 */

static BigInt GORDER =  {0x41, 0xDE, 0x35, 0x41, 0x64,
    0x08, 0x7E, 0x71, 0xBA, 0x3E,
    0x8D, 0x6F, 0x54, 0x72, 0x1F,
    0x90, 0xE0, 0x46, 0x7A};
/* byte are in the inverse allignment
 static BigInt GORDER2 =  {0x7A,0x46,0xE0,0x90,
 0x1F,0x72,0x54,0x6F,0x8D,
 0x3E,0xBA,0x71,0x7E,0x08,
 0x64,0x41,0x35,0xDE,0x41};
 */

#endif
