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

interface BLS_SS{
    
    /*
     * Key generation
     */
    command void keygen(Point* genrator, Point* pk, BigInt sk);
    
    /*
     * sign message
     */
    command bool sign(UInt* msg, uint32_t len, BigInt sk, CpElement sig);
    
    /*
     * signature verification
     */
    command int8_t verify(Point* generator, Point* pk, UInt* msg, uint32_t len, CpElement sig);
}

