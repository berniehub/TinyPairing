/**
 * Authors: Xiaokang Xiong (xkxiong@cityu.edu.hk)
 * Date: Oct, 2008
 *
 *
 * This file handles operations in base field that elliptic curve is constructed on
 * The field is GF(3^97)
 * Opearations includes add, sub, multiply, which are prefixed with "asyn"
 *
 * Use enum to declare all constant values, such that not RAM or Program Memeory would be used.
 * But not use enum for variables declarations, since enum defaults to interger width.
 *
 * Be noted that, currently we focus on cutting memory footprint we used for pairing implementation
 * Thus some functions in this file may be used exclusively for Field 3&97
 *
 * The reduction and cube routines implemented in this file do not use pre-computed table
 * Although they are extensively used in the pairing calulcation,
 */

#include "crypto.h"

module BaseFieldM{
    
    provides interface BaseField;
}

implementation{
    
    /**
     * Pre-allocate a set of binary strings for storing intermediate results.
     * The purpose is to reduce the number of dynamAically created variables which
     * will result in reducing the stack operations and enhancing the performance
     * of the program.
     *
     * Use with care and used only internally. A rule of thumb when using these
     * variables is that always finish using them within a single routine. We
     * should also pay special attention when the routine needs to call some other
     * routines in which these temporary binary strings may also be used.
     */
    //For private_element_add function use only
    //The function can not recusively call itself
    //  UInt temp_padd[ELEMENT_LEN+1];
    
    //For mult function use only
    //The function can not recusively call itself
    //  UInt temp_mult[2][ELEMENT_LEN+1];
    //  UInt longtemp_mult[2][2*ELEMENT_LEN];
    
    //  UInt i, j, k; //which should not exceed 256
    //  UInt ui, uj, uk;
    
    /*
     * This functin has limited application that element_len should not exceed 255
     *
     * More ROM, but the same RAM compared with not using "#define"
     *
     * Be noted that, if this routine is used for substruction, i.e. b.hi is exchanged with b.lo
     * we could be careful that b point to the same memory location as c.
     */
    #define private_element_add(ahi,alo,bhi,blo,digits,chi,clo) \
    { \
        UInt ti; \
        UInt temp_padd[ELEMENT_LEN+1]; \
        for(ti=0; ti<digits; ti++) { \
            temp_padd[ti] = ((*((ahi)+ti)) | (*((alo)+ti))) & ((*((bhi)+ti)) | (*((blo)+ti))); \
            (*((chi)+ti)) = ((*((ahi)+ti)) | (*((bhi)+ti))) ^ temp_padd[ti]; \
            (*((clo)+ti)) = ((*((alo)+ti)) | (*((blo)+ti))) ^ temp_padd[ti]; \
        } \
    }
    /*
     void private_element_add(UInt *ahi, UInt *alo, UInt *bhi, UInt *blo,
     UInt digits, UInt *chi, UInt *clo) {
     UInt ti;
     UInt temp_padd[ELEMENT_LEN+1];
     for(ti=0; ti<digits; ti++) {
     temp_padd[ti] = ((*((ahi)+ti)) | (*((alo)+ti))) & ((*((bhi)+ti)) | (*((blo)+ti)));
     (*((chi)+ti)) = temp_padd[ti] ^ ((*((ahi)+ti)) | (*((bhi)+ti)));
     (*((clo)+ti)) = temp_padd[ti] ^ ((*((alo)+ti)) | (*((blo)+ti)));
     }
     }
     */
    
    /*
     * For Inverse function use
     * Compute the degree of element *a, and writes the degree to *degree.
     * The definition of degree is the value of most significant non-zero bit of an element
     *
     * Be noted that degree should not exceed 255
     */
    void private_element_deg(Element *a, UInt *degree){
        UInt i = (UInt)(ELEMENT_LEN - 1);
        *degree = 0;
        if((a->hi[i]==1) || (a->lo[i]==1)){
            *degree = (UInt)(CONSTANT_M - 1); //96
        }else{
            i--;
            while((a->hi[i]==0)&&(a->lo[i]==0)){
                i--;
            }
            *degree = (UInt)(i*UINT_LEN);
            i = UINT_LEN - 1;
            while( ((a->hi[(*degree)/UINT_LEN]>>i)==0) && ((a->lo[(*degree)/UINT_LEN]>>i)==0) ){
                i--;
            }
            *degree += i;
        }
    }
    
    /*
     * For inverse funtioin use
     * Shift the element *a to the left with len bits, and writes the value to Element *b.
     * Use to calculate x^len.
     */
    void private_element_shift(UInt *ahi, UInt *alo, UInt *bhi, UInt *blo, UInt eLen, UInt shift){
        UInt byte_shift;
        UInt bit_shift;
        int8_t i;
        byte_shift = (UInt) (shift/(UInt)UINT_LEN);
        bit_shift = (UInt) (shift %(UInt)UINT_LEN);
        for(i=0; i<(eLen-byte_shift); i++){
            bhi[eLen-1-i] = ahi[eLen-1-byte_shift-i];
            blo[eLen-1-i] = alo[eLen-1-byte_shift-i];
        }
        for(i=0; i<byte_shift; i++){
            bhi[i] = 0;
            blo[i] = 0;
        }
        
        bhi[eLen-1] = bhi[eLen - 1]<<bit_shift;
        blo[eLen-1] = blo[eLen - 1]<<bit_shift;
        if(bit_shift!=0){
            for(i= (eLen - 2); i>=0; i--){
                bhi[i+1] = ((bhi[i]>>(UINT_LEN-bit_shift) | bhi[i+1]));
                blo[i+1] = ((blo[i]>>(UINT_LEN-bit_shift) | blo[i+1]));
                bhi[i] = bhi[i]<<bit_shift;
                blo[i] = blo[i]<<bit_shift;
            }
        }
    }
    
    void private_void_byte_cube(UInt* a, UInt* c){
        static UInt ct0[8] = {0x0,0x1,0x8,0x9,0x40,0x41,0x48,0x49};
        static UInt ct1[8] = {0x0,0x2,0x10,0x12,0x80,0x82,0x90,0x92};
        static UInt ct2[4] = {0x0,0x4,0x20,0x24};
        *c = ct0[((*a) & 0x07)];
        *(c+1) = ct1[((*a) >>3) & 0x07];
        *(c+2) = ct2[((*a) >>6)];
    }
    
    /*Num should range from 0 to 242*/
    void private_byte_int2elmt(UInt num, UInt* hi, UInt* lo){
        UInt modulus;
        UInt orvalue;
        int8_t i;
        
        *hi = 0x0;
        *lo = 0x0;
        orvalue = 0x10;
        modulus = 81;
        
        /* Compute element from highest bit to lowest one
         * i.e. from 5th bit to 1st bit
         */
        for(i=5; i>0; i--)
        {
            if(num >= (modulus<<1)){
                *hi |= orvalue;
            }else if(num >= modulus){
                *lo |= orvalue;
            }
            
            if(i>1){
                num = num %modulus;
                modulus /= 3;
                orvalue >>= 1;
            }
        }
    }
    
    void private_byte_elmt2int(UInt hi, UInt lo, UInt* num){
        int8_t i;
        UInt adder;
        UInt andvalue;
        
        *num = 0;
        adder = 1;
        andvalue = 0x1;
        /*Compute from low bit to high bit
         * If ith bit is not zero, add 3^i to the num
         */
        for(i=0; i<5; i++){
            if(hi & andvalue){
                *num += adder*2;
            }else if(lo & andvalue){
                *num += adder;
            }
            
            if(i!=4){
                andvalue <<= 1;
                adder *=3;
            }
        }
    }
    
    
    
    /*
     * C(x) := A(x) + B(x) in GF(3^m)
     *
     * This routine allows C(x) to be A(x) or B(x).
     */
    command void BaseField.add(Element* A, Element* B, Element* C) {
        private_element_add(A->hi, A->lo, B->hi, B->lo, ELEMENT_LEN, C->hi, C->lo);
    }
    
    /*
     * C(x) := A(x) - B(x) := A(x) + (-B(x)) in GF(3^m)
     *
     * Note: in GF(3^m), if B(x) = (hi, lo), then -B(x) = (lo, hi).
     * Hence -B(x) is simply the "bitwise swapping" between HIGH bits and
     * the LOW bits.
     *
     * As of Addition in GF(3^m), this Subtraction routine also allows C(x) to be
     * A(x) or B(x).
     */
    command void BaseField.sub(Element *A, Element *B, Element *C) {
        /*
         * here we copy the value of Hi in B to a temp data struct,
         * such that C could be the same as B when using this fuction
         */
        uint8_t thi[ELEMENT_LEN];
        memcpy(thi, B->hi, ELEMENT_LEN);
        private_element_add(A->hi, A->lo, B->lo, thi, ELEMENT_LEN, C->hi, C->lo);
    }
    
    /*
     * C(x) := A(x) * B(x) in GF(3^m)
     *
     * This routine allows C(x) to be A(x) or B(x).
     */
    command void BaseField.mult(Element* A, Element *B, Element *C) {
        UInt j;
        int8_t k;
        UInt uk,res;
        UInt temp_mult[8][ELEMENT_LEN];
        UInt longtemp_mult[2][2*ELEMENT_LEN];
        
        
        //precomputation for "10", stored in temp_mulit[0,1]
        for(j=(ELEMENT_LEN-1); j>0; j--) {
            temp_mult[0][j] = B->hi[j] << 1;
            temp_mult[0][j] |= B->hi[j-1]>>(UINT_LEN-1);
            temp_mult[1][j] = B->lo[j] << 1;
            temp_mult[1][j] |= B->lo[j-1]>>(UINT_LEN-1);
        }
        temp_mult[0][0] = B->hi[0] << 1;
        temp_mult[1][0] = B->lo[0] << 1;
        
        //precomputation for "11", stored in temp_mulit[2,3]
        private_element_add(temp_mult[0], temp_mult[1],
                            B->hi, B->lo, ELEMENT_LEN,
                            temp_mult[2], temp_mult[3]);
        
        //precomputation for "12", stored in temp_mulit[4,5]
        private_element_add(temp_mult[0], temp_mult[1],
                            B->lo, B->hi, ELEMENT_LEN,
                            temp_mult[4], temp_mult[5]);
        
        //"01" is B
        memcpy(temp_mult[6], B->hi, ELEMENT_LEN);
        memcpy(temp_mult[7], B->lo, ELEMENT_LEN);
        memset(longtemp_mult,0,sizeof(longtemp_mult));
        
        //Step 1: multiplication
        //Left-right comb multiplication method
        for(k=6; k>=0; k=k-2) {
            for(j=0;j<ELEMENT_LEN;j++) {
                uk = (((A->hi[j])>>k)&0x3)<<2;
                uk |= ((A->lo[j])>>k)&0x3;
                switch(uk)
                {
                    case 1: //01
                        uk=6;
                        break;
                    case 4: //02
                        uk=7;
                        break;
                    case 2: //10 stored in temp[0,1]
                        uk=0;
                        break;
                    case 3: //11 stored in temp[2,3]
                        uk=2;
                        break;
                    case 6: //12 stored in temp[4,5]
                        uk=4;
                        break;
                    case 8: //20
                        uk=1;
                        break;
                    case 9: //21
                        uk=5;
                        break;
                    case 12: //22
                        uk=3;
                        break;
                    default:
                        uk=8;
                        break;
                }
                if(uk!=8){
                    if(uk%2==0)
                        res=uk+1;
                    else
                        res=uk-1;
                    private_element_add(longtemp_mult[0]+j, longtemp_mult[1]+j,
                                        temp_mult[uk], temp_mult[res], ELEMENT_LEN,
                                        longtemp_mult[0]+j, longtemp_mult[1]+j);
                }
            }
            if(k != 0) {
                for(j=(2*ELEMENT_LEN-1); j>0; j--) {
                    longtemp_mult[0][j] <<= 2;
                    longtemp_mult[0][j] |= longtemp_mult[0][j-1]>>(UINT_LEN-2);
                    longtemp_mult[1][j] <<= 2;
                    longtemp_mult[1][j] |= longtemp_mult[1][j-1]>>(UINT_LEN-2);
                }
                longtemp_mult[0][0] <<= 2;
                longtemp_mult[1][0] <<= 2;
            }
        }
        
        //Step 2: reduction
        //we do faster reduction here
        
        //shift bits 97 to 192 and add to c0 to c95
        private_element_shift(longtemp_mult[0]+12, longtemp_mult[1]+12,
                              temp_mult[0], temp_mult[1], ELEMENT_LEN, 7);
        private_element_add(longtemp_mult[0], longtemp_mult[1],
                            temp_mult[0]+1, temp_mult[1]+1, ELEMENT_LEN-1, C->hi, C->lo);
        
        //shift bits 97 to 180 and minus to c12 to c95
        private_element_shift(longtemp_mult[0]+12, longtemp_mult[1]+12,
                              temp_mult[0], temp_mult[1], ELEMENT_LEN-2, 3);
        temp_mult[0][0] &= 0xF0;
        temp_mult[1][0] &= 0xF0;
        //substraction here
        private_element_add(C->hi + 1, C->lo + 1,
                            temp_mult[1], temp_mult[0], ELEMENT_LEN-2, C->hi+1, C->lo+1);
        
        //shift bits 182 to 192 and add to c0 to c10
        private_element_shift(longtemp_mult[0]+22, longtemp_mult[1]+22,
                              temp_mult[0], temp_mult[1], 3, 2);
        temp_mult[0][2] &= 0x07;
        temp_mult[1][2] &= 0x07;
        //substration here
        private_element_add(C->hi, C->lo,
                            temp_mult[1]+1, temp_mult[0]+1, 2, C->hi, C->lo);
        
        //shift bits 182 to 192 and add to c12 to c22
        private_element_shift(longtemp_mult[0]+22, longtemp_mult[1]+22,
                              temp_mult[0], temp_mult[1], 3, 6);
        temp_mult[0][1] &= 0xF0;
        temp_mult[1][1] &= 0xF0;
        temp_mult[0][2] &= 0x7F;
        temp_mult[1][2] &= 0x7F;
        private_element_add(C->hi + 1, C->lo + 1,
                            temp_mult[0]+1, temp_mult[1]+1, 2, C->hi + 1, C->lo + 1);
        
        //bit c96 = c96 - c181
        temp_mult[0][0] = (longtemp_mult[0][22]>>5) & 0x01;
        temp_mult[1][0] = (longtemp_mult[1][22]>>5) & 0x01;
        temp_mult[0][1] = longtemp_mult[0][12] & 0x01;
        temp_mult[1][1] = longtemp_mult[1][12] & 0x01;
        private_element_add(temp_mult[0]+1, temp_mult[1]+1,
                            temp_mult[1], temp_mult[0], 1, C->hi+12, C->lo+12);
        
    }//end BaseField.mult
    
    /*
     * Cubing algorithms is modified in this version
     * Insteading of doing cubing and reduction in traditional way, we directly use
     * regroupping(remapping, or so called purmutation) to do modular cubing.
     */
    command void BaseField.cube(Element* A, Element *B){
        
        //The result of cubing B0 to B96 is grouped to C0[4],C1[4],C2[4], and c96.
        //C0[4]={c0,c3,c6...c93}, and so for C1[4] and C2[4]
        UInt C0_hi[4];
        UInt C0_lo[4];
        UInt C1_hi[4];
        UInt C1_lo[4];
        UInt C2_hi[4];
        UInt C2_lo[4];
        UInt temp[3];
        UInt i;
        
        //first do one bit shift for a[33] to [96] and move the a[32] to a[96]
        //store the result in B
        //a0 to a31
        memcpy(&B->hi[0], &A->hi[0], 4);
        memcpy(&B->lo[0], &A->lo[0], 4);
        temp[0] = A->hi[4] & 0x01;
        temp[1] = A->lo[4] & 0x01;
        for(i=4; i<(ELEMENT_LEN-1); i++){
            B->hi[i] = (A->hi[i]>>1) | (A->hi[i+1]<<7);
            B->lo[i] = (A->lo[i]>>1) | (A->lo[i+1]<<7);
        }
        B->hi[ELEMENT_LEN-1] = temp[0];
        B->lo[ELEMENT_LEN-1] = temp[1];
        //C0
        memcpy(C0_hi, &B->hi[0], 4);
        memcpy(C0_lo, &B->lo[0], 4);
        
        temp[0] = B->hi[11] & 0x0F; //a89 to a92
        temp[1] = B->lo[11] & 0x0F; //a89 to a92
        private_element_add(&C0_hi[0], &C0_lo[0], &temp[0], &temp[1], 1, &C0_hi[0], &C0_lo[0]);//C00
        temp[0] = temp[0]<<4;
        temp[1] = temp[1]<<4;
        private_element_add(&C0_hi[0], &C0_lo[0], &temp[1], &temp[0], 1, &C0_hi[0], &C0_lo[0]);//C00,substraction
        
        temp[0] = B->hi[11] >> 4; //a93 to a96
        temp[1] = B->lo[11] >> 4; //a93 to a96
        private_element_add(&C0_hi[0], &C0_lo[0], &temp[0], &temp[1], 1, &C0_hi[0], &C0_lo[0]);//C00
        private_element_add(&C0_hi[1], &C0_lo[1], &temp[1], &temp[0], 1, &C0_hi[1], &C0_lo[1]);//C01,substraction
        
        //C1
        C1_hi[0] = (B->hi[8] & 0x0F) | (B->hi[8]<<4); //a65 to a68 & a65 to a68
        C1_lo[0] = (B->lo[8] & 0x0F) | (B->lo[8]<<4); //a65 to a68 & a65 to a68
        temp[0] = B->hi[8] & 0xF0; //a69 to a72
        temp[1] = B->lo[8] & 0xF0; //a69 to a72
        private_element_add(&C1_hi[0], &C1_lo[0], &temp[0], &temp[1], 1, &C1_hi[0], &C1_lo[0]);//C10
        temp[0] = (B->hi[7] & 0xF0) | (B->lo[7]>>4);  //-a61 to -a64 & a61 to a64
        temp[1] = (B->lo[7] & 0xF0) | (B->hi[7]>>4);  //-a61 to -a64 & a61 to a64
        private_element_add(&C1_hi[0], &C1_lo[0], &temp[0], &temp[1], 1, &C1_hi[0], &C1_lo[0]);//C10
        
        for(i=1;i<4;i++){
            C1_hi[i] = (B->hi[7+i]>>4) | (B->hi[8+i]<<4);
            C1_lo[i] = (B->lo[7+i]>>4) | (B->lo[8+i]<<4);
            private_element_add(&C1_hi[i], &C1_lo[i], &B->hi[7+i], &B->lo[7+i], 1, &C1_hi[i], &C1_lo[i]);//C1i
            private_element_add(&C1_hi[i], &C1_lo[i], &B->hi[8+i], &B->lo[8+i], 1, &C1_hi[i], &C1_lo[i]);//C1i
        }
        
        //C2
        C2_hi[0] = (B->hi[4] & 0x0F) | (B->lo[4]<<4);  //a33 to a36 & -a33 to -a36
        C2_lo[0] = (B->lo[4] & 0x0F) | (B->hi[4]<<4);  //a33 to a36 & -a33 to -a36
        temp[0] = B->hi[4] & 0xF0;
        temp[1] = B->lo[4] & 0xF0;
        private_element_add(&C2_hi[0], &C2_lo[0], &temp[0], &temp[1], 1, &C2_hi[0], &C2_lo[0]);//C20
        for(i=1;i<4;i++){
            C2_hi[i] = (B->lo[3+i]>>4) | (B->lo[4+i]<<4); // -
            C2_lo[i] = (B->hi[3+i]>>4) | (B->hi[4+i]<<4); // -
            private_element_add(&C2_hi[i], &C2_lo[i], &B->hi[4+i], &B->lo[4+i], 1, &C2_hi[i], &C2_lo[i]);//C2i
        }
        
        //start cubing
        for(i=0;i<4;i++){
            private_void_byte_cube(&C0_hi[i], &B->hi[3*i]); //cube C0
            private_void_byte_cube(&C0_lo[i], &B->lo[3*i]); //cube C0
            
            private_void_byte_cube(&C1_hi[i], temp); //cube C1
            B->hi[3*i] |= temp[0]<<1;
            B->hi[3*i+1] |= temp[1]<<1;
            B->hi[3*i+2] |= temp[2]<<1;
            if(temp[1]&0x80){
                B->hi[3*i+2] |= 0x01;
            }
            private_void_byte_cube(&C1_lo[i], temp); //cube C1
            B->lo[3*i] |= temp[0]<<1;
            B->lo[3*i+1] |= temp[1]<<1;
            B->lo[3*i+2] |= temp[2]<<1;
            if(temp[1]&0x80){
                B->lo[3*i+2] |= 0x01;
            }
            
            private_void_byte_cube(&C2_hi[i], temp); //cube C2
            B->hi[3*i] |= temp[0]<<2;
            B->hi[3*i+1] |= temp[1]<<2;
            B->hi[3*i+2] |= temp[2]<<2;
            if(temp[0]&0x40){
                B->hi[3*i+1] |= 0x01;
            }
            if(temp[1]&0x80){
                B->hi[3*i+2] |= 0x02;
            }
            private_void_byte_cube(&C2_lo[i], temp); //cube C2
            B->lo[3*i] |= temp[0]<<2;
            B->lo[3*i+1] |= temp[1]<<2;
            B->lo[3*i+2] |= temp[2]<<2;
            if(temp[0]&0x40){
                B->lo[3*i+1] |= 0x01;
            }
            if(temp[1]&0x80){
                B->lo[3*i+2] |= 0x02;
            }
        }
    }//end BaseField.cube
    
    /*
     * A
     * B = A^(-1) mod F(x)
     * A, B can point to the same memory
     */
    command UInt BaseField.inver(Element* A, Element *B){
        Element fx = {{0x1,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0},
            {0x0,0x10,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x2}};
        Element g2 = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0}};
        Element u;
        Element v;
        Element trans;
        UInt deg_u, deg_v;
        UInt t = 0;
        int8_t equal = 0;
        int8_t j = 0;
        
        //A could not be zero
        if(memcmp(A,&ELEMENT_ZERO, ELEMENT_LEN*2)==0)
            return 0;
        
        memcpy(&u, A->hi, 2*ELEMENT_LEN);
        memcpy(&v, fx.hi, 2*ELEMENT_LEN);
        for(j=0; j<ELEMENT_LEN; j++){
            B->hi[j] = 0;
            B->lo[j] = 0;
        }
        B->lo[0] = 1;
        
        private_element_deg(&u, &deg_u);
        deg_v = 97;
        
        while(deg_u){
            //dbg("PairingTest", "%d   %d   ", deg_u, deg_v);
            j = deg_u - deg_v;
            if(j<0){
                trans = u;
                u = v;
                v = trans;
                
                trans = *B;
                *B = g2;
                g2 = trans;
                
                t = deg_u;
                deg_u = deg_v;
                deg_v = t;
                j = 0 - j;
            }
            
            if((u.hi[deg_u/8]>>(deg_u%8)) & (v.lo[deg_v/8]>>(deg_v%8)) & 0x01)
                equal = 1; //ui+vi=0
            else
                if((u.lo[deg_u/8]>>(deg_u%8)) & (v.hi[deg_v/8]>>(deg_v%8)) & 0x01)
                    equal = 1; //ui+vi=0
                else equal = 0;
            //dbg("PairingTest", "Equal: %d\n", equal);
            if(!equal){
                call BaseField.neg(&v, &v);
                call BaseField.neg(&g2, &g2);
            }
            private_element_shift(v.hi, v.lo, trans.hi, trans.lo, ELEMENT_LEN, j);
            //private_element_add(u.hi, u.lo, trans.hi, trans.lo, ELEMENT_LEN, u.hi, u.lo);
            call BaseField.add(&u, &trans, &u);
            private_element_shift(g2.hi, g2.lo, trans.hi, trans.lo, ELEMENT_LEN, j);
            //private_element_add(B->hi, B->lo, trans.hi, trans.lo, ELEMENT_LEN, B->hi, B->lo);
            call BaseField.add(B, &trans, B);
            
            private_element_deg(&u, &deg_u);
            private_element_deg(&v, &deg_v);
            
        }//end while loop
        
        if(u.hi[0] == 1){
            call BaseField.neg(B, B);
        }
        
        return 1;
    }//end BaseFiled.inver
    
    /*
     * compute opposite value of A
     * *B = -(*A)
     */
    command void BaseField.neg(Element *A, Element *B){
        uint8_t temp[ELEMENT_LEN];
        memcpy(temp, A->hi, ELEMENT_LEN);
        memcpy(B->hi, A->lo, ELEMENT_LEN);
        memcpy(B->lo, temp, ELEMENT_LEN);  	
    }
    
    /*
     * Base Conversion function
     * Compress an Element in base 3 to an array in base 2
     */
    command void BaseField.cps(Element *E, CpElement cpElement){
        int8_t i,k;
        UInt head, tail;
        UInt hi, lo;
        
        for(i=0; i<CPELEMENT_LEN; i++){
            k = i*5;
            tail = (k) % UINT_LEN;
            head = (k+4) % UINT_LEN;
            
            k = k/8;// /8;
            /*contain in one byte*/
            if(head>tail){
                hi = (E->hi[k]>>tail) & 0x1F;
                lo = (E->lo[k]>>tail) & 0x1F;
            }
            /*contain in two bytes*/
            else{
                hi = ((E->hi[k]>>tail) | (E->hi[k+1]<<(UINT_LEN-tail))) & 0x1F;
                lo = ((E->lo[k]>>tail) | (E->lo[k+1]<<(UINT_LEN-tail))) & 0x1F;
            }
            
            private_byte_elmt2int(hi, lo, cpElement+i);
        }
    }
    
    /*
     * Convert in inverse order
     * An array in base 2 is converted to an Element in base 3
     * The integer in Arrary should range from 0 to 242
     */
    command void BaseField.dcps(CpElement cpElement, Element *E){
        int8_t i, k;
        UInt head, tail;
        UInt hi, lo;
        
        memset(E, 0x0, ELEMENT_LEN*2);
        
        for(i=0; i<CPELEMENT_LEN; i++){
            private_byte_int2elmt(cpElement[i], &hi, &lo);
            k = i*5;
            tail = (k) % UINT_LEN;
            head = (k+4) % UINT_LEN;
            
            k = k>>3; // /= 8;
            /*contain in one byte*/
            if(head>tail){
                E->hi[k] |= hi<<tail;
                E->lo[k] |= lo<<tail;
            }
            /*contain in two bytes*/
            else{
                E->hi[k] |= hi<<tail;
                E->lo[k] |= lo<<tail;
                E->hi[k+1] |= hi>>(UINT_LEN-tail);
                E->lo[k+1] |= lo>>(UINT_LEN-tail);
            }
        }
    }
    
}
