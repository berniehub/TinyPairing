/**
 *
 * Sample code for BF Identity-Based Encryption opt version
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "TimeSerial.h"



configuration test_BF_IBEC{
}

implementation{
    components MainC, test_BF_IBEM, LedsC, BF_IBEC, SerialActiveMessageC;
    components TimeCounterMilli32P;
    
    test_BF_IBEM.Boot -> MainC;
    test_BF_IBEM.Leds -> LedsC;
    test_BF_IBEM.BF_IBE -> BF_IBEC;
    
    test_BF_IBEM.SplitControl -> SerialActiveMessageC;
    test_BF_IBEM.SerialSend -> SerialActiveMessageC.AMSend[AM_TIME_SERIAL_MSG];
    test_BF_IBEM.Packet -> SerialActiveMessageC;
    
    test_BF_IBEM.Counter -> TimeCounterMilli32P;
    test_BF_IBEM.Alarm -> TimeCounterMilli32P;
    
}