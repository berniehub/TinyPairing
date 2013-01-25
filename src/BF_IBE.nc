/**
 *
 * This file provides interface for BF IBE BassicIdent, which is IND-ID-CPA secure
 * The version is the general version, in the way that all random numbers are represented and operated as large integers.
 * Conversions from and to trinary representation are needed.
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */
#include "crypto.h"

interface BF_IBE{
    
    /*
     * Setup
     */
    command void setup(Point* generator, BigInt mk, Point* pk);
    
    /*
     * Private key extration
     */
    command UInt keyextract(UInt* ID, uint32_t len, BigInt mk, Point* dID);
    
    /*
     * Encryption
     */
    command bool encrypt(Point* generator, Point* pk, UInt* msg, uint32_t len, UInt*ID, uint32_t idlen, Point* C0, UInt* C1);
    
    /*
     * Decryption
     */
    command bool decrypt(Point* dID, Point* C0, UInt* C1, uint32_t len, UInt* msg);
}