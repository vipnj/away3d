package away3d.core.render
{
    import flash.display.*;
    import flash.utils.*;

    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.proto.*;
    import away3d.core.render.*;

    /** Filter for correct triangle z-sorting */
    public class AnotherRivalFilter implements IPrimitiveQuadrantFilter
    {
        public var maxdelay:int;
    
        public function AnotherRivalFilter(maxdelay:int = 60000)
        {
            this.maxdelay = maxdelay;
        }
    
        public function filter(tree:PrimitiveQuadrantTree, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            var start:int = getTimer();
            var check:int = 0;
    
            var primitives:Array = tree.list();
            var turn:int = 0;
            while (primitives.length > 0)
            {
                var leftover:Array = new Array();
                for each (var pri:DrawPrimitive in primitives)
                {
                    check++;
                    if (check == 10)
                        if (getTimer() - start > maxdelay)
                            return;
                        else
                            check = 0;
    
                    var maxZ:Number = pri.maxZ + 1000;
                    var minZ:Number = pri.minZ - 1000;
                    var maxdeltaZ:Number = 0;
                    var rivals:Array = tree.get(pri.minX, pri.minY, pri.maxX, pri.maxY, null);
                    for each (var rival:DrawPrimitive in rivals)
                    {
                        if (rival == pri)
                            continue;
    
                        switch (zconflict(pri, rival))
                        {
                            case ZOrderIrrelevant:
                                break;
                            case ZOrderDeeper:
                                minZ = Math.max(minZ, rival.screenZ);
                                break;
                            case ZOrderHigher:
                                maxZ = Math.min(maxZ, rival.screenZ);
                                break;
                        }
                    }
                    if ((maxZ >= pri.screenZ) && (pri.screenZ >= minZ))
                    {
                        // ok
                    }
                    else
                    if ((maxZ > minZ))
                    {
                        pri.screenZ = (maxZ + minZ) / 2;
                    }
                    else
                    {
                        if (turn % 3 == 2)
                        {
                            var parts:Array = pri.quarter(camera.focus);
                            
                            if (parts != null)
                            {
                                tree.remove(pri);
                                for each (var part:DrawPrimitive in parts)
                                {
                                    part.screenZ = pri.screenZ;
                                    leftover.push(part);
                                    tree.push(part);
                                }
                            }
                        }
                        else
                            leftover.push(pri);
                    }
                }
                primitives = leftover;
                turn += 1;
                if (turn == 20)
                    break;
            }
        }
    
        private static var ZOrderDeeper:int = 1;
        private static var ZOrderIrrelevant:int = 0;
        private static var ZOrderHigher:int = -1;
        private static var ZOrderSame:int = 0;
    
        public static function zconflict(q:DrawPrimitive, w:DrawPrimitive):int
        {
            if (q is DrawTriangle)
            { 
                if (w is DrawTriangle)
                    return zconflictTT(q as DrawTriangle, w as DrawTriangle);
                if (w is DrawSegment)
                    return zconflictTS(q as DrawTriangle, w as DrawSegment);
                if (q is DrawScaledBitmap)
                    return zconflictTB(q as DrawTriangle, w as DrawScaledBitmap);
            }
            else
            if (q is DrawSegment)
            {
                if (w is DrawTriangle)
                    return -zconflictTS(w as DrawTriangle, q as DrawSegment);
            }
            else
            if (q is DrawScaledBitmap)
            {
                if (w is DrawTriangle)
                    return -zconflictTB(w as DrawTriangle, q as DrawScaledBitmap);
                if (w is DrawScaledBitmap)
                    return zconflictBB(q as DrawScaledBitmap, w as DrawScaledBitmap);
            }
            return ZOrderIrrelevant;
        }
    
        private static function zconflictBB(q:DrawScaledBitmap, r:DrawScaledBitmap):int
        {
            if (q.screenZ > r.screenZ)
                return ZOrderDeeper;
            if (q.screenZ < r.screenZ)
                return ZOrderHigher;
    
            return ZOrderSame;
        }

        private static function zconflictTB(q:DrawTriangle, r:DrawScaledBitmap):int
        {
            if (q.contains(r.v.x, r.v.y))
                return zcompare(q, r, r.v.x, r.v.y);
            else
            if (q.contains(r.minX, r.minY))
                return zcompare(q, r, r.minX, r.minY);
            else
            if (q.contains(r.minX, r.maxY))
                return zcompare(q, r, r.minX, r.maxY);
            else
            if (q.contains(r.maxX, r.minY))
                return zcompare(q, r, r.maxX, r.minY);
            else
            if (q.contains(r.maxX, r.maxY))
                return zcompare(q, r, r.maxX, r.maxY);
            else
                return ZOrderIrrelevant;
        }

        private static function zconflictTS(q:DrawTriangle, r:DrawSegment):int
        {
        /*
            if (q == null)
                return ZOrderIrrelevant;
            if (r == null)
                return ZOrderIrrelevant;
        */
            var q0x:Number = q.v0.x;
            var q0y:Number = q.v0.y;
            var q1x:Number = q.v1.x;
            var q1y:Number = q.v1.y;
            var q2x:Number = q.v2.x;
            var q2y:Number = q.v2.y;
    
            var r0x:Number = r.v0.x;
            var r0y:Number = r.v0.y;
            var r1x:Number = r.v1.x;
            var r1y:Number = r.v1.y;
    
            var ql01a:Number = q1y - q0y;
            var ql01b:Number = q0x - q1x;
            var ql01c:Number = -(ql01b*q0y + ql01a*q0x);
            var ql01s:Number = ql01a*q2x + ql01b*q2y + ql01c;
            var ql01r0:Number = (ql01a*r0x + ql01b*r0y + ql01c) * ql01s;
            var ql01r1:Number = (ql01a*r1x + ql01b*r1y + ql01c) * ql01s;
    
            if ((ql01r0 <= 0.0001) && (ql01r1 <= 0.0001))
                return ZOrderIrrelevant;
    
            var ql12a:Number = q2y - q1y;
            var ql12b:Number = q1x - q2x;
            var ql12n:Boolean = (ql12a*ql12a + ql12b*ql12b) > 0.0001;
            var ql12c:Number = -(ql12b*q1y + ql12a*q1x);
            var ql12s:Number = ql12a*q0x + ql12b*q0y + ql12c;
            var ql12r0:Number = (ql12a*r0x + ql12b*r0y + ql12c) * ql12s;
            var ql12r1:Number = (ql12a*r1x + ql12b*r1y + ql12c) * ql12s;
    
            if ((ql12r0 <= 0.0001) && (ql12r1 <= 0.0001))
                return ZOrderIrrelevant;
    
            var ql20a:Number = q0y - q2y;
            var ql20b:Number = q2x - q0x;
            var ql20c:Number = -(ql20b*q2y + ql20a*q2x);
            var ql20s:Number = ql20a*q1x + ql20b*q1y + ql20c;
            var ql20r0:Number = (ql20a*r0x + ql20b*r0y + ql20c) * ql20s;
            var ql20r1:Number = (ql20a*r1x + ql20b*r1y + ql20c) * ql20s;
    
            if ((ql20r0 <= 0.0001) && (ql20r1 <= 0.0001))
                return ZOrderIrrelevant;
    
            var rla:Number = r1y - r0y;
            var rlb:Number = r0x - r1x;
            var rlc:Number = -(rlb*r0y + rla*r0x);
            var rlq0:Number = (rla*q0x + rlb*q0y + rlc);
            var rlq1:Number = (rla*q1x + rlb*q1y + rlc);
            var rlq2:Number = (rla*q2x + rlb*q2y + rlc);
    
            if ((rlq0*rlq1 >= 0.0001) && (rlq1*rlq2 >= 0.0001) && (rlq2*rlq0 >= 0.0001))
                return ZOrderIrrelevant;
    
            if (((ql01r0 > -0.0001) && (ql12r0 > -0.0001) && (ql20r0 > -0.0001))
             && ((ql01r1 > -0.0001) && (ql12r1 > -0.0001) && (ql20r1 > -0.0001)))
            {
                return zcompare(q, r, (r0x+r1x)/2, (r0y+r1y)/2);
            }
    
            var q01r:Boolean = ((rlq0*rlq1 < 0.0001) && (ql01r0*ql01r1 < 0.0001));
            var q12r:Boolean = ((rlq1*rlq2 < 0.0001) && (ql12r0*ql12r1 < 0.0001));
            var q20r:Boolean = ((rlq2*rlq0 < 0.0001) && (ql20r0*ql20r1 < 0.0001));
    
            var q01rx:Number;
            var q01ry:Number;
            var q12rx:Number;
            var q12ry:Number;
            var q20rx:Number;
            var q20ry:Number;
            var count:int = 0;
            var cx:Number = 0;
            var cy:Number = 0;
    
            if ((ql01r0 > 0.0001) && (ql12r0 > 0.0001) && (ql20r0 > 0.0001))
            {
                cx += r0x;
                cy += r0y;
                count += 1;
            }
    
            if ((ql01r1 > 0.0001) && (ql12r1 > 0.0001) && (ql20r1 > 0.0001))
            {
                cx += r1x;
                cy += r1y;
                count += 1;
            }
    
            if (q01r)
            { 
                var q01rd:Number = ql01a*rlb - ql01b*rla;
                if (q01rd*q01rd > 0.0001)
                {
                    q01rx = (ql01b*rlc - ql01c*rlb) / q01rd;
                    q01ry = (ql01c*rla - ql01a*rlc) / q01rd;
                    cx += q01rx;
                    cy += q01ry;
                    count += 1;
                }
            }
    
            if (q12r)
            { 
                var q12rd:Number = ql12a*rlb - ql12b*rla;
                if (q12rd*q12rd > 0.0001)
                {
                    q12rx = (ql12b*rlc - ql12c*rlb) / q12rd;
                    q12ry = (ql12c*rla - ql12a*rlc) / q12rd;
                    cx += q12rx;
                    cy += q12ry;
                    count += 1;
                }
            }
    
            if (q20r)
            { 
                var q20rd:Number = ql20a*rlb - ql20b*rla;
                if (q20rd*q20rd > 0.0001)
                {
                    q20rx = (ql20b*rlc - ql20c*rlb) / q20rd;
                    q20ry = (ql20c*rla - ql20a*rlc) / q20rd;
                    cx += q20rx;
                    cy += q20ry;
                    count += 1;
                }
            }
    
            return zcompare(q, r, cx / count, cy / count);
        }
    
        private static function zconflictTT(q:DrawTriangle, w:DrawTriangle):int
        {
            var q0x:Number = q.v0.x;
            var q0y:Number = q.v0.y;
            var q1x:Number = q.v1.x;
            var q1y:Number = q.v1.y;
            var q2x:Number = q.v2.x;
            var q2y:Number = q.v2.y;
    
            var w0x:Number = w.v0.x;
            var w0y:Number = w.v0.y;
            var w1x:Number = w.v1.x;
            var w1y:Number = w.v1.y;
            var w2x:Number = w.v2.x;
            var w2y:Number = w.v2.y;
    
            var ql01a:Number = q1y - q0y;
            var ql01b:Number = q0x - q1x;
            //var ql01n:Boolean = (ql01a*ql01a + ql01b*ql01b) > 0.0001;
            var ql01c:Number = -(ql01b*q0y + ql01a*q0x);
            var ql01s:Number = ql01a*q2x + ql01b*q2y + ql01c;
            var ql01w0:Number = (ql01a*w0x + ql01b*w0y + ql01c) * ql01s;
            var ql01w1:Number = (ql01a*w1x + ql01b*w1y + ql01c) * ql01s;
            var ql01w2:Number = (ql01a*w2x + ql01b*w2y + ql01c) * ql01s;
    
            //if (ql01n && (ql01s > 0.0001))
                if ((ql01w0 <= 0.0001) && (ql01w1 <= 0.0001) && (ql01w2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            var ql12a:Number = q2y - q1y;
            var ql12b:Number = q1x - q2x;
            var ql12n:Boolean = (ql12a*ql12a + ql12b*ql12b) > 0.0001;
            var ql12c:Number = -(ql12b*q1y + ql12a*q1x);
            var ql12s:Number = ql12a*q0x + ql12b*q0y + ql12c;
            var ql12w0:Number = (ql12a*w0x + ql12b*w0y + ql12c) * ql12s;
            var ql12w1:Number = (ql12a*w1x + ql12b*w1y + ql12c) * ql12s;
            var ql12w2:Number = (ql12a*w2x + ql12b*w2y + ql12c) * ql12s;
    
            //if (ql12n && (ql12s > 0.0001))
                if ((ql12w0 <= 0.0001) && (ql12w1 <= 0.0001) && (ql12w2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            var ql20a:Number = q0y - q2y;
            var ql20b:Number = q2x - q0x;
            //var ql20n:Boolean = (ql20a*ql20a + ql20b*ql20b) > 0.0001;
            var ql20c:Number = -(ql20b*q2y + ql20a*q2x);
            var ql20s:Number = ql20a*q1x + ql20b*q1y + ql20c;
            var ql20w0:Number = (ql20a*w0x + ql20b*w0y + ql20c) * ql20s;
            var ql20w1:Number = (ql20a*w1x + ql20b*w1y + ql20c) * ql20s;
            var ql20w2:Number = (ql20a*w2x + ql20b*w2y + ql20c) * ql20s;
    
            //if (ql20n && (ql20s > 0.0001))
                if ((ql20w0 <= 0.0001) && (ql20w1 <= 0.0001) && (ql20w2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            var wl01a:Number = w1y - w0y;
            var wl01b:Number = w0x - w1x;
            //var wl01n:Boolean = (wl01a*wl01a + wl01b*wl01b) > 0.0001;
            var wl01c:Number = -(wl01b*w0y + wl01a*w0x);
            var wl01s:Number = wl01a*w2x + wl01b*w2y + wl01c;
            var wl01q0:Number = (wl01a*q0x + wl01b*q0y + wl01c) * wl01s;
            var wl01q1:Number = (wl01a*q1x + wl01b*q1y + wl01c) * wl01s;
            var wl01q2:Number = (wl01a*q2x + wl01b*q2y + wl01c) * wl01s;
    
            //if (wl01n && (wl01s > 0.0001))
                if ((wl01q0 <= 0.0001) && (wl01q1 <= 0.0001) && (wl01q2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            var wl12a:Number = w2y - w1y;
            var wl12b:Number = w1x - w2x;
            //var wl12n:Boolean = (wl12a*wl12a + wl12b*wl12b) > 0.0001;
            var wl12c:Number = -(wl12b*w1y + wl12a*w1x);
            var wl12s:Number = wl12a*w0x + wl12b*w0y + wl12c;
            var wl12q0:Number = (wl12a*q0x + wl12b*q0y + wl12c) * wl12s;
            var wl12q1:Number = (wl12a*q1x + wl12b*q1y + wl12c) * wl12s;
            var wl12q2:Number = (wl12a*q2x + wl12b*q2y + wl12c) * wl12s;
    
            //if (wl12n  && (wl12s > 0.0001))
                if ((wl12q0 <= 0.0001) && (wl12q1 <= 0.0001) && (wl12q2 <= 0.0001))
                    return ZOrderIrrelevant;
    
            var wl20a:Number = w0y - w2y;
            var wl20b:Number = w2x - w0x;
            //var wl20n:Boolean = (wl20a*wl20a + wl20b*wl20b) > 0.0001;
            var wl20c:Number = -(wl20b*w2y + wl20a*w2x);
            var wl20s:Number = wl20a*w1x + wl20b*w1y + wl20c;
            var wl20q0:Number = (wl20a*q0x + wl20b*q0y + wl20c) * wl20s;
            var wl20q1:Number = (wl20a*q1x + wl20b*q1y + wl20c) * wl20s;
            var wl20q2:Number = (wl20a*q2x + wl20b*q2y + wl20c) * wl20s;
    
            //if (wl20n && (wl20s > 0.0001))
                if ((wl20q0 <= 0.0001) && (wl20q1 <= 0.0001) && (wl20q2 <= 0.0001))
                    return ZOrderIrrelevant;
            
            //if (wl01n && wl12n && wl20n)
                if (((wl01q0*wl01q0 <= 0.0001) || (wl12q0*wl12q0 <= 0.0001) || (wl20q0*wl20q0 <= 0.0001))
                 && ((wl01q1*wl01q1 <= 0.0001) || (wl12q1*wl12q1 <= 0.0001) || (wl20q1*wl20q1 <= 0.0001))
                 && ((wl01q2*wl01q2 <= 0.0001) || (wl12q2*wl12q2 <= 0.0001) || (wl20q2*wl20q2 <= 0.0001)))
                {
                    return zcompare(q, w, (q0x+q1x+q2x)/3, (q0y+q1y+q2y)/3);
                }
            
            //if (ql01n && ql12n && ql20n)
                if (((ql01w0*ql01w0 <= 0.0001) || (ql12w0*ql12w0 <= 0.0001) || (ql20w0*ql20w0 <= 0.0001))
                 && ((ql01w1*ql01w1 <= 0.0001) || (ql12w1*ql12w1 <= 0.0001) || (ql20w1*ql20w1 <= 0.0001))
                 && ((ql01w2*ql01w2 <= 0.0001) || (ql12w2*ql12w2 <= 0.0001) || (ql20w2*ql20w2 <= 0.0001)))
                {
                    return zcompare(q, w, (w0x+w1x+w2x)/3, (w0y+w1y+w2y)/3);
                }
    
            var q01w01:Boolean = ((wl01q0*wl01q1 < 0.0001) && (ql01w0*ql01w1 < 0.0001));
            var q12w01:Boolean = ((wl01q1*wl01q2 < 0.0001) && (ql12w0*ql12w1 < 0.0001));
            var q20w01:Boolean = ((wl01q2*wl01q0 < 0.0001) && (ql20w0*ql20w1 < 0.0001));
            var q01w12:Boolean = ((wl12q0*wl12q1 < 0.0001) && (ql01w1*ql01w2 < 0.0001));
            var q12w12:Boolean = ((wl12q1*wl12q2 < 0.0001) && (ql12w1*ql12w2 < 0.0001));
            var q20w12:Boolean = ((wl12q2*wl12q0 < 0.0001) && (ql20w1*ql20w2 < 0.0001));
            var q01w20:Boolean = ((wl20q0*wl20q1 < 0.0001) && (ql01w2*ql01w0 < 0.0001));
            var q12w20:Boolean = ((wl20q1*wl20q2 < 0.0001) && (ql12w2*ql12w0 < 0.0001));
            var q20w20:Boolean = ((wl20q2*wl20q0 < 0.0001) && (ql20w2*ql20w0 < 0.0001));
    
            var q01w01x:Number;
            var q01w01y:Number;
            var q12w01x:Number;
            var q12w01y:Number;
            var q20w01x:Number;
            var q20w01y:Number;
            var q01w12x:Number;
            var q01w12y:Number;
            var q12w12x:Number;
            var q12w12y:Number;
            var q20w12x:Number;
            var q20w12y:Number;
            var q01w20x:Number;
            var q01w20y:Number;
            var q12w20x:Number;
            var q12w20y:Number;
            var q20w20x:Number;
            var q20w20y:Number;
            var count:int = 0;
            var cx:Number = 0;
            var cy:Number = 0;
    
            if ((ql01w0 > 0.0001) && (ql12w0 > 0.0001) && (ql20w0 > 0.0001))
            {
                cx += w0x;
                cy += w0y;
                count += 1;
            }
    
            if ((ql01w1 > 0.0001) && (ql12w1 > 0.0001) && (ql20w1 > 0.0001))
            {
                cx += w1x;
                cy += w1y;
                count += 1;
            }
    
            if ((ql01w2 > 0.0001) && (ql12w2 > 0.0001) && (ql20w2 > 0.0001))
            {
                cx += w2x;
                cy += w2y;
                count += 1;
            }
    
            if ((wl01q0 > 0.0001) && (wl12q0 > 0.0001) && (wl20q0 > 0.0001))
            {
                cx += q0x;
                cy += q0y;
                count += 1;
            }
    
            if ((wl01q1 > 0.0001) && (wl12q1 > 0.0001) && (wl20q1 > 0.0001))
            {
                cx += q1x;
                cy += q1y;
                count += 1;
            }
    
            if ((wl01q2 > 0.0001) && (wl12q2 > 0.0001) && (wl20q2 > 0.0001))
            {
                cx += q2x;
                cy += q2y;
                count += 1;
            }
    
            if (q01w01)
            { 
                var q01w01d:Number = ql01a*wl01b - ql01b*wl01a;
                if (q01w01d*q01w01d > 0.0001)
                {
                    q01w01x = (ql01b*wl01c - ql01c*wl01b) / q01w01d;
                    q01w01y = (ql01c*wl01a - ql01a*wl01c) / q01w01d;
                    cx += q01w01x;
                    cy += q01w01y;
                    count += 1;
                }
            }
    
            if (q12w01)
            { 
                var q12w01d:Number = ql12a*wl01b - ql12b*wl01a;
                if (q12w01d*q12w01d > 0.0001)
                {
                    q12w01x = (ql12b*wl01c - ql12c*wl01b) / q12w01d;
                    q12w01y = (ql12c*wl01a - ql12a*wl01c) / q12w01d;
                    cx += q12w01x;
                    cy += q12w01y;
                    count += 1;
                }
            }
    
            if (q20w01)
            { 
                var q20w01d:Number = ql20a*wl01b - ql20b*wl01a;
                if (q20w01d*q20w01d > 0.0001)
                {
                    q20w01x = (ql20b*wl01c - ql20c*wl01b) / q20w01d;
                    q20w01y = (ql20c*wl01a - ql20a*wl01c) / q20w01d;
                    cx += q20w01x;
                    cy += q20w01y;
                    count += 1;
                }
            }
    
            if (q01w12)
            { 
                var q01w12d:Number = ql01a*wl12b - ql01b*wl12a;
                if (q01w12d*q01w12d > 0.0001)
                {
                    q01w12x = (ql01b*wl12c - ql01c*wl12b) / q01w12d;
                    q01w12y = (ql01c*wl12a - ql01a*wl12c) / q01w12d;
                    cx += q01w12x;
                    cy += q01w12y;
                    count += 1;
                }
            }
    
            if (q12w12)
            { 
                var q12w12d:Number = ql12a*wl12b - ql12b*wl12a;
                if (q12w12d*q12w12d > 0.0001)
                {
                    q12w12x = (ql12b*wl12c - ql12c*wl12b) / q12w12d;
                    q12w12y = (ql12c*wl12a - ql12a*wl12c) / q12w12d;
                    cx += q12w12x;
                    cy += q12w12y;
                    count += 1;
                }
            }
    
            if (q20w12)
            { 
                var q20w12d:Number = ql20a*wl12b - ql20b*wl12a;
                if (q20w12d*q20w12d > 0.0001)
                {
                    q20w12x = (ql20b*wl12c - ql20c*wl12b) / q20w12d;
                    q20w12y = (ql20c*wl12a - ql20a*wl12c) / q20w12d;
                    cx += q20w12x;
                    cy += q20w12y;
                    count += 1;
                }
            }
    
            if (q01w20)
            { 
                var q01w20d:Number = ql01a*wl20b - ql01b*wl20a;
                if (q01w20d*q01w20d > 0.0001)
                {
                    q01w20x = (ql01b*wl20c - ql01c*wl20b) / q01w20d;
                    q01w20y = (ql01c*wl20a - ql01a*wl20c) / q01w20d;
                    cx += q01w20x;
                    cy += q01w20y;
                    count += 1;
                }
            }
    
            if (q12w20)
            { 
                var q12w20d:Number = ql12a*wl20b - ql12b*wl20a;
                if (q12w20d*q12w20d > 0.0001)
                {
                    q12w20x = (ql12b*wl20c - ql12c*wl20b) / q12w20d;
                    q12w20y = (ql12c*wl20a - ql12a*wl20c) / q12w20d;
                    cx += q12w20x;
                    cy += q12w20y;
                    count += 1;
                }
            }
    
            if (q20w20)
            { 
                var q20w20d:Number = ql20a*wl20b - ql20b*wl20a;
                if (q20w20d*q20w20d > 0.0001)
                {
                    q20w20x = (ql20b*wl20c - ql20c*wl20b) / q20w20d;
                    q20w20y = (ql20c*wl20a - ql20a*wl20c) / q20w20d;
                    cx += q20w20x;
                    cy += q20w20y;
                    count += 1;
                }
            }
    
            return zcompare(q, w, cx / count, cy / count);
        }
    
        private static function zcompare(a:DrawPrimitive, b:DrawPrimitive, x:Number, y:Number):int
        {
            var az:Number = a.getZ(x, y);
            var bz:Number = b.getZ(x, y);
    
            if (az > bz)
                return ZOrderDeeper;
            if (az < bz)
                return ZOrderHigher;
    
            return ZOrderSame;
        }
    
        public function toString():String
        {
            return "AnotherRivalFilter" + ((maxdelay == 60000) ? "" : "("+maxdelay+"ms)");
        }
    }
}