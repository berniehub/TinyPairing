/**
 *
 * This file provides configuration for BLS Short Signature
 * The version is the general version, in the way that all random numbers are represented and operated as large integers.
 * Conversions from and to trinary representation are needed.
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */


configuration BLS_SSC{
    provides interface BLS_SS;
}

implementation
{
    components PairingC, BLS_SSM, GetRandomC;
    
    BLS_SS = BLS_SSM;
    
    BLS_SSM.GetRandom -> GetRandomC;
    BLS_SSM.BaseField -> PairingC;
    BLS_SSM.ExtField2 -> PairingC;
    BLS_SSM.PointArith -> PairingC;
    BLS_SSM.Pairing -> PairingC;
    
}