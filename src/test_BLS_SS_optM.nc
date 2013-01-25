/**
 *
 * Sample code for BLS Short Signature
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2008
 */
#include "crypto.h"
#include "TimeSerial.h"

module test_BLS_SS_optM
{
    uses interface Boot;
    uses interface Leds;
    uses interface BLS_SS_opt;
    uses interface SplitControl;
    uses interface AMSend as SerialSend;
    uses interface Packet;
    uses interface Random;
    
    uses interface Counter<TMilli, uint32_t>;
    uses interface Alarm<TMilli, uint32_t>;
    
}

implementation
{
    uint8_t ctr_c;
    
    void testing()
    {
    uint32_t start, end;
    Point pk,pp,generator;
    Element sk;
    CpElement sig;
    UInt msg[8] = "abcdegef";
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
        call BLS_SS_opt.keygen(&generator, &pk, &sk);
        end = call Counter.get();
        tmsg->t1 += end - start;
        
        start = call Counter.get();
        call BLS_SS_opt.sign(msg, sizeof(msg), &sk, sig);
        end = call Counter.get();
        tmsg->t2 += end - start;
        
        start = call Counter.get();
        result = call BLS_SS_opt.verify(&generator, &pk, msg, sizeof(msg), sig);
        end = call Counter.get();
        tmsg->t3 += end - start;
    }
    tmsg->t4=0;
    tmsg->overflow = ctr_c;
    tmsg->result = result;
    
    if(call SerialSend.send(AM_BROADCAST_ADDR, &packet1, sizeof(time_msg))==SUCCESS)
        call Leds.led2Toggle();
    
    //dbg("Output", "BLS_SS_opt test result: %d\n", result);
    
    }
    
    
    event void Boot.booted()
    {
    call SplitControl.start();
    //testing();
    }
    
    event void SplitControl.startDone(error_t err) {
        if (err == SUCCESS) {
            //dbg("test_BLS_SS_opt", "Start testing!\n");
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
