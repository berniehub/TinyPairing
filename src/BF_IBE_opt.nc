/**
 *
 * This ile provides interface for BF IBE BassicIdent, which is IND-ID-CPA secure
 * The version is what we called opt version, in the way that all random numbers are represented and operated in field of characteristic three
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */
#include "crypto.h"

interface BF_IBE_opt{
    
    /*
     * Setup
     */
    command void setup(Point* generator, Element* mk, Point* pk);
    
    /*
     * Private key extration
     */
    command UInt keyextract(UInt* ID, uint32_t len, Element* mk, Point* dID);
    
    /*
     * Encryption
     */
    command bool encrypt(Point* generator, Point* pk, UInt* msg, uint32_t len, UInt*ID, uint32_t idlen, Point* C0, UInt* C1);
    
    /*
     * Decryption
     */
    command bool decrypt(Point* dID, Point* C0, UInt* C1, uint32_t len, UInt* msg);
}