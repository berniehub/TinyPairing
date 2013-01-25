/**
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Oct, 2008
 */
#include "crypto.h"
#include "TimeSerial.h"

module PairingTestM
{
    uses interface Boot;
    uses interface BaseField;
    uses interface ExtField2;
    uses interface PointArith;
    uses interface Pairing;
    uses interface Leds;
    uses interface GetRandom;
    uses interface SplitControl;
    uses interface AMSend as SerialSend;
    uses interface Packet;
    
    uses interface Counter<TMilli, uint32_t>;
    uses interface Alarm<TMilli, uint32_t>;
}

implementation
{
    static Element c_a = {{0x49,0x02,0x80,0xE2,  0x14,0x4D,0x01,0x69,  0x20,0x00,0x00,0xB0,  0x1},
        {0x36,0x90,0x34,0x10,  0x22,0xB0,0x7E,0x80,  0x03,0x39,0xC9,0x41,  0x0}};
    static Element c_b = {{0x01,0x2A,0x06,0x64,  0x01,0x02,0x3A,0x62,  0xD1,0x08,0xCB,0x08,  0x0},
        {0x66,0xD0,0x41,0x00,  0xCC,0x1C,0x84,0x80,  0x20,0x62,0x00,0xE6,  0x1}};
    
    static Element c_c = {{0x02,0x16,0xDB,0x81,  0xD2,0x00,0x55,0xAA,  0xDC,0x30,0xD6,0x11,  0x0},
        {0x9C,0x29,0x20,0x0C,  0x09,0xF0,0x82,0x45,  0x03,0x01,0x01,0xA6,  0x1}};
    
    static Element c_d = {{0x30,0x40,0x92,0x38,  0x06,0x90,0x07,0x54,  0x70,0x2C,0x44,0x15,  0x0},
        {0x49,0xA1,0x09,0xC0,  0xC0,0x45,0xC0,0x28,  0x0A,0x82,0x83,0xC0,  0x1}};
    
    /*#E = 3^97 + 3^49 + 1*/
    static Element ec_order = {{0x1,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0},
        {0x0,0x0,0x0,0x0, 0x0,0x0,0x2,0x0, 0x0,0x0,0x0,0x0, 0x2}};
    Element k1 = {{0x0,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0},
        {0x6,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0,0x0,0x0,0x0, 0x0}};
    BigInt k2 =  {0x7,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0};
    uint32_t start, end;
    uint32_t ctr_c;
    
    void testing()
    {
    
    Element sk;
    CpElement sig;
    Point p,q,p1,q1;
    UInt k;
    time_msg *tmsg;
    message_t packet1;
    BigInt r;
    Element g;
    int i;
    
    tmsg = (time_msg*)call Packet.getPayload(&packet1, sizeof(time_msg));
    if (tmsg == NULL) {return;}
    if (call Packet.maxPayloadLength() < sizeof(time_msg)) {
        return;
    }
    
    p.x = c_a;
    p.y = c_c;
    q.x = c_b;
    q.y = c_d;
    
    tmsg->t1=0;
    tmsg->t2=0;
    tmsg->t3=0;
    tmsg->result=1;
    for(i=0;i<100;i++){
        /*
         ExtElement2 exteltm;
         call GetRandom.generator(&p1);
         call GetRandom.generator(&q1);
         start = call Counter.get();
         call Pairing.pairing(&p1, &q1, &exteltm);
         end = call Counter.get();
         tmsg->t1+=end-start;
         */
        /*
         UInt msg[16];
         CpElement cp;
         call GetRandom.bigint(r);
         memcpy(msg, r, sizeof(msg));
         c
         start = call Counter.get();
         call PointArith.cps(&p1, cp);
         end = call Counter.get();
         tmsg->t2+=end-start;
         
         start = call Counter.get();
         call PointArith.dcps(cp, &q1);
         end = call Counter.get();
         tmsg->t3+=end-start;
         
         if(memcmp(&p1,&q1,ELEMENT_LEN*4)!=0)
         tmsg->result=0;
         */
        // point multiplication
        call GetRandom.bigint(r);
        //call GetRandom.elmt(&g);
        
        start = call Counter.get();
        call PointArith.mult_proj2(r, &p, &p1);
        end = call Counter.get();
        tmsg->t1+=end-start;
        
        start = call Counter.get();
        call PointArith.mult2(r, &p, &q1);
        end = call Counter.get();
        tmsg->t3+=end-start;
        
        /*
         start = call Counter.get();
         call PointArith.mult_proj(&g, &p, &p1);
         end = call Counter.get();
         tmsg->t2+=end-start;
         */
        
    }
    
    tmsg->t4=0;
    tmsg->overflow=ctr_c;
    tmsg->result=1;
    
    if(call SerialSend.send(AM_BROADCAST_ADDR, &packet1, sizeof(time_msg))==SUCCESS)
        call Leds.led2Toggle();
    
    }
    
    void testing2(){
        BigInt r;
        Point p,p1,q,q1;
        
        p.x = c_a;
        p.y = c_c;
        p1.x = c_b;
        p1.y = c_d;
        call GetRandom.bigint(r);
        call PointArith.mult2(r, &p1, &q);
        call PointArith.mult_proj2(r, &p1, &q1);
        
        if(memcmp(&q,&q1,ELEMENT_LEN*4)==0)
            dbg("Output", "Test succeed!\n");
        else
            dbg("Output", "Test failed!\n");
        
    }
    event void Boot.booted()
    {
    call SplitControl.start();
    //testing2();
    }
    
    event void SplitControl.startDone(error_t err) {
        if (err == SUCCESS) {
            testing();
        }
    }
    
    event void SplitControl.stopDone(error_t err) {}
    
    event void SerialSend.sendDone(message_t* bufPtr, error_t error) {}
    
    async event void Counter.overflow(){
        ctr_c++;
    }
    
    async event void Alarm.fired(){
        
    }
    
}
