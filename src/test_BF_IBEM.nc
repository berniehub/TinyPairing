/**
 *
 * Sample code for BF Identity-Based Encryption opt version
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "TimeSerial.h"

module test_BF_IBEM{
    uses interface Boot;
    uses interface Leds;
    uses interface BF_IBE;
    uses interface SplitControl;
    uses interface AMSend as SerialSend;
    uses interface Packet;
    
    uses interface Counter<TMilli, uint32_t>;
    uses interface Alarm<TMilli, uint32_t>;
}

implementation{
    
    
    uint8_t ctr_c;
    
    void testing()
    {
    uint32_t start, end;
    Point pk,dID,C0, generator;
    BigInt mk;
    CpElement sig;
    UInt msg[8] = "abcdefgh";
    UInt C1[8];
    UInt dmsg[8];
    UInt ID[8] ="12345678";
    int8_t result;
    time_msg *tmsg;
    message_t packet1;
    UInt i;
    
    tmsg = (time_msg*)call Packet.getPayload(&packet1, sizeof(time_msg));
    if (tmsg == NULL) {return;}
    if (call Packet.maxPayloadLength() < sizeof(time_msg)) {
        return;
    }
    
    tmsg->t1=0;
    tmsg->t2=0;
    tmsg->t3=0;
    tmsg->t4=0;
    ctr_c=0;
    for(i=0;i<10;i++){
        start = call Counter.get();
        call BF_IBE.setup(&generator, mk, &pk);
        end = call Counter.get();
        tmsg->t1 += end - start;
        
        start = call Counter.get();
        call BF_IBE.keyextract(ID, sizeof(ID), mk, &dID);
        end = call Counter.get();
        tmsg->t2 += end - start;
        
        start = call Counter.get();
        call BF_IBE.encrypt(&generator, &pk, msg, sizeof(msg), ID, sizeof(ID), &C0, C1);
        end = call Counter.get();
        tmsg->t3 += end - start;
        
        start = call Counter.get();
        call BF_IBE.decrypt(&dID, &C0, C1, sizeof(C1), dmsg);
        end = call Counter.get();
        tmsg->t4 += end - start;
    }
    
    if(memcmp(msg, dmsg, sizeof(msg))==0)
        result=1;
    else
        result=0;
    
    tmsg->overflow=ctr_c;
    tmsg->result=result;
    
    if(call SerialSend.send(AM_BROADCAST_ADDR, &packet1, sizeof(time_msg))==SUCCESS)
        call Leds.led2Toggle();
    
    }
    
    
    event void Boot.booted()
    {
    call SplitControl.start();
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