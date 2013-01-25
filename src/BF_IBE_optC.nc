/**
 *
 * This file provides configuration for BF IBE BassicIdent, which is IND-ID-CPA secure
 * The version is what we called opt version, in the way that all random numbers are represented and operated in field of characteristic three
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */

configuration BF_IBE_optC{
    provides interface BF_IBE_opt;
}

implementation{
    components BF_IBE_optM, PairingC, GetRandomC, SHA1M;
    
    BF_IBE_opt = BF_IBE_optM;
    
    BF_IBE_optM.BaseField -> PairingC;
    BF_IBE_optM.PointArith -> PairingC;
    BF_IBE_optM.Pairing -> PairingC;
    BF_IBE_optM.GetRandom -> GetRandomC;
    BF_IBE_optM.SHA1 -> SHA1M;
}