/**
 * All new code in this distribution is Copyright 2005 by North Carolina
 * State University. All rights reserved. Redistribution and use in
 * source and binary forms are permitted provided that this entire
 * copyright notice is duplicated in all such copies, and that any
 * documentation, announcements, and other materials related to such
 * distribution and use acknowledge that the software was developed at
 * North Carolina State University, Raleigh, NC. No charge may be made
 * for copies, derivations, or distributions of this material without the
 * express written consent of the copyright holder. Neither the name of
 * the University nor the name of the author may be used to endorse or
 * promote products derived from this material without specific prior
 * written permission.
 *
 * IN NO EVENT SHALL THE NORTH CAROLINA STATE UNIVERSITY BE LIABLE TO ANY
 * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF THE NORTH CAROLINA STATE UNIVERSITY HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN
 * "AS IS" BASIS, AND THE NORTH CAROLINA STATE UNIVERSITY HAS NO
 * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS. "
 *
 */

/**
 * Interface NN
 * Provide the functions of big Natural Numbers.
 *
 * Author: An Liu
 * Date: 09/29/2006
 */

#include "NN.h"

interface NN {
    
    /*
     CONVERSIONS
     Decode (a, digits, b, len)   Decodes character string b into a.
     Encode (a, len, b, digits)   Encodes a into character string b.
     
     ASSIGNMENTS
     Assign (a, b, digits)        Assigns a = b.
     ASSIGN_DIGIT (a, b, digits)  Assigns a = b, where b is a digit.
     AssignZero (a, digits)    Assigns a = 0.
     Assign2Exp (a, b, digits)    Assigns a = 2^b.
     
     ARITHMETIC OPERATIONS
     Add (a, b, c, digits)        Computes a = b + c.
     Sub (a, b, c, digits)        Computes a = b - c.
     Mult (a, b, c, digits)       Computes a = b * c.
     LShift (a, b, c, digits)     Computes a = b * 2^c.
     RShift (a, b, c, digits)     Computes a = b / 2^c.
     Div (a, b, c, cDigits, d, dDigits)  Computes a = c div d and b = c mod d.
     
     NUMBER THEORY
     Mod (a, b, bDigits, c, cDigits)  Computes a = b mod c.
     ModMult (a, b, c, d, digits) Computes a = b * c mod d.
     ModExp (a, b, c, cDigits, d, dDigits)  Computes a = b^c mod d.
     ModInv (a, b, c, digits)     Computes a = 1/b mod c.
     Gcd (a, b, c, digits)        Computes a = gcd (b, c).
     
     OTHER OPERATIONS
     EVEN (a, digits)             Returns 1 iff a is even.
     Cmp (a, b, digits)           Returns sign of a - b.
     EQUAL (a, digits)            Returns 1 iff a = b.
     Zero (a, digits)             Returns 1 iff a = 0.
     Digits (a, digits)           Returns significant length of a in digits.
     Bits (a, digits)             Returns significant length of a in bits.
     */
    
    /* CONVERSIONS */
    
    //Decodes character string b into a.
    command void Decode(NN_DIGIT * a, NN_UINT digits, unsigned char * b, NN_UINT len);
    //Encodes a into character string b.
    command void Encode(unsigned char * a, NN_UINT digits, NN_DIGIT * b, NN_UINT len);
    
    /* ASSIGNMENT */
    //Assigns a = b.
    command void Assign(NN_DIGIT * a, NN_DIGIT * b, NN_UINT digits);
    //Assigns a = b, where b is a digit.
    command void AssignDigit(NN_DIGIT * a, NN_DIGIT b, NN_UINT digits);
    //Assigns a = 0.
    command void AssignZero(NN_DIGIT * a, NN_UINT digits);
    //Assigns a = 2^b.
    command void Assign2Exp(NN_DIGIT * a, NN_UINT2 b, NN_UINT digits);
    
    /* ARITHMETIC OPERATIONS */
    //Computes a = b + c.
    command NN_DIGIT Add(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_UINT digits);
    //Computes a = b - c.
    command NN_DIGIT Sub(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_UINT digits);
    //Computes a = b * c.
    command void Mult(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_UINT digits);
    //Computes a = c div d and b = c mod d.
    command void Div(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_UINT cDigits, NN_DIGIT * d, NN_UINT dDigits);
    //Computes a = b * 2^c.
    command NN_DIGIT LShift(NN_DIGIT * a, NN_DIGIT * b, NN_UINT c, NN_UINT digits);
    //Computes a = b / 2^c.
    command NN_DIGIT RShift(NN_DIGIT * a, NN_DIGIT * b, NN_UINT c, NN_UINT digits);
    //Computes a = b + c*d, where c is a digit
    command NN_DIGIT AddDigitMult (NN_DIGIT *a, NN_DIGIT *b, NN_DIGIT c, NN_DIGIT *d, NN_UINT digits);
    
    /* NUMBER THEORY */
    //Computes a = b mod c.
    command void Mod(NN_DIGIT * a, NN_DIGIT * b, NN_UINT bDigits, NN_DIGIT * c, NN_UINT cDigits);
    //Computes b = b mod c, suppose the b is just one bit longer than c
    command void ModSmall(NN_DIGIT * b, NN_DIGIT * c, NN_UINT digits);
    //Computes a = (b + c) mod d
    command void ModAdd(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_DIGIT * d, NN_UINT digits);
    //Computes a = (b - c) mod d
    command void ModSub(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_DIGIT * d, NN_UINT digits);
    //Computes a = (b * c) mod d.
    command void ModMult(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_DIGIT * d, NN_UINT digits);
    //Computes a = (b * c) mod d, for d is generalized mersenne number, d = 2^m - omega
    //command void ModMultOpt(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_DIGIT * d, NN_DIGIT * omega, NN_UINT digits);
    //Computes a = b^2 mod d
    command void ModSqr(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * d, NN_UINT digits);
    //Computes a = b^2 mod d
    //command void ModSqrOpt(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * d, NN_DIGIT * omega, NN_UINT digits);
    //Computes a = b^c mod d.
    command void ModExp(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_UINT cDigits, NN_DIGIT * d, NN_UINT dDigits);
    //Computes a = 1/b mod c.
    command void ModInv(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_UINT digits);
    //Computes a = gcd (b, c).
    command void Gcd(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, NN_UINT digits);
    
    //command void ModDivOpt(NN_DIGIT * a, NN_DIGIT * b, NN_DIGIT * c, );
    
    /* OTHER OPERATIONS */
    //Returns sign of a - b.
    command int Cmp(NN_DIGIT * a, NN_DIGIT * b, NN_UINT digits);
    //Returns 1 iff a = 0.
    command int Zero(NN_DIGIT * a, NN_UINT digits);
    //Returns 1 iff a = 1.
    command int One(NN_DIGIT * a, NN_UINT digits);
    //Returns significant length of a in bits.
    command unsigned int Bits(NN_DIGIT * a, NN_UINT digits);
    //Returns significant length of a in digits.
    command unsigned int Digits(NN_DIGIT * a, NN_UINT digits);
    //Returns 1 iff a = b.
    command int Equal(NN_DIGIT * a, NN_DIGIT * b, NN_UINT digits);
    //Returns 1 iff a is even.
    command int Even(NN_DIGIT * a, NN_UINT digits);
    
    
}
