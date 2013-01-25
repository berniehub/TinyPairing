/*
 * This file is to provide a 32-bit Milli Time Couter (1 sec = 1024 millli)
 * Implemenation for Mica platform is providede
 * If running the code on other sensor platoforms, additional wiring implementation is needed.
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */


configuration TimeCounterMilli32P
{
    provides interface Counter<TMilli, uint32_t>;
    provides interface Alarm<TMilli, uint32_t>;
}

//Mica
implementation
{
    components AlarmCounterMilliP, MainC;
    
    Counter = AlarmCounterMilliP;
    Alarm = AlarmCounterMilliP;
    MainC.SoftwareInit -> AlarmCounterMilliP;
}
