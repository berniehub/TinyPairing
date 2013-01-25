/**
 *
 * This file provides interface for BLS Short Signature
 * The version is the general version, in the way that all random numbers are represented and operated as large integers.
 * Conversions from and to trinary representation are needed.
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */

#include "crypto.h"

interface BB_SS{
    
    /*
     * Key generation
     */
    command void keygen(Point* g1, Point* g2, Point* u, Point* v, ExtElement2* z, BigInt x, BigInt y);
    
    /*
     * sign message
     */
    command bool sign(BigInt msg, Point* g1, BigInt x, BigInt y, BigInt r, CpElement sig);
    
    /*
     * signature verification
     */
    command int8_t verify(Point* g1, Point* g2, Point* u, Point* v, ExtElement2* z, BigInt msg, BigInt r, CpElement sig);
}

