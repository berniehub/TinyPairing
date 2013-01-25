/**
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "TimeSerial.h"

configuration PairingTestC
{
}

implementation
{
    components MainC, PairingTestM, PairingC, LedsC, SerialActiveMessageC, GetRandomC;
    components TimeCounterMilli32P;
    
    PairingTestM.Boot -> MainC;
    PairingTestM.BaseField -> PairingC.BaseField;
    PairingTestM.ExtField2 -> PairingC.ExtField2;
    PairingTestM.PointArith -> PairingC.PointArith;
    PairingTestM.Pairing -> PairingC.Pairing;
    PairingTestM.Leds -> LedsC;
    PairingTestM.GetRandom -> GetRandomC;
    
    PairingTestM.SplitControl -> SerialActiveMessageC;
    PairingTestM.SerialSend -> SerialActiveMessageC.AMSend[AM_TIME_SERIAL_MSG];
    PairingTestM.Packet -> SerialActiveMessageC;
    
    PairingTestM.Counter -> TimeCounterMilli32P;
    PairingTestM.Alarm -> TimeCounterMilli32P;
    
    
}
