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


configuration BB_SSC{
    provides interface BB_SS;
}

implementation
{
    components PairingC, BB_SSM, GetRandomC, NNM;
    
    BB_SS = BB_SSM;
    
    BB_SSM.GetRandom -> GetRandomC;
    BB_SSM.BaseField -> PairingC;
    BB_SSM.ExtField2 -> PairingC;
    BB_SSM.PointArith -> PairingC;
    BB_SSM.Pairing -> PairingC;
    BB_SSM.NN -> NNM;
    
}