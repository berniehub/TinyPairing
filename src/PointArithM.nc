/**
 * Authors: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Oct, 2008
 *
 *
 * This file handles point operations over the elliptic curves,
 * specifically, the point addition, tripling, and scale multiplication.
 */

#include "crypto.h"

module PointArithM{
    
    provides interface PointArith;
    uses interface BaseField;
    uses interface SHA1;
    uses interface NN;//from TINYECC library
}

implementation{
    
    /*
     * Compare two pointsB
     * Return 1 if they are equal
     * return 0 if not.
     */
    UInt point_cmp(Point* P, Point* Q){
        if(memcmp(P, Q, ELEMENT_LEN*4)==0)
            return 1;
        else return 0;
    }
    
    
    /*
     * Add two points P and Q
     * *R = *P + *Q
     */
    command void PointArith.add(Point* P, Point *Q, Point *R){
        Element slope, temp;
        Point r;
        
        /*either point P or Q is zero point*/
        if(point_cmp(P, &ZERO_POINT)){
            memcpy(R, Q, ELEMENT_LEN*4);
            return;
        }
        if(point_cmp(Q, &ZERO_POINT)){
            memcpy(R, P, ELEMENT_LEN*4);
            return;
        }
        
        /*point P is the same as point Q*/
        if(point_cmp(P, Q)){
            call PointArith.doub(P, R);
            return;
        }
        
        /*point P is the opposite point of Q*/
        call PointArith.neg(Q, &r);
        if(point_cmp(P, &r)){
            memcpy(R, &ZERO_POINT, ELEMENT_LEN*4);
            return;
        }
        
        /*ordinary point addition*/
        call BaseField.sub(&Q->y, &P->y, &slope);
        call BaseField.sub(&Q->x, &P->x, &temp);
        call BaseField.inver(&temp, &temp);
        call BaseField.mult(&slope, &temp, &slope);
        
        call BaseField.mult(&slope, &slope, &temp);/*slope^2*/
        call BaseField.cube(&slope, &slope);
        
        call BaseField.add(&P->x, &Q->x, &r.x);
        call BaseField.sub(&temp, &r.x, &R->x);
        
        call BaseField.add(&P->y, &Q->y, &r.y);
        call BaseField.sub(&r.y, &slope, &R->y);
        
    }
    
    
    /*
     * Compute double of point P
     * *Q = 2 * *P
     */
    command void PointArith.doub(Point* P, Point *Q){
        Element slope, temp;
        
        /*if point P is zero point*/
        if(point_cmp(P, &ZERO_POINT)){
            memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
            return;
        }
        
        call BaseField.inver(&P->y, &slope);
        
        call BaseField.mult(&slope, &slope, &temp);
        call BaseField.add(&temp, &P->x, &Q->x);
        
        call BaseField.cube(&slope, &slope);
        call BaseField.add(&slope, &P->y, &temp);
        call BaseField.neg(&temp, &Q->y);
    }
    
    
    /*
     * Compute trible of point P
     * *Q = 3 * *P
     */
    command void PointArith.trip(Point* P, Point *Q){
        Element temp;
        
        /*if point P is zero point*/
        if(point_cmp(P, &ZERO_POINT)){
            memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
            return;
        }
        
        call BaseField.cube(&P->x, &temp);
        call BaseField.cube(&temp, &temp);
        call BaseField.sub(&temp, &ELEMENT_ONE, &Q->x);
        
        call BaseField.cube(&P->y, &temp);
        call BaseField.cube(&temp, &temp);
        call BaseField.neg(&temp, &Q->y);
    }
    
    
    /*
     * Point scale multiplication k*P, where k is an element in base field to present an integer.
     * Since the order of the curve is #E = 3^m + 3^(m+1)/2 + 1,
     * it is reasonable to use an element in base field to store the scale multiplier k
     * *Q = *k * *P
     */
    command void PointArith.mult(Element* k, Point *P, Point *Q){
        Point dP,result;
        int8_t i,j;
        
        /*if point P is zero point*/
        if(point_cmp(P, &ZERO_POINT)){
            memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
            return;
        }
        /*if k is zero*/
        if(memcmp(ELEMENT_ONE.hi, k->hi, ELEMENT_LEN)==0){
            if(memcmp(ELEMENT_ONE.lo, k->lo, ELEMENT_LEN)==0){
                memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
                return;
            }
        }
        
        call PointArith.doub(P, &dP);
        
        /*preset result to zero*/
        memcpy(&result, &ZERO_POINT, ELEMENT_LEN*4);
        
        /*start the loop*/
        for(i=(ELEMENT_LEN-1); i>=0; i--){
            for(j=(UINT_LEN-1); j>=0; j--){
                if((k->hi[i]>>j)&0x01) /*case 2*/
                    call PointArith.add(&result, &dP, &result);
                else if((k->lo[i]>>j)&0x01) /*case 1*/
                    call PointArith.add(&result, P, &result);
                
                if((i>0)||(j>0))
                    call PointArith.trip(&result, &result);
            }
        }
        memcpy(Q, &result, ELEMENT_LEN*4);
    }
    
    command UInt PointArith.mult2(BigInt bigInt, Point *P, Point *Q){
        
        BigInt q;
        UInt r;
        UInt THREE = 0x3;
        //we declare an byte array here rather than new byte inside the code, for the reason the size is not big
        //and it costs additional bytes to store the pointers that link new bytes together.
        //MP_UInt8 k3[CONSTANT_M];//be consistant with BIGINT_LEN
        UInt k[ELEMENT_LEN*UINT_LEN];/* larger than log_3(BIGINT_LEN*8)*/
        UInt k3_len;
        //point precomputation
        Point dP;
        Point result;
        int8_t i;
        
        // if P is a zero point
        if(point_cmp(P, &ZERO_POINT)){
            memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
            return 1;
        }
        //if multiplier is zero, return zero point
        //bigint_mod(bigInt, mod_k);
        i=0;
        while((i<BIGINT_LEN) &&(bigInt[i]==0)){
            i++;
            if(i==BIGINT_LEN){
                memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
                return 1;
            }
        }
        
        //change the base of multiplier to radix 9 NAF
        k3_len = 0;
        call NN.Assign(q, bigInt, BIGINT_LEN);
        while((!(call NN.Zero(q, BIGINT_LEN)))&&(k3_len<(ELEMENT_LEN*UINT_LEN))){/*larger than log_3(BIGINT_LEN*8)*/
            call NN.Div(q, &r, q, BIGINT_LEN, &THREE, 1);
            k[k3_len++] = r;
        }
        
        call PointArith.doub(P, &dP); //double
        /*preset result to zero*/
        memcpy(&result, &ZERO_POINT, ELEMENT_LEN*4);
        
        /*start the loop*/
        for(i=k3_len-1; i>=0; i--){
            if(k[i]==0x02) /*case 2*/
                call PointArith.add(&result, &dP, &result);
            else if(k[i]==0x01) /*case 1*/
                call PointArith.add(&result, P, &result);
            
            if(i>0)
                call PointArith.trip(&result, &result);
            
        }
        memcpy(Q, &result, ELEMENT_LEN*4);
        return 1;
    }
    
    
    
    /*
     * compute opposite of point P
     * *Q = -(*P)
     */
    command void PointArith.neg(Point *P, Point *Q){
        call BaseField.neg(&P->y, &Q->y);
        memcpy(&Q->x, &P->x, ELEMENT_LEN*2);
    }
    
    /*
     * Add two points using projective coordinate
     * The projective coordinates of second input point are (x,y,1), so here we use its affine coordinate.
     * Refer to the library document for algorithm reference
     */
    command void PointArith.add_proj(Point_proj* P, Point *Q, Point_proj *R){
        Element A,B,C,D;
        //Point r;
        
        /*either point P or Q is zero point*/
        if(point_cmp((Point*)P, &ZERO_POINT)){
            memcpy(R, Q, ELEMENT_LEN*4);
            R->z = ELEMENT_ONE;
            return;
        }
        if(point_cmp(Q, &ZERO_POINT)){
            memcpy(R, P, ELEMENT_LEN*6);
            return;
        }
        
        /*point P is the opposite point of Q
         * first check whether q.x*p.z ?= p.x
         */
        call BaseField.mult(&Q->x, &P->z, &A);
        if(memcmp(&P->x, &A, ELEMENT_LEN*2)==0){
            call BaseField.mult(&Q->y, &P->z, &B);
            call BaseField.neg(&B, &C);
            if(memcmp(&P->y, &C, ELEMENT_LEN*2)==0){
                memcpy(R, &ZERO_POINT, ELEMENT_LEN*4);
                R->z = ELEMENT_ONE;
                return;
            }
        }
        
        //call BaseField.mult(&Q->x, &P->z, &A);
        call BaseField.sub(&A, &P->x, &A);
        call BaseField.mult(&Q->y, &P->z, &B);
        call BaseField.sub(&B, &P->y, &B);
        call BaseField.cube(&A, &C);
        call BaseField.mult(&B, &B, &D);
        call BaseField.mult(&D, &P->z, &D);
        call BaseField.sub(&C, &D, &D);
        
        //R->x
        call BaseField.mult(&P->x, &C, &R->x);
        call BaseField.mult(&A, &D, &A);
        call BaseField.sub(&R->x, &A, &R->x);
        //R->y
        call BaseField.mult(&B, &D, &A);
        call BaseField.mult(&P->y, &C, &R->y);
        call BaseField.sub(&A, &R->y, &R->y);
        //R->z
        call BaseField.mult(&P->z, &C, &R->z);
    }
    
    /*
     * Tripling a point in projective coordinates
     * x = x^9 - z^9
     * y = - y^9
     * z = z^9
     */
    command void PointArith.trip_proj(Point_proj* P, Point_proj *Q){
        
        /*if point P is zero point*/
        if(point_cmp((Point*)P, &ZERO_POINT)){
            memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
            Q->z = ELEMENT_ONE;
            return;
        }
        
        call BaseField.cube(&P->z, &Q->z);
        call BaseField.cube(&Q->z, &Q->z);
        
        call BaseField.cube(&P->x, &Q->x);
        call BaseField.cube(&Q->x, &Q->x);
        call BaseField.sub(&Q->x, &Q->z, &Q->x);
        
        call BaseField.cube(&P->y, &Q->y);
        call BaseField.cube(&Q->y, &Q->y);
        call BaseField.neg(&Q->y, &Q->y);
    }
    
    /*
     * Conduct scale multiplication of points, in which mulitplication is computed in coordinate forms
     * Scale multiplier k is in trinay representation, specifically a base field element
     */
    command UInt PointArith.mult_proj(Element* k, Point *P, Point *Q){
        
        Point p_array[8];
        Point_proj result;
        int8_t i,j;
        UInt uk, carry, t;
        UInt k_NAF[(ELEMENT_LEN*UINT_LEN)/2+1];
        
        /*
         * need to check P is not zero point and k is also not zero
         */
        if(point_cmp(P, &ZERO_POINT)){
            memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
            return 1;
        }
        /*if k is zero*/
        if(memcmp(ELEMENT_ZERO.hi, k->hi, ELEMENT_LEN)==0){
            if(memcmp(ELEMENT_ZERO.lo, k->lo, ELEMENT_LEN)==0){
                memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
                return 1;
            }
        }
        //p_array[0] = *P; //01=1
        memcpy(&p_array[0], P, ELEMENT_LEN*4); //01=1
        call PointArith.doub(&p_array[0], &p_array[1]); //02=2
        call PointArith.trip(&p_array[0], &p_array[2]); //10=3
        call PointArith.doub(&p_array[1], &p_array[3]); //11=4
        for(i=0; i<4;i++)
            {
            call PointArith.neg(&p_array[3-i], &p_array[4+i]);
            }
        /* save program size by group them.
         call PointArith.neg(&p_array[3], &p_array[4]);//12=5=-4
         call PointArith.neg(&p_array[2], &p_array[5]);//20=6=-3
         call PointArith.neg(&p_array[1], &p_array[6]);//21=7=-2
         call PointArith.neg(&p_array[0], &p_array[7]); //22=8=-1
         */
        
        /*preset result to zero*/
        memcpy(&result, &ZERO_POINT, ELEMENT_LEN*4);
        memcpy(&result.z, &ELEMENT_ONE, ELEMENT_LEN*2);
        
        
        /*
         * Apply NAF technique on scale multiplier K
         */
        t = 0;
        carry = 0;
        for(i=0; i<ELEMENT_LEN; i++){
            for(j=0; j<UINT_LEN; j=j+2){
                
                uk = (((k->hi[i])>>j)&0x3)<<2;
                uk |= ((k->lo[i])>>j)&0x3;
                switch(uk)
                {
                    case 1: //01
                    uk=1;
                    break;
                    case 4: //02
                    uk=2;
                    break;
                    case 2: //10
                    uk=3;
                    break;
                    case 3: //11
                    uk=4;
                    break;
                    case 6: //12
                    uk=5;
                    break;
                    case 8: //20
                    uk=6;
                    break;
                    case 9: //21
                    uk=7;
                    break;
                    case 12: //22
                    uk=8;
                    break;
                    default:
                    uk=0;
                    break;
                }
                
                k_NAF[t] = uk + carry;
                if((k_NAF[t])>4)
                    carry = 1;
                else
                    carry = 0;
                if((k_NAF[t])==9)
                    k_NAF[t] = 0;
                
                t++;
            }
        }
        k_NAF[t] = carry;
        
        
        /* start the loop, from most significant bit to least significant one*/
        for(i=((ELEMENT_LEN*UINT_LEN)/2); i>=0; i--){
            if(k_NAF[i]!=0){
                call PointArith.add_proj(&result, &p_array[k_NAF[i]-1], &result);
            }
            if(i>0){
                call PointArith.trip_proj(&result, &result);
                call PointArith.trip_proj(&result, &result);
            }
        }
        
        if(call BaseField.inver(&result.z, &result.z)==0) return 0;
        call BaseField.mult(&result.x, &result.z, &Q->x);
        call BaseField.mult(&result.y, &result.z, &Q->y);
        return 1;
    }
    
    /*
     * Conduct scale multiplication of points, in which mulitplication is computed in coordinate forms
     * Scale multiplier k is in binary representation, specifically a BigInt type
     */
    command UInt PointArith.mult_proj2(BigInt bigInt, Point *P, Point *Q){
        
        BigInt q;
        UInt r;
        UInt NINE = 0x9;
        //we declare an byte array here rather than new byte inside the code, for the reason the size is not big
        //and it costs additional bytes to store the pointers that link new bytes together.
        //MP_UInt8 k3[CONSTANT_M];//be consistant with BIGINT_LEN
        UInt k_NAF[ELEMENT_LEN*UINT_LEN/2];/* larger than log_3(BIGINT_LEN*8)*/
        UInt k9_len;
        //point precomputation
        Point p_array[8];
        Point_proj result;
        UInt carry;
        int8_t i;
        
        // if P is a zero point
        if(point_cmp(P, &ZERO_POINT)){
            memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
            return 1;
        }
        //if multiplier is zero, return zero point
        //bigint_mod(bigInt, mod_k);
        i=0;
        while((i<BIGINT_LEN) &&(bigInt[i]==0)){
            i++;
            if(i==BIGINT_LEN){
                memcpy(Q, &ZERO_POINT, ELEMENT_LEN*4);
                return 1;
            }
        }
        
        //change the base of multiplier to radix 9 NAF
        k9_len = 0;
        carry = 0;
        call NN.Assign(q, bigInt, BIGINT_LEN);
        while((!(call NN.Zero(q, BIGINT_LEN)))&&(k9_len<(ELEMENT_LEN*UINT_LEN/2))){/*larger than log_3(BIGINT_LEN*8)*/
            call NN.Div(q, &r, q, BIGINT_LEN, &NINE, 1);
            
            k_NAF[k9_len] = carry;
            if(r!=0){
                //assert r can be only 1,2,...,8
                k_NAF[k9_len] += r;
            }
            if(k_NAF[k9_len]>4)
                carry = 1;
            else
                carry = 0;
            if(k_NAF[k9_len]==9)
                k_NAF[k9_len] = 0;
            
            k9_len++;
        }
        if(carry==1)
            k_NAF[k9_len++]=1;
        
        //p_array[0] = *P; //01=1
        memcpy(&p_array[0], P, ELEMENT_LEN*4); //01=1
        call PointArith.doub(&p_array[0], &p_array[1]); //02=2
        call PointArith.trip(&p_array[0], &p_array[2]); //10=3
        call PointArith.doub(&p_array[1], &p_array[3]); //11=4
        for(i=0; i<4;i++)
            {
            call PointArith.neg(&p_array[3-i], &p_array[4+i]);
            }
        
        /*preset result to zero*/
        //memcpy(&result.x, &ZERO_POINT.x, ELEMENT_LEN*2);
        //memcpy(&result.z, &ELEMENT_ONE, ELEMENT_LEN*2);
        result.x=ZERO_POINT.x;
        result.y=ZERO_POINT.y;
        result.z=ELEMENT_ONE;
        /* start the loop, from most significant bit to least significant one*/
        for(i=k9_len-1; i>=0; i--){
            if(k_NAF[i]!=0){
                call PointArith.add_proj(&result, &p_array[k_NAF[i]-1], &result);
            }
            if(i>0){
                call PointArith.trip_proj(&result, &result);
                call PointArith.trip_proj(&result, &result);
            }
        }
        
        call BaseField.inver(&result.z, &result.z);
        call BaseField.mult(&result.x, &result.z, &Q->x);
        call BaseField.mult(&result.y, &result.z, &Q->y);
        
        return 1;
        
    }
    
    
    /*
     * This funtion maps an arbitrary message to a point on the elliptic curve
     * Hash to point algorithm:
     * Input: a random length message
     * Output: a point on the EC
     * 1. i = 0
     * 2. hash(i||msg)->digest
     * 3.1 encode every two bits of the digest to 1 digit in the base field element x
     * 	 by 00->0,01->1,10->2, ignore the case 11
     * 3.2 if digest is not long enough to generate x, go to step 2
     * 4. compute f(x). If f(x) has roots y0, y1, choose
     * 	(x, y0) as the point if i is even
     * 	(x, y1) as the point if i is odd
     * 4.1 7*(x,y) to get a point in the subgroup
     * 5. otherwise, increment i and goto step 2.
     *
     * Return 1 if success, 0 if fail
     */
    command bool PointArith.map2point(UInt* msg, uint32_t len, Point* point){
        SHA1Context ctx;
        UInt sha1sum[SHA1HashSize];
        UInt* hashmsg;
        UInt i;
        UInt j;
        UInt a,b;//x index
        UInt ha,hb;//sha1sum index.
        UInt rdigit;
        Element x,y;
        
        hashmsg = malloc(len+1);
        if(hashmsg==NULL) return FALSE;
        memcpy(hashmsg+1, msg, len);
        
        //we try HASHBOUND times here, if still can not obtain a valid point return failure
        for(i=0;i<HASH_BOUND;i++){
            memset(&x, 0x0, ELEMENT_LEN*2);
            
            hashmsg[0] = i;
            if(call SHA1.reset(&ctx)!=shaSuccess){
                if(hashmsg!=NULL) free(hashmsg);
                return FALSE;
            }
            if(call SHA1.update(&ctx, hashmsg, len+1)!=shaSuccess){
                if(hashmsg!=NULL) free(hashmsg);
                return FALSE;
            }
            if(call SHA1.digest(&ctx, sha1sum)!=shaSuccess){
                if(hashmsg!=NULL) free(hashmsg);
                return FALSE;
            }
            
            ha = 0;
            hb = 0;
            //encode the digest to a base field element
            j=0;
            while(j<CONSTANT_M){
                //obtain a random trinary digit from two bits
                
                //obtain two random bits
                rdigit=3;
                while(rdigit==3){
                    if(ha==SHA1HashSize){
                        //hashed bits are used up
                        //run hash funtion one more time
                        if(call SHA1.reset(&ctx)!=shaSuccess){
                            if(hashmsg!=NULL) free(hashmsg);
                            return FALSE;
                        }
                        if(call SHA1.update(&ctx, sha1sum, SHA1HashSize)!=shaSuccess){
                            if(hashmsg!=NULL) free(hashmsg);
                            return FALSE;
                        }
                        if(call SHA1.digest(&ctx, sha1sum)!=shaSuccess){
                            if(hashmsg!=NULL) free(hashmsg);
                            return FALSE;
                        }
                        
                        ha = 0;
                    }
                    
                    rdigit = (sha1sum[ha]>>hb) & 0x3;
                    hb = (hb+2) & 0x7;
                    if(hb==0)	ha++;
                }
                
                //convert two random bits to one random digit
                //00->0, 01->1, 10->2 
                a = j/8;//j>>3; //j/8;
                b = j%8;//(j&0x07); //j%8;
                
                x.hi[a] |= (rdigit>>1)<<b;
                x.lo[a] |= (rdigit&0x1)<<b;
                
                j++;
            }
            
            //get y
            if(call PointArith.get_y(&x, &y)){
                point->x = x;
                point->y = y;
                free(hashmsg);
                return TRUE;
            }
        }
        free(hashmsg);
        return FALSE;
    }
    
    /*
     * This function compute the y coordinate, given the x coordinate
     * y^2 = x^3 - x + 1
     * Return 1 if success, 0 if fail
     */
    command bool PointArith.get_y(Element *x, Element *y){
        Element y2, temp;
        Element y_1;//computed y1 for x coordinate
        int8_t i;
        
        /*y^2*/
        call BaseField.cube(x, &y2);
        call BaseField.sub(&y2, x, &y2);
        call BaseField.add(&y2, &ELEMENT_ONE, &y2);
        
        call BaseField.mult(&y2, &y2, &temp);
        call BaseField.inver(&temp, &y_1);
        
        temp = y2;
        for(i=0; i<(CONSTANT_M-1)/2; i++){
            call BaseField.cube(&temp, &temp);
            call BaseField.cube(&temp, &temp);
            call BaseField.mult(&temp, &y_1, &temp);
        }//temp = y2^(1/2)
        
        y_1 = temp;
        
        call BaseField.mult(&temp, &temp, &temp);
        if(memcmp(&temp, &y2, ELEMENT_LEN*2)!=0)
            return FALSE;
        
        *y = y_1;
        return TRUE;
    }
    
    /*
     * Compress a point to a CpPoint
     */  
    command bool PointArith.cps(Point* p, CpElement cp){
        Element y;
        UInt flag;
        
        if(!(call PointArith.get_y(&p->x, &y))) return FALSE;
        if(memcmp(&p->y, &y, ELEMENT_LEN)==0)
            flag = 0x0;
        else
            flag = 0x80;
        
        call BaseField.cps(&p->x, cp);
        cp[CPELEMENT_LEN-1] |= flag;
        
        return TRUE;
    }
    
    /*
     * Decompress a CpPoint
     */
    command bool PointArith.dcps(CpElement cp, Point *p){
        UInt flag;
        CpElement cptemp;
        
        memcpy(cptemp, cp, CPELEMENT_LEN);
        flag = 0x80 & cptemp[CPELEMENT_LEN-1];
        cptemp[CPELEMENT_LEN-1] &= 0x7F;
        
        call BaseField.dcps(cptemp, &p->x);
        if(!(call PointArith.get_y(&p->x, &p->y))) return FALSE;
        
        if(flag!=0)
            call BaseField.neg(&p->y, &p->y);
        
        return TRUE;
    }
    
}
