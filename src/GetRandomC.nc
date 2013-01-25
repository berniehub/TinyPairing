/**
 * This file provides configuration for random bytes, and random base field element generation.
 * It is dependent on RandomLfsrC.
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

configuration GetRandomC{
    provides interface GetRandom;
}

implementation{
    components GetRandomM, RandomLfsrC, PairingC, MainC;
    
    GetRandom = GetRandomM;
    GetRandomM.Random -> RandomLfsrC;
    GetRandomM.PointArith -> PairingC;
    MainC.SoftwareInit -> RandomLfsrC;
}