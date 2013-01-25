/**
 * Authors: Xiaokang Xiong <xkxiong@gmail.com>
 * Date: May, 2009
 *
 */

#include "crypto.h"

interface PointArith{
    
    /*
     * Add two points P and Q
     * *R = *P + *Q
     */
    command void add(Point* P, Point *Q, Point *R);
    /*
     * Add two points using projective coordinate
     * The projective coordinates of second input point are (x,y,1), so here we use its affine coordinate.
     */
    command void add_proj(Point_proj* P, Point *Q, Point_proj *R);
    
    /*
     * Point scale multiplication k*P, where k is an element in base field to present an integer.
     * Since the order of the curve is #E = 3^m + 3^(m+1)/2 + 1,
     * it is reasonable to use an element in base field to store the scale multiplier k
     * *C = *k * *Q
     */
    command void mult(Element* k, Point *P, Point *R);
    command UInt mult2(BigInt bigInt, Point *P, Point *R);
    /*
     * Conduct scale multiplication of points, in which mulitplication is computed in coordinate forms
     * Scale multiplier k is in trinay representation, specifically a base field element
     */
    command UInt mult_proj(Element* k, Point *P, Point *R);
    
    /*
     * Conduct scale multiplication of points, in which mulitplication is computed in coordinate forms
     * Scale multiplier k is in binary representation, specifically a BigInt type
     */
    command UInt mult_proj2(BigInt bigInt, Point *P, Point *Q);
    /*
     * Compute trible of point P
     * *Q = 3 * *P
     */
    command void trip(Point* P, Point *Q);
    /*
     * Tripling a point in projective coordinates
     */
    command void trip_proj(Point_proj* P, Point_proj *Q);
    
    /*
     * This funtion maps an arbitrary message to a point on the elliptic curve
     * Return TURE if success, FALSE if fail
     */
    command bool map2point(UInt* msg, uint32_t len, Point* point);
    
    /*
     * This function compute the y coordinate, given the x coordinate
     * Return TURE if success, FALSE if fail
     */
    command bool get_y(Element* x, Element* y);
    
    /*
     * Compute double of point P
     * *Q = 2 * *P
     */
    command void doub(Point* P, Point *Q);
    
    /*
     * compute opposite of point P
     * *Q = -(*P)p
     */
    command void neg(Point *P, Point *Q);
    
    
    /*
     * Compress a point to a CpPoint
     */
    command bool cps(Point* p, CpElement cp);
    
    /*
     * Decompress a CpPoint
     */
    command bool dcps(CpElement cp, Point *p);
}
