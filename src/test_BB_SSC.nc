/**
 *
 * Sample code for running BLS Short Signature
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "TimeSerial.h"

configuration test_BB_SSC
{
}

implementation
{
    components MainC, test_BB_SSM, LedsC, BB_SSC, SerialActiveMessageC, GetRandomC;
    components TimeCounterMilli32P;
    
    test_BB_SSM.Boot -> MainC;
    test_BB_SSM.Leds -> LedsC;
    test_BB_SSM.BB_SS -> BB_SSC;
    
    test_BB_SSM.SplitControl -> SerialActiveMessageC;
    test_BB_SSM.SerialSend -> SerialActiveMessageC.AMSend[AM_TIME_SERIAL_MSG];
    test_BB_SSM.Packet -> SerialActiveMessageC;
    
    test_BB_SSM.Counter -> TimeCounterMilli32P;
    test_BB_SSM.Alarm -> TimeCounterMilli32P;
    
}
