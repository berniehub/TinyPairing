/**
 *
 * Sample code for running BLS Short Signature
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "TimeSerial.h"

configuration test_BLS_SS_optC
{
}

implementation
{
    components MainC, test_BLS_SS_optM, LedsC, BLS_SS_optC, SerialActiveMessageC, RandomLfsrC;
    components TimeCounterMilli32P;
    
    test_BLS_SS_optM.Boot -> MainC;
    test_BLS_SS_optM.Leds -> LedsC;
    test_BLS_SS_optM.BLS_SS_opt -> BLS_SS_optC;
    
    test_BLS_SS_optM.SplitControl -> SerialActiveMessageC;
    test_BLS_SS_optM.SerialSend -> SerialActiveMessageC.AMSend[AM_TIME_SERIAL_MSG];
    test_BLS_SS_optM.Packet -> SerialActiveMessageC;
    
    test_BLS_SS_optM.Counter -> TimeCounterMilli32P;
    test_BLS_SS_optM.Alarm -> TimeCounterMilli32P;
    test_BLS_SS_optM.Random -> RandomLfsrC;
    
}
