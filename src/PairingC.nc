/*
 * Configration file for Bilinear Pairing library
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

configuration PairingC{
    provides interface Pairing;
    provides interface BaseField;
    provides interface ExtField2;
    provides interface PointArith;
}

implementation
{
    components BaseFieldM, ExtField2M, PointArithM, PairingM, SHA1M, NNM;
    
    Pairing = PairingM;
    BaseField = BaseFieldM;
    ExtField2 = ExtField2M;
    PointArith = PointArithM;
    
    ExtField2M.BaseField -> BaseFieldM.BaseField;
    
    PointArithM.BaseField -> BaseFieldM.BaseField;
    PointArithM.SHA1 -> SHA1M.SHA1;
    PointArithM.NN -> NNM;
    
    PairingM.BaseField -> BaseFieldM.BaseField;
    PairingM.ExtField2 -> ExtField2M.ExtField2;
    
}