/**
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Oct, 2008
 */

#include "crypto.h"

interface ExtField2{
    
    /*
     * Add two elements A and B in extension filed GF(3^97^6)
     * *C = *A + *B
     */
    //command void add(ExtElement* A, ExtElement *B, ExtElement *C);
    
    /*
     * A multiply B in GF(3^97^6)
     * *C = *A * *B mod F(x)
     */
    command void mult(ExtElement2* A, ExtElement2* B, ExtElement2* C);
    
    /*
     * Compute cube of A in GF(3^97^6)
     * *B = *A^3
     */
    command void cube(ExtElement2* A, ExtElement2* B);
    
    /*
     * Compute inverse of A in GF(3^97^6)
     * *B = *A^(-1)
     */
    command void inver(ExtElement2* A, ExtElement2* B);
    
    //middle filed for final exponation
    command void mid_neg_element(MidElement2 *A, MidElement2 *B);
    command void mid_inver_element(MidElement2 *A, MidElement2 *B);
    command void mid_mult_element(MidElement2 *A, MidElement2 *B, MidElement2 *C);
    command void mid_sub_element(MidElement2 *a, MidElement2 *b, MidElement2 *c);
    command void mid_add_element(MidElement2 *a, MidElement2 *b, MidElement2 *c);
    command void mid_cube_element(MidElement2 *A, MidElement2 *B);
}
