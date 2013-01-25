/**
 *
 * This file provides configuration for BLS Short Signature
 * The version is what we called opt version, in the way that all random numbers are represented and operated in field of characteristic three
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */

configuration BLS_SS_optC{
    provides interface BLS_SS_opt;
}

implementation
{
    components PairingC, BLS_SS_optM, GetRandomC;
    
    BLS_SS_opt = BLS_SS_optM;
    
    BLS_SS_optM.GetRandom -> GetRandomC;
    BLS_SS_optM.BaseField -> PairingC;
    BLS_SS_optM.ExtField2 -> PairingC;
    BLS_SS_optM.PointArith -> PairingC;
    BLS_SS_optM.Pairing -> PairingC;
    
}