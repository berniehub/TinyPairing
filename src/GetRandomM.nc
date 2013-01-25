/**
 * This file provides implementation for random bytes, and random base field element generation.
 * It is dependent on RandomLfsrC.
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "crypto.h"

module GetRandomM{
    provides interface GetRandom;
    uses interface Random;
    uses interface PointArith;
}

implementation{
    
    /*
     * Generate a random elment
     * which dependents on the TinyOS random function RandomLfsrC
     * The order to the subgroup used is #E/7=(3^97+3^49+1)/7<3^96,
     */
    command void GetRandom.elmt(Element* re){
        UInt rdigit;
        UInt a,b;
        UInt i=0;
        UInt ri=0;
        uint16_t rbits;
        
        memset(re, 0x0, ELEMENT_LEN*2);
        rbits = call Random.rand16();
        while(i<CONSTANT_M){
            rdigit=3;
            while(rdigit==3){
                if(ri==16){
                    rbits = call Random.rand16();
                    ri=0;
                    //dbg("PairingTest", "Random bits: %X\n", rbits);
                }
                rdigit = (rbits>>ri) & 0x3;
                ri += 2;
            }
            
            //convert two random bits to one random digit
            //00->0, 01->1, 10->2
            a = i/8;//i>>3; //i/8;
            b = i%8;//(i&0x07); //i%8;
            
            re->hi[a] |= (rdigit>>1)<<b;
            re->lo[a] |= (rdigit&0x1)<<b;
            
            i++;
        }
    }
    
    /*
     * get a random large interger and stored in a BigInt type
     * The order to the subgroup used is #E/7=(3^97+3^49+1)/7<2^151,
     */
    command void GetRandom.bigint(BigInt bi){
        UInt i;
        uint16_t rbits;
        
        for(i=0; i<(BIGINT_LEN-1); i=i+2){
            rbits = call Random.rand16();
            memcpy(&bi[i], &rbits, 2);
        }
        rbits = call Random.rand16();
        memcpy(&bi[BIGINT_LEN-1], &rbits, 1);
    }
    
    /*
     * get a random generator point
     * obtained by get a random point p, and return 7*p, which has prime order s.t..
     */
    command void GetRandom.generator(Point* generator){
        Point p;
        bool succ=FALSE;
        while(!succ){
            call GetRandom.elmt(&p.x);
            p.x.hi[ELEMENT_LEN-1] &= 0X1;
            p.x.lo[ELEMENT_LEN-1] &= 0X1;
            succ = call PointArith.get_y(&p.x, &p.y);
        }
        //7*p
        call PointArith.trip(&p, generator);//3*p
        call PointArith.doub(generator, generator);//2*3*p
        call PointArith.add(&p, generator, generator);//1+2*3p
    }
    
}
