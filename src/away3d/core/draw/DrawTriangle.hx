package away3d.core.draw;

    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.render.*;
    import away3d.materials.*;
    
    import flash.display.*;
    import flash.geom.Matrix;
    
    use namespace arcane;
    
    /**
    * Triangle drawing primitive
    */
    class DrawTriangle extends DrawPrimitive {
		/** @private */
        public function new() {
        _invtexmapping = new Matrix();
        backface = false;
        }
        
		/** @private */
        arcane function acuteAngled():Bool
        {
            d01 = v0.distanceSqr(v1);
            d12 = v1.distanceSqr(v2);
            d20 = v2.distanceSqr(v0);
            dd01 = d01 * d01;
            dd12 = d12 * d12;
            dd20 = d20 * d20;
            
            return (dd01 <= dd12 + dd20) && (dd12 <= dd20 + dd01) && (dd20 <= dd01 + dd12);
        }
		/** @private */
        arcane function maxEdgeSqr():Float
        {
            return Math.max(Math.max(v0.distanceSqr(v1),
                                        v1.distanceSqr(v2)),
                                        v2.distanceSqr(v0));
        }
		/** @private */
        arcane function minEdgeSqr():Float
        {
            return Math.min(Math.min(v0.distanceSqr(v1),
                                        v1.distanceSqr(v2)),
                                        v2.distanceSqr(v0));
        }
		/** @private */
        arcane function maxDistortSqr(focus:Float):Float
        {
            return Math.max(Math.max(v0.distortSqr(v1, focus),
                                        v1.distortSqr(v2, focus)),
                                        v2.distortSqr(v0, focus));
        }
		/** @private */
        arcane function minDistortSqr(focus:Float):Float
        {
            return Math.min(Math.min(v0.distortSqr(v1, focus),
                                        v1.distortSqr(v2, focus)),
                                        v2.distortSqr(v0, focus));
        }
		/** @private */
        arcane function fivepointcut(v0:ScreenVertex, v01:ScreenVertex, v1:ScreenVertex, v12:ScreenVertex, v2:ScreenVertex, uv0:UV, uv01:UV, uv1:UV, uv12:UV, uv2:UV):Array<Dynamic>
        {
            if (v0.distanceSqr(v12) < v01.distanceSqr(v2))
            {
                return [
                    create(view, source, face, material,  v0, v01, v12,  uv0, uv01, uv12),
                    create(view, source, face, material, v01,  v1, v12, uv01,  uv1, uv12),
                    create(view, source, face, material,  v0, v12 , v2,  uv0, uv12, uv2)];
            }
            else
            {
                return [
                    create(view, source, face, material,   v0, v01,  v2,  uv0, uv01, uv2),
                    create(view, source, face, material,  v01,  v1, v12, uv01,  uv1, uv12),
                    create(view, source, face, material,  v01, v12,  v2, uv01, uv12, uv2)];
            }
        }
		/** @private */
        arcane function bisect(focus:Float):Array<Dynamic>
        {
            d01 = v0.distanceSqr(v1);
            d12 = v1.distanceSqr(v2);
            d20 = v2.distanceSqr(v0);

            if ((d12 >= d01) && (d12 >= d20))
                return bisect12(focus);
            else
            if (d01 >= d20)
                return bisect01(focus);
            else
                return bisect20(focus);
        }
		/** @private */
        arcane function distortbisect(focus:Float):Array<Dynamic>
        {
            d01 = v0.distortSqr(v1, focus),
            d12 = v1.distortSqr(v2, focus),
            d20 = v2.distortSqr(v0, focus);

            if ((d12 >= d01) && (d12 >= d20))
                return bisect12(focus);
            else
            if (d01 >= d20)
                return bisect01(focus);
            else
                return bisect20(focus);
        }
        
		var d01:Float;
        var d12:Float;
        var d20:Float;
        var dd01:Float;
        var dd12:Float;
        var dd20:Float;
        var materialWidth:Float;
        var materialHeight:Float;
        var _u0:Float;
        var _u1:Float;
        var _u2:Float;
        var _v0:Float;
        var _v1:Float;
        var _v2:Float;
        var focus:Float;
        var ax:Float;
        var ay:Float;
        var az:Float;
        var bx:Float;
        var by:Float;
        var bz:Float;
        var cx:Float;
        var cy:Float;
        var cz:Float;
        var azf:Float;
        var bzf:Float;
        var czf:Float;
        var faz:Float;
        var fbz:Float;
        var fcz:Float;
        var axf:Float;
        var bxf:Float;
        var cxf:Float;
        var ayf:Float;
        var byf:Float;
        var cyf:Float;
        var det:Float;
        var da:Float;
        var db:Float;
        var dc:Float;
		var au:Float;
        var av:Float;
        var bu:Float;
        var bv:Float;
        var cu:Float;
        var cv:Float;
        var v01:ScreenVertex;
        var v12:ScreenVertex;
        var v20:ScreenVertex;
        var uv01:UV;
        var uv12:UV;
        var uv20:UV;
        var _invtexmapping:Matrix ;
        
        function num(n:Float):Float
        {
            return int(n*1000)/1000;
        }
        
        function bisect01(focus:Float):Array<Dynamic>
        {
            var v01:ScreenVertex = ScreenVertex.median(v0, v1, focus),
                uv01:UV = UV.median(uv0, uv1);
            return [
                create(view, source, face, material, v2, v0, v01, uv2, uv0, uv01),
                create(view, source, face, material, v01, v1, v2, uv01, uv1, uv2) 
            ];
        }

        function bisect12(focus:Float):Array<Dynamic>
        {
            var v12:ScreenVertex = ScreenVertex.median(v1, v2, focus),
                uv12:UV = UV.median(uv1, uv2);
            return [
                create(view, source, face, material, v0, v1, v12, uv0, uv1, uv12),
                create(view, source, face, material, v12, v2, v0, uv12, uv2, uv0) 
            ];
        }

        function bisect20(focus:Float):Array<Dynamic>
        {
            var v20:ScreenVertex = ScreenVertex.median(v2, v0, focus),
                uv20:UV = UV.median(uv2, uv0);
            return [
                create(view, source, face, material, v1, v2, v20, uv1, uv2, uv20),
                create(view, source, face, material, v20, v0, v1, uv20, uv0, uv1) 
            ];                                                
        }
        
		/**
		 * The v0 screenvertex of the triangle primitive.
		 */
        public var v0:ScreenVertex;
        
		/**
		 * The v1 screenvertex of the triangle primitive.
		 */
        public var v1:ScreenVertex;
        
		/**
		 * The v2 screenvertex of the triangle primitive.
		 */
        public var v2:ScreenVertex;
        
		/**
		 * The uv0 uv coordinate of the triangle primitive.
		 */
        public var uv0:UV;
        
		/**
		 * The uv1 uv coordinate of the triangle primitive.
		 */
        public var uv1:UV;
        
		/**
		 * The uv2 uv coordinate of the triangle primitive.
		 */
        public var uv2:UV;
        
		/**
		 * The calulated area of the triangle primitive.
		 */
        public var area:Float;
        
    	/**
    	 * A reference to the face object used by the triangle primitive.
    	 */
        public var face:Face;
        
        public var generated:Bool;
        
    	/**
    	 * Indicates whether the face of the triangle primitive is facing away from the camera.
    	 */
        public var backface:Bool ;
        
    	/**
    	 * The bitmapData object used as the triangle primitive texture.
    	 */
        public var material:ITriangleMaterial;
        
		/**
		 * @inheritDoc
		 */
        public override function clear():Void
        {
            v0 = null;
            v1 = null;
            v2 = null;
            uv0 = null;
            uv1 = null;
            uv2 = null;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function render():Void
        {
            material.renderTriangle(this);
        }
        
        /**
        * Calculates from the uv coordinates the mapping matrix required to draw the triangle primitive.
        */
        public function transformUV(material:IUVMaterial):Matrix
        {
            materialWidth = material.width,
            materialHeight = material.height;
            
            if (uv0 == null || uv1 == null || uv2 == null)
                return null;

            _u0 = materialWidth * uv0._u;
            _u1 = materialWidth * uv1._u;
            _u2 = materialWidth * uv2._u;
            _v0 = materialHeight * (1 - uv0._v);
            _v1 = materialHeight * (1 - uv1._v);
            _v2 = materialHeight * (1 - uv2._v);
      
            // Fix perpendicular projections
            if ((_u0 == _u1 && _v0 == _v1) || (_u0 == _u2 && _v0 == _v2)) {
            	if (_u0 > 0.05)
                	_u0 -= 0.05;
                else
                	_u0 += 0.05;
                	
                if (_v0 > 0.07)           
                	_v0 -= 0.07;
                else
                	_v0 += 0.07;
            }
    
            if (_u2 == _u1 && _v2 == _v1) {
            	if (_u2 > 0.04)
                	_u2 -= 0.04;
                else
                	_u2 += 0.04;
                	
                if (_v2 > 0.06)           
                	_v2 -= 0.06;
                else
                	_v2 += 0.06;
            }
            
        	_invtexmapping.a = _u1 - _u0;
        	_invtexmapping.b = _v1 - _v0;
        	_invtexmapping.c = _u2 - _u0;
        	_invtexmapping.d = _v2 - _v0;
        	
            if (Std.is( material, BitmapMaterialContainer)) {
            	_invtexmapping.tx = _u0 - face.bitmapRect.x;
            	_invtexmapping.ty = _v0 - face.bitmapRect.y;
            } else {
            	_invtexmapping.tx = _u0;
            	_invtexmapping.ty = _v0;
            }
            
            return _invtexmapping;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function getZ(x:Float, y:Float):Float
        {
            focus = view.camera.focus;

            ax = v0.x;
            ay = v0.y;
            az = v0.z;
            bx = v1.x;
            by = v1.y;
            bz = v1.z;
            cx = v2.x;
            cy = v2.y;
            cz = v2.z;

            if ((ax == x) && (ay == y))
                return az;

            if ((bx == x) && (by == y))
                return bz;

            if ((cx == x) && (cy == y))
                return cz;

            azf = az / focus;
            bzf = bz / focus;
            czf = cz / focus;

            faz = 1 + azf;
            fbz = 1 + bzf;
            fcz = 1 + czf;

            axf = ax*faz - x*azf;
            bxf = bx*fbz - x*bzf;
            cxf = cx*fcz - x*czf;
            ayf = ay*faz - y*azf;
            byf = by*fbz - y*bzf;
            cyf = cy*fcz - y*czf;

            det = axf*(byf - cyf) + bxf*(cyf - ayf) + cxf*(ayf - byf);
            da = x*(byf - cyf) + bxf*(cyf - y) + cxf*(y - byf);
            db = axf*(y - cyf) + x*(cyf - ayf) + cxf*(ayf - y);
            dc = axf*(byf - y) + bxf*(y - ayf) + x*(ayf - byf);

            return (da*az + db*bz + dc*cz) / det;
        }
		
		/**
		 * Calulates the uv value of a precise point on the drawing primitive.
		 * Used to determine the mouse position in interactive materials.
		 * 
		 * @param	x	The x position of the point to be tested.
		 * @param	y	The y position of the point to be tested.
		 * @return		The uv value.
		 */
        public function getUV(x:Float, y:Float):UV
        {
            if (uv0 == null)
                return null;

            if (uv1 == null)
                return null;

            if (uv2 == null)
                return null;

            au = uv0._u;
            av = uv0._v;
            bu = uv1._u;
            bv = uv1._v;
            cu = uv2._u;
            cv = uv2._v;

            focus = view.camera.focus;

            ax = v0.x;
            ay = v0.y;
            az = v0.z;
            bx = v1.x;
            by = v1.y;
            bz = v1.z;
            cx = v2.x;
            cy = v2.y;
            cz = v2.z;

            if ((ax == x) && (ay == y))
                return uv0;

            if ((bx == x) && (by == y))
                return uv1;

            if ((cx == x) && (cy == y))
                return uv2;

            azf = az / focus;
            bzf = bz / focus;
            czf = cz / focus;

            faz = 1 + azf;
            fbz = 1 + bzf;
            fcz = 1 + czf;
                                
            axf = ax*faz - x*azf;
            bxf = bx*fbz - x*bzf;
            cxf = cx*fcz - x*czf;
            ayf = ay*faz - y*azf;
            byf = by*fbz - y*bzf;
            cyf = cy*fcz - y*czf;

            det = axf*(byf - cyf) + bxf*(cyf - ayf) + cxf*(ayf - byf);
            da = x*(byf - cyf) + bxf*(cyf - y) + cxf*(y- byf);
            db = axf*(y - cyf) + x*(cyf - ayf) + cxf*(ayf - y);
            dc = axf*(byf - y) + bxf*(y - ayf) + x*(ayf - byf);

            return new UV((da*au + db*bu + dc*cu) / det, (da*av + db*bv + dc*cv) / det);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function quarter(focus:Float):Array<Dynamic>
        {
            if (area < 20)
                return null;

            v01 = ScreenVertex.median(v0, v1, focus);
            v12 = ScreenVertex.median(v1, v2, focus);
            v20 = ScreenVertex.median(v2, v0, focus);
            uv01 = UV.median(uv0, uv1);
            uv12 = UV.median(uv1, uv2);
            uv20 = UV.median(uv2, uv0);

            return [
                create(view, source, face, material, v0, v01, v20, uv0, uv01, uv20),
                create(view, source, face, material, v1, v12, v01, uv1, uv12, uv01),
                create(view, source, face, material, v2, v20, v12, uv2, uv20, uv12),
                create(view, source, face, material, v01, v12, v20, uv01, uv12, uv20)
            ];
        }
        
		/**
		 * @inheritDoc
		 */
        public override function contains(x:Float, y:Float):Bool
        {   
            if (v0.x*(y - v1.y) + v1.x*(v0.y - y) + x*(v1.y - v0.y) < -0.001)
                return false;

            if (v0.x*(v2.y - y) + x*(v0.y - v2.y) + v2.x*(y - v0.y) < -0.001)
                return false;

            if (x*(v2.y - v1.y) + v1.x*(y - v2.y) + v2.x*(v1.y - y) < -0.001)
                return false;

            return true;
        }

        public function distanceToCenter(x:Float, y:Float):Float
        {   
            var centerx:Int = (v0.x + v1.x + v2.x) / 3,
                centery:Int = (v0.y + v1.y + v2.y) / 3;

            return Math.sqrt((centerx-x)*(centerx-x) + (centery-y)*(centery-y));
        }
        
		/**
		 * @inheritDoc
		 */
        public override function calc():Void
        {
        	if (v0.x > v1.x) {
                if (v0.x > v2.x) maxX = v0.x;
                else maxX = v2.x;
            } else {
                if (v1.x > v2.x) maxX = v1.x;
                else maxX = v2.x;
            }
            
            if (v0.x < v1.x) {
                if (v0.x < v2.x) minX = v0.x;
                else minX = v2.x;
            } else {
                if (v1.x < v2.x) minX = v1.x;
                else minX = v2.x;
            }
            
            if (v0.y > v1.y) {
                if (v0.y > v2.y) maxY = v0.y;
                else maxY = v2.y;
            } else {
                if (v1.y > v2.y) maxY = v1.y;
                else maxY = v2.y;
            }
            
            if (v0.y < v1.y) {
                if (v0.y < v2.y) minY = v0.y;
                else minY = v2.y;
            } else {
                if (v1.y < v2.y) minY = v1.y;
                else minY = v2.y;
            }
            
            if (v0.z > v1.z) {
                if (v0.z > v2.z) maxZ = v0.z;
                else maxZ = v2.z;
            } else {
                if (v1.z > v2.z) maxZ = v1.z;
                else maxZ = v2.z;
            }
            
            if (v0.z < v1.z) {
                if (v0.z < v2.z) minZ = v0.z;
                else minZ = v2.z;
            } else {
                if (v1.z < v2.z) minZ = v1.z;
                else minZ = v2.z;
            }
            
            screenZ = (v0.z + v1.z + v2.z) / 3;
            area = 0.5 * (v0.x*(v2.y - v1.y) + v1.x*(v0.y - v2.y) + v2.x*(v1.y - v0.y));
        }
        
		/**
		 * @inheritDoc
		 */
        public override function toString():String
        {
            var color:String = "";
            if (Std.is( material, WireColorMaterial))
            {
                switch ((cast( material, WireColorMaterial)).color)
                {
                    case 0x00FF00: color = "green"; break;
                    case 0xFFFF00: color = "yellow"; break;
                    case 0xFF0000: color = "red"; break;
                    case 0x0000FF: color = "blue"; break;
                }
            }
            return "T{"+color+int(area)+" screenZ = " + num(screenZ) + ", minZ = " + num(minZ) + ", maxZ = " + num(maxZ) + " }";
        }
    }
