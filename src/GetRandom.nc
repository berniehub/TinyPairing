/**
 * This file defines interface for random bytes, and random base field element generation.
 * It is dependent on RandomLfsrC.
 *
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Sep, 2009
 */

#include "crypto.h"

interface GetRandom{
    /*
     * get a random base filed element
     */
    command void elmt(Element* re);
    
    /*
     * get a random large interger and stored in a BigInt type
     */
    command void bigint(BigInt bi);
    
    /*
     * get a random generator point
     */
    command void generator(Point* generator);
}