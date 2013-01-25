/**
 *
 * This file provides interface for BLS Short Signature
 * The version is what we called opt version, in the way that all random numbers are represented and operated in field of characteristic three
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */

#include "crypto.h"

interface BLS_SS_opt{
    
    /*
     * Key generation
     */
    command void keygen(Point* genrator, Point* pk, Element* sk);
    
    /*
     * sign message
     */
    command bool sign(UInt* msg, uint32_t len, Element* sk, CpElement sig);
    
    /*
     * signature verification
     */
    command int8_t verify(Point* generator, Point* pk, UInt* msg, uint32_t len, CpElement sig);
}

