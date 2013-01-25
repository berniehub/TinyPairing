/**
 *
 * Sample code for running BLS Short Signature
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "TimeSerial.h"

configuration test_BLS_SSC
{
}

implementation
{
    components MainC, test_BLS_SSM, LedsC, BLS_SSC, SerialActiveMessageC;
    components TimeCounterMilli32P;
    
    test_BLS_SSM.Boot -> MainC;
    test_BLS_SSM.Leds -> LedsC;
    test_BLS_SSM.BLS_SS -> BLS_SSC;
    
    test_BLS_SSM.SplitControl -> SerialActiveMessageC;
    test_BLS_SSM.SerialSend -> SerialActiveMessageC.AMSend[AM_TIME_SERIAL_MSG];
    test_BLS_SSM.Packet -> SerialActiveMessageC;
    
    test_BLS_SSM.Counter -> TimeCounterMilli32P;
    test_BLS_SSM.Alarm -> TimeCounterMilli32P;
    
}
