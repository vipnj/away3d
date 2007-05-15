package away3d.extrusions
{
	import away3d.objects.*;
	import away3d.shapes.*;
	import away3d.core.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.material.*;
	import away3d.core.math.*;
	import away3d.core.proto.*;
	import away3d.core.render.*;
	
	import flash.geom.*;
    
    public class BezierExtrude extends Mesh3D
    {
        public var shape:Vertices3D;
        
        public var segmentsH:int = 20;
        public var axisVertices:Array = [];
        public var axisMaterials:Array = [];
        
        function BezierExtrude(material:IMaterial, shape:Vertices3D, vertices:Array, init:Object = null)
        {
            super(material, init);

            init = Init.parse(init);

            segmentsH = init.getNumber("segmentsH", 20, {min:2});
            axisMaterials = init.getArray("axisMaterials");

            this.shape = shape;
            this.vertices = vertices;
			buildExtrusion();
		}
		
		private function buildExtrusion():void
		{
			var i:Number, j:Number, k:Number;
			var iPoints:Number = vertices.length - 1;
			var aVtc:Array = new Array();
			
			var vec:Vertex3D, vx:Number, vy:Number, vz:Number, sx:Number, sy:Number, sz:Number;
			
			var a1:Number, a2:Number, fDir1:Number3D, fDir2:Number3D, fPos:Number3D, oldPos:Number3D;
			
			length = 0;
			for (k=0;k<iPoints-2; k+=2) {
				var p0:Number3D = vertices[k];
				var p1:Number3D = vertices[k+1];
				var p2:Number3D = Number3D.sub(Number3D.scale(vertices[k+2], 2), vertices[k+3]);
				var p3:Number3D = vertices[k+2];
				
				var d2:Number3D = Number3D.scale(Number3D.sub(p1, p0), 2);
				var d1:Number3D = Number3D.sub(p2, Number3D.add(p0, d2));
				
				var d4:Number3D = Number3D.scale(Number3D.sub(p2, p1), 2);
				var d3:Number3D = Number3D.sub(p3, Number3D.add(p1, d4));
				
				var jStart:Number = k? 1 : 0;
				for (j=jStart;j<=segmentsH;j++) { // vertical
					oldPos = fPos;
					var aRow:Array = new Array();
					a1 = j/segmentsH;
					a2 = Math.pow(j/segmentsH, 2);
					fDir1 = Number3D.add(Number3D.add(Number3D.scale(d1, a2), Number3D.scale(d2, a1)), p0);
					fDir2 = Number3D.add(Number3D.add(Number3D.scale(d3, a2), Number3D.scale(d4, a1)), p1);
					fPos = Number3D.add(Number3D.scale(fDir1, 1 - a1), Number3D.scale(fDir2, a1));
					axisVertices.push(fPos);
					
					var iHor:Number = shape.vertices.length;
					var oVertices:Array = shape.vertices;
					shape.lookAt(Number3D.sub(fDir2,fDir1));
					var sTransform:Matrix3D = shape.transform;
					if (j) length += Math.sqrt(Math.pow(fPos.x - oldPos.x,2) + Math.pow(fPos.y - oldPos.y,2) + Math.pow(fPos.z - oldPos.z,2));
					
					for (i=0;i<iHor;i++) { // horizontal
						vec = oVertices[i];
						vx = vec.x;
						vy = vec.y;
						vz = vec.z;
						sx = vx * sTransform.n11 + vy * sTransform.n12 + vz * sTransform.n13 + sTransform.n14;
            			sy = vx * sTransform.n21 + vy * sTransform.n22 + vz * sTransform.n23 + sTransform.n24;
						sz = vx * sTransform.n31 + vy * sTransform.n32 + vz * sTransform.n33 + sTransform.n34;
						var oVtx:Vertex3D = new Vertex3D(sx + fPos.x, sy + fPos.y, sz + fPos.z);
						vertices.push(oVtx);
						aRow.push(oVtx);
					}
					aVtc.push(aRow);
				}
			}
			var iVerNum:int = aVtc.length;
	
			var aP4uv:NumberUV, aP1uv:NumberUV, aP2uv:NumberUV, aP3uv:NumberUV;
			var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;
			var p:Point;
			var t1:Point = new Point();
			var t2:Point = new Point();
			var t3:Point = new Point();
			var t4:Point = new Point();
			var test1:Point = new Point(1,1);
			var test2:Point = new Point(0,1);
			var test3:Point = new Point(0,0);
			var test4:Point = new Point(1,0);
			var fJ0:Number, fJ1:Number, fI0:Number, fI1:Number;
			var lengthH:Number, oldLengthH:Number, lengthV:Number, oldLengthV:Number, tDiffx:Number, tDiffy:Number;
			var trans:Matrix = getMaterialTransform(material, shape.length, length);
			var mat:IUVMaterial = material as IUVMaterial;
			lengthV = oldLengthV = 0;
			for (j=1;j<iVerNum;j++) {
				var len:int = aVtc[j].length;
				var iHorNum:int = len;
				if (shape.wrap) iHorNum++;
				lengthH = oldLengthH = 0;
				oldLengthV = lengthV;
				lengthV += Number3D.sub(axisVertices[j], axisVertices[j-1]).modulo; 
				for (i=1;i<iHorNum;i++) {
					// select vertices
					var iWrapped:Number = i==len?0:i;
					aP1 = aVtc[j][iWrapped];
					aP2 = aVtc[j][i-1];
					aP3 = aVtc[j-1][i-1];
					aP4 = aVtc[j-1][iWrapped];
					// uv
					if (axisMaterials[i]) {
						mat = axisMaterials[i] as IUVMaterial;
						trans = getMaterialTransform(axisMaterials[i], shape.length, length);
					} else if (mat != material) {
						mat = material as IUVMaterial;
						trans = getMaterialTransform(material, shape.length, length);
					}
					if (mat.normal.modulo > 0) {
						var u:Number3D = Number3D.cross(mat.normal as Number3D, new Number3D(0,1,0));
						if (u.modulo) u.normalize();
						else u = new Number3D(1,0,0);
						var v:Number3D = Number3D.cross(mat.normal as Number3D, new Number3D(1,0,0));
						if (v.modulo) v.normalize();
						else v = new Number3D(0,1,0);
						t1.x = Number3D.dot(aP1, u);
						t1.y = Number3D.dot(aP1, v);
						t2.x = Number3D.dot(aP2, u);
						t2.y = Number3D.dot(aP2, v);
						t3.x = Number3D.dot(aP3, u);
						t3.y = Number3D.dot(aP3, v);
						t4.x = Number3D.dot(aP4, u);
						t4.y = Number3D.dot(aP4, v);
					} else {
						oldLengthH = lengthH;
						lengthH += Number3D.sub(aP1, aP2).modulo;
						t1.x = lengthH;
						t1.y = lengthV;
						t2.x = oldLengthH;
						t2.y = lengthV;
						t3.x = oldLengthH;
						t3.y = oldLengthV;
						t4.x = lengthH;
						t4.y = oldLengthV;
						//t2 = t1.add(t2);
					}
					t1 = trans.transformPoint(t1);
					t2 = trans.transformPoint(t2);
					t3 = trans.transformPoint(t3);
					t4 = trans.transformPoint(t4);
					if (mat.repeat) {
						tDiffx = t1.x - (t1.x %= 1);
						tDiffy = t1.y - (t1.y %= 1);
						t2.x -= tDiffx;
						t2.y -= tDiffy;
						t3.x -= tDiffx;
						t3.y -= tDiffy;
						t4.x -= tDiffx;
						t4.y -= tDiffy;						
					}
					aP1uv = new NumberUV(t1.x,t1.y);
					aP2uv = new NumberUV(t2.x,t2.y);
					aP3uv = new NumberUV(t3.x,t3.y);
					aP4uv = new NumberUV(t4.x,t4.y);
					var tArray:Array = [t1,t2,t3,t4];
					var testArray:Array = [test1,test2,test3,test4];
					if (mat.repeat || insideShape(testArray, tArray)) {
						// 2 faces
						faces.push( new Face3D(aP1,aP2,aP3, mat as ITriangleMaterial, aP1uv,aP2uv,aP3uv) );
						faces.push( new Face3D(aP1,aP3,aP4, mat as ITriangleMaterial, aP1uv,aP3uv,aP4uv) );
					}
				}
			}
		}
		
		private function insideShape(shape1:Array, shape2:Array):Boolean
		{
			var flag:Boolean;
			var p:Point, p1:Number, p2:Number, s1:Point, s2:Point;
			for each (p in shape1) {
				flag = true;
				for (p2=0;p2<shape2.length;p2++) {
					p1 = (p2 == 0)? shape2.length - 1 : p2 - 1;
					s1 = shape2[p1];
					s2 = shape2[p2];
					if ((s1.x*s2.y - s1.y*s2.x - p.x*s2.y + p.y*s2.x + p.x*s1.y - p.y*s1.x) < 0) flag = false;
				}
				if (flag) return true;
			}
			for each (p in shape2) {
				flag = true;
				for (p2=0;p2<shape1.length;p2++) {
					p1 = (p2 == 0)? shape1.length - 1 : p2 - 1;
					s1 = shape1[p1];
					s2 = shape1[p2];
					if ((s1.x*s2.y - s1.y*s2.x - p.x*s2.y + p.y*s2.x + p.x*s1.y - p.y*s1.x) < 0) flag = false;
				}
				if (flag) return true;
			}
			return flag;
		}
	}
		
}