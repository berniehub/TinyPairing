/**
 *
 * Sample code for BF Identity-Based Encryption opt version
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "TimeSerial.h"



configuration test_BF_IBE_optC{
}

implementation{
    components MainC, test_BF_IBE_optM, LedsC, BF_IBE_optC, SerialActiveMessageC;
    components TimeCounterMilli32P;
    
    test_BF_IBE_optM.Boot -> MainC;
    test_BF_IBE_optM.Leds -> LedsC;
    test_BF_IBE_optM.BF_IBE_opt -> BF_IBE_optC;
    
    test_BF_IBE_optM.SplitControl -> SerialActiveMessageC;
    test_BF_IBE_optM.SerialSend -> SerialActiveMessageC.AMSend[AM_TIME_SERIAL_MSG];
    test_BF_IBE_optM.Packet -> SerialActiveMessageC;
    
    test_BF_IBE_optM.Counter -> TimeCounterMilli32P;
    test_BF_IBE_optM.Alarm -> TimeCounterMilli32P;
    
}