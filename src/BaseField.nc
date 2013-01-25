/**
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Oct, 2008
 */

#include "crypto.h"

interface BaseField{
    
    /*
     * Add two elements A and B in base filed GF(3^97)
     * *C = *A + *B
     */
    command void add(Element* A, Element *B, Element *C);
    
    /*
     * A substitue B in GF(3^97)
     * *C = *A - *B
     */
    command void sub(Element* A, Element *B, Element *C);
    
    /*
     * A multiply B in GF(3^97)
     * *C = *A * *B mod F(x)
     */
    command void mult(Element* A, Element *B, Element *C);
    
    /*
     * Compute cube of A in GF(3^97)
     * *B = *A^3
     */
    command void cube(Element* A, Element *B);
    
    /*
     * Compute inverse of A in GF(3^97)
     * *B = *A^(-1) mod F(x)
     * retrun 0 if A is 0.
     */
    command UInt inver(Element* A, Element *B);
    
    /*
     * compute opposite value of A
     * *B = -(*A)
     */
    command void neg(Element *A, Element *B);
    
    /*
     * Base Conversion function
     * Compress an Element in base 3 to an array in base 2
     */
    command void cps(Element *E, CpElement cpElement);
    
    /*
     * Convert in inverse order
     * An array in base 2 is converted to an Element in base 3
     */
    command void dcps(CpElement cpElement, Element *E);
    
    //command void private_byte_int2elmt(UInt* hi, UInt* lo, UInt num);
    //command void private_byte_elmt2int(UInt* num, UInt* hi, UInt* lo);
    
}
