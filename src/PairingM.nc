/**
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Oct, 2008
 */

#include "crypto.h"

module PairingM{
    
    provides interface Pairing;
    uses interface BaseField;
    uses interface ExtField2;
}

implementation{
    static Element element_one = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
        {1,0,0,0,0,0,0,0,0,0,0,0,0}};
    void triple_point(Point *p, Point *tp)
    {
    //need to be modified here to handle zero point
    //if(equal(p, zero_point)) return zero_point;
    
    call BaseField.cube(&p->x, &tp->x);
    call BaseField.cube(&tp->x, &tp->x);
    //can be further optimaized here
    call BaseField.sub(&tp->x, &element_one, &tp->x);
    call BaseField.cube(&p->y, &tp->y);
    call BaseField.cube(&tp->y, &tp->y);
    call BaseField.neg(&tp->y, &tp->y);
    }
    
    /*
     * Pairing computed in the ExtField2
     */
    /*
     * more efficient exponation,but more memory
     */
    
    //for final expononation
    void lambda(ExtElement2 *a, ExtElement2 *b)
    {
    Element z0;
    Element z1;
    Element z2;
    Element z3;
    Element z4;
    Element z5;
    Element z6;
    Element z7;
    Element z8;
    Element temp;
    
    call BaseField.mult(&a->ext[0].mid[0], &a->ext[0].mid[2], &z0);
    call BaseField.mult(&a->ext[1].mid[0], &a->ext[1].mid[2], &z1);
    call BaseField.mult(&a->ext[0].mid[1], &a->ext[0].mid[2], &z2);
    call BaseField.mult(&a->ext[1].mid[1], &a->ext[1].mid[2], &z3);
    
    call BaseField.add(&a->ext[0].mid[0], &a->ext[1].mid[0], &z4);
    call BaseField.sub(&a->ext[0].mid[2], &a->ext[1].mid[2], &temp);
    call BaseField.mult(&z4, &temp, &z4);
    
    call BaseField.mult(&a->ext[1].mid[0], &a->ext[0].mid[1], &z5);
    call BaseField.mult(&a->ext[0].mid[0], &a->ext[1].mid[1], &z6);
    
    call BaseField.add(&a->ext[0].mid[0], &a->ext[1].mid[0], &z7);
    call BaseField.add(&a->ext[0].mid[1], &a->ext[1].mid[1], &temp);
    call BaseField.mult(&z7, &temp, &z7);
    
    call BaseField.add(&a->ext[0].mid[1], &a->ext[1].mid[1], &z8);
    call BaseField.sub(&a->ext[0].mid[2], &a->ext[1].mid[2], &temp);
    call BaseField.mult(&z8, &temp, &z8);
    
    //B
    call BaseField.add(&element_one, &z0, &b->ext[0].mid[0]);
    call BaseField.add(&b->ext[0].mid[0], &z1, &b->ext[0].mid[0]);
    call BaseField.sub(&b->ext[0].mid[0], &z2, &b->ext[0].mid[0]);
    call BaseField.sub(&b->ext[0].mid[0], &z3, &b->ext[0].mid[0]);
    
    call BaseField.add(&z1, &z4, &b->ext[1].mid[0]);
    call BaseField.add(&b->ext[1].mid[0], &z5, &b->ext[1].mid[0]);
    call BaseField.sub(&b->ext[1].mid[0], &z0, &b->ext[1].mid[0]);
    call BaseField.sub(&b->ext[1].mid[0], &z6, &b->ext[1].mid[0]);
    
    call BaseField.sub(&z7, &z2, &b->ext[0].mid[1]);
    call BaseField.sub(&b->ext[0].mid[1], &z3, &b->ext[0].mid[1]);
    call BaseField.sub(&b->ext[0].mid[1], &z5, &b->ext[0].mid[1]);
    call BaseField.sub(&b->ext[0].mid[1], &z6, &b->ext[0].mid[1]);
    
    call BaseField.add(&z0, &z3, &b->ext[1].mid[1]);
    call BaseField.add(&b->ext[1].mid[1], &z8, &b->ext[1].mid[1]);
    call BaseField.sub(&b->ext[1].mid[1], &z2, &b->ext[1].mid[1]);
    call BaseField.sub(&b->ext[1].mid[1], &z1, &b->ext[1].mid[1]);
    call BaseField.sub(&b->ext[1].mid[1], &z4, &b->ext[1].mid[1]);
    
    call BaseField.add(&z2, &z3, &b->ext[0].mid[2]);
    call BaseField.add(&b->ext[0].mid[2], &z7, &b->ext[0].mid[2]);
    call BaseField.sub(&b->ext[0].mid[2], &z5, &b->ext[0].mid[2]);
    call BaseField.sub(&b->ext[0].mid[2], &z6, &b->ext[0].mid[2]);
    
    call BaseField.add(&z3, &z8, &b->ext[1].mid[2]);
    call BaseField.sub(&b->ext[1].mid[2], &z2, &b->ext[1].mid[2]);
    }
    
    void root_3m(ExtElement2 *a, ExtElement2 *r)
    {
    call BaseField.sub(&a->ext[0].mid[0], &a->ext[0].mid[1], &r->ext[0].mid[0]);
    call BaseField.add(&r->ext[0].mid[0], &a->ext[0].mid[2], &r->ext[0].mid[0]);//r00
    call BaseField.sub(&a->ext[1].mid[1], &a->ext[1].mid[0], &r->ext[1].mid[0]);
    call BaseField.sub(&r->ext[1].mid[0], &a->ext[1].mid[2], &r->ext[1].mid[0]);//r10
    call BaseField.add(&a->ext[0].mid[1], &a->ext[0].mid[2], &r->ext[0].mid[1]);//r01
    call BaseField.add(&a->ext[1].mid[1], &a->ext[1].mid[2], &r->ext[1].mid[1]);
    call BaseField.neg(&r->ext[1].mid[1], &r->ext[1].mid[1]);//r11
    memcpy(&r->ext[0].mid[2].hi, &a->ext[0].mid[2].hi, ELEMENT_LEN);//r02
    memcpy(&r->ext[0].mid[2].lo, &a->ext[0].mid[2].lo, ELEMENT_LEN);//r02
    call BaseField.neg(&a->ext[1].mid[2], &r->ext[1].mid[2]);//r12
    }
    
    // keep Point P and Q unchanged
    command void Pairing.pairing(Point *P, Point *Q, ExtElement2 *E){
        ExtElement2 R1; //v5
        
        Element r0;
        Element b = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
            {1,0,0,0,0,0,0,0,0,0,0,0,0}};
        Element d = {{0,0,0,0,0,0,0,0,0,0,0,0,0},
            {1,0,0,0,0,0,0,0,0,0,0,0,0}};
        UInt i;
        Point p;
        Point q;
        
        //P = 3^{(m-1)/2} * P
        triple_point(P, &p);
        for(i=1; i<(CONSTANT_M-1)/2; i++){
            triple_point(&p, &p);
        }
        
        //memcpy(&q.x, &Q->x, ELEMENT_LEN);
        //memcpy(&q.y, &Q->y, ELEMENT_LEN);
        q = *Q;
        //start Algorithm 2
        call BaseField.neg(&p.y, &p.y);
        
        call BaseField.add(&p.x, &q.x, &r0);
        call BaseField.add(&r0, &b, &r0);
        
        //*E = R0
        call BaseField.mult(&p.y, &r0, &r0);
        call BaseField.neg(&r0, &E->ext[0].mid[0]);
        //memcpy(&E->ext[0].mid[1], &q.x, ELEMENT_LEN);
        //memcpy(&E->ext[1].mid[0], &p.x, ELEMENT_LEN);
        E->ext[1].mid[0] = q.y;
        E->ext[0].mid[1] = p.y;
        memset(&E->ext[0].mid[2].hi, 0x0, ELEMENT_LEN);
        memset(&E->ext[0].mid[2].lo, 0x0, ELEMENT_LEN);
        memset(&E->ext[1].mid[1].hi, 0x0, ELEMENT_LEN);
        memset(&E->ext[1].mid[1].lo, 0x0, ELEMENT_LEN);
        memset(&E->ext[1].mid[2].hi, 0x0, ELEMENT_LEN);
        memset(&E->ext[1].mid[2].lo, 0x0, ELEMENT_LEN);
        
        for(i=0; i<=(CONSTANT_M-1)/2; i++){
            call BaseField.add(&p.x, &q.x, &r0);
            call BaseField.add(&r0, &d, &r0);
            
            //R1
            call BaseField.neg(&r0, &R1.ext[0].mid[1]);
            call BaseField.mult(&r0, &r0, &r0);
            call BaseField.neg(&r0, &R1.ext[0].mid[0]);
            call BaseField.mult(&p.y, &q.y, &R1.ext[1].mid[0]);
            memset(&R1.ext[1].mid[1].hi, 0x0, ELEMENT_LEN);
            memset(&R1.ext[1].mid[1].lo, 0x0, ELEMENT_LEN);
            call BaseField.neg(&b, &R1.ext[0].mid[2]);
            memset(&R1.ext[1].mid[2].hi, 0x0, ELEMENT_LEN);
            memset(&R1.ext[1].mid[2].lo, 0x0, ELEMENT_LEN);
            
            
            //*E = R0 = (R0R1)^3)
            call ExtField2.mult(&R1, E, E);
            call ExtField2.cube(E, E);
            
            call BaseField.neg(&p.y, &p.y);
            call BaseField.cube(&q.x, &q.x);
            call BaseField.cube(&q.x, &q.x);
            call BaseField.cube(&q.y, &q.y);
            call BaseField.cube(&q.y, &q.y);
            
            call BaseField.sub(&d, &b, &d);
        }
        
        //compute E(R0)'s 3m-th root
        root_3m(E, E);
        
        //final expononation
        //use R1.ext[1] and R1.ext[0] to store temp value
        call ExtField2.mid_mult_element(&E->ext[0], &E->ext[1], &R1.ext[0]); //A0A1
        call ExtField2.mid_mult_element(&E->ext[0], &E->ext[0], &E->ext[0]); //A0A0
        call ExtField2.mid_mult_element(&E->ext[1], &E->ext[1], &E->ext[1]); //A1A1
        call ExtField2.mid_add_element(&E->ext[0], &E->ext[1], &R1.ext[1]); //A0^2+A1+2
        call ExtField2.mid_inver_element(&R1.ext[1], &R1.ext[1]); //(A0^2+A1+2)^-1
        call ExtField2.mid_sub_element(&E->ext[0], &E->ext[1], &E->ext[0]); //A0^2-A1+2
        call ExtField2.mid_mult_element(&E->ext[0], &R1.ext[1], &E->ext[0]); //A0
        call ExtField2.mid_add_element(&R1.ext[0], &R1.ext[0], &R1.ext[0]); //2A0A1
        call ExtField2.mid_neg_element(&R1.ext[0], &R1.ext[0]);//-2A0A1
        call ExtField2.mid_mult_element(&R1.ext[0], &R1.ext[1], &E->ext[1]); //A1
        
        lambda(E, E);
        lambda(E, &R1); //R1=d
        
        for(i=0; i<=(CONSTANT_M-1)/2; i++){
            call ExtField2.cube(E, E);
        }
        call ExtField2.inver(E, E);
        call ExtField2.mult(E, &R1, E);
    }
    
}
