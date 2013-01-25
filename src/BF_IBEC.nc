/**
 *
 * This file provides configuration for BF IBE BassicIdent, which is IND-ID-CPA secure
 * The version is the general version, in the way that all random numbers are represented and operated as large integers.
 * Conversions from and to trinary representation are needed.
 *
 *
 * Author: Xiaokang Xiong (xkxiong@gmail.com)
 * Date: Jul, 2009
 */

configuration BF_IBEC{
    provides interface BF_IBE;
}

implementation{
    components BF_IBEM, PairingC, GetRandomC, SHA1M;
    
    BF_IBE = BF_IBEM;
    
    BF_IBEM.BaseField -> PairingC;
    BF_IBEM.PointArith -> PairingC;
    BF_IBEM.Pairing -> PairingC;
    BF_IBEM.GetRandom -> GetRandomC;
    BF_IBEM.SHA1 -> SHA1M;
}