/**
 * Author: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: Oct, 2008
 */

#include "crypto.h"

interface Pairing{
    
    /*
     * Compute the tate pairing value of two points P, Q
     * *E = tate pairing(*A, *B)
     */
    command void pairing(Point *P, Point *Q, ExtElement2 *E);
}
