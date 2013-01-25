/**
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Oct, 2008
 */

#include "crypto.h"

module ExtField2M{
    
    provides interface ExtField2;
    uses interface BaseField;
}

implementation{
    
    /*
     * intermedia filed operations
     */
    command void ExtField2.mid_add_element(MidElement2 *a, MidElement2 *b, MidElement2 *c){
        call BaseField.add(&a->mid[0], &b->mid[0], &c->mid[0]);
        call BaseField.add(&a->mid[1], &b->mid[1], &c->mid[1]);
        call BaseField.add(&a->mid[2], &b->mid[2], &c->mid[2]);
    }
    
    command void ExtField2.mid_sub_element(MidElement2 *a, MidElement2 *b, MidElement2 *c){
        call BaseField.sub(&a->mid[0], &b->mid[0], &c->mid[0]);
        call BaseField.sub(&a->mid[1], &b->mid[1], &c->mid[1]);
        call BaseField.sub(&a->mid[2], &b->mid[2], &c->mid[2]);
    }
    
    command void ExtField2.mid_mult_element(MidElement2 *A, MidElement2 *B, MidElement2 *C){
        Element d1, d2, d3;
        Element temp;
        
        //pre-calulate d1
        call BaseField.add(&A->mid[1], &A->mid[0], &temp);
        call BaseField.add(&B->mid[1], &B->mid[0], &d1);
        call BaseField.mult(&temp, &d1, &d1);
        //pre-cal d2
        call BaseField.add(&A->mid[2], &A->mid[0], &temp);
        call BaseField.add(&B->mid[2], &B->mid[0], &d2);
        call BaseField.mult(&temp, &d2, &d2);
        //pre-cal d3
        call BaseField.add(&A->mid[2], &A->mid[1], &temp);
        call BaseField.add(&B->mid[2], &B->mid[1], &d3);
        call BaseField.mult(&temp, &d3, &d3);
        
        call BaseField.mult(&A->mid[0], &B->mid[0], &C->mid[0]); //a0b0
        call BaseField.mult(&A->mid[1], &B->mid[1], &C->mid[1]); //a1b1
        call BaseField.mult(&A->mid[2], &B->mid[2], &C->mid[2]); //a2b2
        
        //compute d1,d2,d3
        call BaseField.sub(&d1, &C->mid[1], &d1);
        call BaseField.sub(&d1, &C->mid[0], &d1);
        
        call BaseField.add(&d2, &C->mid[1], &d2);
        call BaseField.sub(&d2, &C->mid[2], &d2);
        call BaseField.sub(&d2, &C->mid[0], &d2);
        
        call BaseField.sub(&d3, &C->mid[2], &d3);
        call BaseField.sub(&d3, &C->mid[1], &d3);
        
        //compute C
        call BaseField.add(&d1, &d3, &C->mid[1]);
        call BaseField.add(&C->mid[1], &C->mid[2], &C->mid[1]);
        call BaseField.add(&C->mid[0], &d3, &C->mid[0]);
        call BaseField.add(&C->mid[2], &d2, &C->mid[2]);
    }
    
    command void ExtField2.mid_cube_element(MidElement2 *A, MidElement2 *B){
        call BaseField.cube(&A->mid[0], &B->mid[0]); //a0^3
        call BaseField.cube(&A->mid[1], &B->mid[1]); //a1^3
        call BaseField.cube(&A->mid[2], &B->mid[2]); //a2^3
        
        call BaseField.add(&B->mid[0], &B->mid[1], &B->mid[0]);
        call BaseField.add(&B->mid[0], &B->mid[2], &B->mid[0]);
        call BaseField.sub(&B->mid[1], &B->mid[2], &B->mid[1]);
    }
    
    /*
     * A(u)^-1
     */
    command void ExtField2.mid_inver_element(MidElement2 *A, MidElement2 *B){
        Element delta;
        Element temp;
        Element a02, a12, a22;
        
        //compute a0^2, a1^2, a2^3
        call BaseField.mult(&A->mid[0], &A->mid[0], &a02); //a0^2
        call BaseField.mult(&A->mid[1], &A->mid[1], &a12); //a1^2
        call BaseField.mult(&A->mid[2], &A->mid[2], &a22); //a2^2
        
        //compute delta
        call BaseField.sub(&A->mid[0], &A->mid[2], &temp);
        call BaseField.mult(&temp, &a02, &delta);
        
        call BaseField.sub(&A->mid[1], &A->mid[0], &temp);
        call BaseField.mult(&temp, &a12, &temp);
        call BaseField.add(&delta, &temp, &delta);
        
        call BaseField.sub(&A->mid[0], &A->mid[1], &temp);
        call BaseField.add(&temp, &A->mid[2], &temp);
        call BaseField.mult(&temp, &a22, &temp);
        call BaseField.add(&delta, &temp, &delta);
        
        call BaseField.inver(&delta, &delta);
        
        //compute C
        call BaseField.add(&a02, &a22, &a02);
        call BaseField.sub(&a02, &a12, &a02);
        call BaseField.mult(&A->mid[1], &A->mid[2], &temp);
        call BaseField.sub(&a02, &temp, &a02);
        call BaseField.mult(&A->mid[0], &A->mid[2], &temp); //a0a2
        call BaseField.sub(&a02, &temp, &a02);
        //for c2
        call BaseField.sub(&a12, &temp, &a12);
        call BaseField.mult(&a02, &delta, &a02); //b0
        
        call BaseField.sub(&a12, &a22, &a12);
        call BaseField.mult(&a12, &delta, &a12); //b2
        
        call BaseField.mult(&A->mid[0], &A->mid[1], &temp);
        call BaseField.sub(&a22, &temp, &a22);
        call BaseField.mult(&a22, &delta, &a22); //b1
        
        B->mid[0] = a02;
        B->mid[1] = a22;
        B->mid[2] = a12;
    }
    
    command void ExtField2.mid_neg_element(MidElement2 *A, MidElement2 *B){
        call BaseField.neg(&A->mid[0], &B->mid[0]);
        call BaseField.neg(&A->mid[1], &B->mid[1]);
        call BaseField.neg(&A->mid[2], &B->mid[2]);
    }
    /*
     * Add two elements A and B in extension filed GF(3^97^6)
     * *C = *A + *B
     */
    //command void ExtField.add(ExtElement* A, ExtElement *B, ExtElement *C)
    
    /*
     * A multiply B in GF(3^97^6)
     * *C = *A * *B mod F(x)
     */
    command void ExtField2.mult(ExtElement2* A, ExtElement2 *B, ExtElement2 *C){
        MidElement2 a0b0;
        MidElement2 a1b1;
        MidElement2 a1a0b1b0;
        call ExtField2.mid_add_element(&A->ext[0], &A->ext[1], &a0b0);
        call ExtField2.mid_add_element(&B->ext[0], &B->ext[1], &a1b1);
        call ExtField2.mid_mult_element(&a0b0, &a1b1, &a1a0b1b0);
        call ExtField2.mid_mult_element(&A->ext[0], &B->ext[0], &a0b0);
        call ExtField2.mid_mult_element(&A->ext[1], &B->ext[1], &a1b1);
        
        call ExtField2.mid_sub_element(&a0b0, &a1b1, &C->ext[0]);
        call ExtField2.mid_sub_element(&a1a0b1b0, &a1b1, &a1a0b1b0);
        call ExtField2.mid_sub_element(&a1a0b1b0, &a0b0, &C->ext[1]);
    }
    
    /*
     * Compute cube of A in GF(3^97^6)
     * *B = *A^3
     */
    command void ExtField2.cube(ExtElement2* A, ExtElement2 *B){
        call ExtField2.mid_cube_element(&A->ext[0], &B->ext[0]); //a0^3
        call ExtField2.mid_cube_element(&A->ext[1], &B->ext[1]); //a1^3
        //-a1^3
        call ExtField2.mid_neg_element(&B->ext[1], &B->ext[1]);
    }
    
    /*
     * Compute inverse of A in GF(3^97^6)
     * *B = *A^(-1)
     */
    command void ExtField2.inver(ExtElement2* A, ExtElement2 *B){
        MidElement2 temp0;
        MidElement2 temp1;
        call ExtField2.mid_mult_element(&A->ext[0],&A->ext[0],&temp0);
        call ExtField2.mid_mult_element(&A->ext[1],&A->ext[1],&temp1);
        call ExtField2.mid_add_element(&temp0,&temp1,&temp0);//t
        call ExtField2.mid_inver_element(&temp0, &temp0);//t^-1
        
        call ExtField2.mid_mult_element(&temp0, &A->ext[0], &B->ext[0]);
        //neg
        call ExtField2.mid_neg_element(&A->ext[1], &temp1);
        call ExtField2.mid_mult_element(&temp0, &temp1, &B->ext[1]);
    }
}
