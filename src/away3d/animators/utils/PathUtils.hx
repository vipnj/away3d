﻿package away3d.animators.utils;	import away3d.core.math.Number3D;	import away3d.core.math.Matrix3D;	import away3d.animators.data.Path;	import away3d.animators.data.CurveSegment;	/**	 * Geometry handlers for classes using Path objects	 */    class PathUtils     {    	 		    	 		public static function step( startVal:Number3D, endVal:Number3D, subdivision:Int):Array<Dynamic> {			var aTween:Array<Dynamic> = [];			var step:Int = 1;						var stepx:Int =  (endVal.x-startVal.x) / subdivision;			var stepy:Int =  (endVal.y-startVal.y) / subdivision;			var stepz:Int =  (endVal.z-startVal.z) / subdivision;						var scalestep:Number3D;			while (step < subdivision) { 				scalestep = new Number3D();				scalestep.x = startVal.x+(stepx*step);				scalestep.y = startVal.y+(stepy*step);				scalestep.z = startVal.z+(stepz*step);				aTween.push(scalestep);								step ++;			}						aTween.push(endVal);						return aTween;		}				public static function rotatePoint(aPoint:Number3D, rotation:Number3D):Number3D		{			if(rotation.x !=0 || rotation.y != 0 || rotation.z != 0)			{				var x1:Float;				var y1:Float;				var z1:Float;								var rad:Int = Math.PI / 180;				var rotx:Int = rotation.x * rad;				var roty:Int = rotation.y * rad;				var rotz:Int = rotation.z * rad;				var sinx:Int = Math.sin(rotx);				var cosx:Int = Math.cos(rotx);				var siny:Int = Math.sin(roty);				var cosy:Int = Math.cos(roty);				var sinz:Int = Math.sin(rotz);				var cosz:Int = Math.cos(rotz);					var x:Int = aPoint.x;				var y:Int = aPoint.y;				var z:Int = aPoint.z;					y1 = y;				y = y1*cosx+z*-sinx;				z = y1*sinx+z*cosx;								x1 = x;				x = x1*cosy+z*siny;				z = x1*-siny+z*cosy;							x1 = x;				x = x1*cosz+y*-sinz;				y = x1*sinz+y*cosz;					aPoint.x = x;				aPoint.y = y;				aPoint.z = z;			}						return aPoint;		}				public static function getPointsOnCurve(_path:Path, subdivision:Int):Array<Dynamic> 		{				var aSegPoints:Array<Dynamic>  = [ PathUtils.getSegmentPoints(_path.array[0].v0, _path.array[0].vc, _path.array[0].v1, subdivision)];						for (var i:Int = 1; i < _path.length; ++i)				aSegPoints.push(PathUtils.getSegmentPoints(_path.array[i-1].v1, _path.array[i].vc, _path.array[i].v1, subdivision));							return aSegPoints;		}				public static function getSegmentPoints(v0:Number3D, va:Number3D, v1:Number3D, n:Float):Array<Dynamic>		{			var aPts:Array<Dynamic> = [];			/*			v0.x = (v0.x == 0)? 0.00001 : v0.x;			v0.y = (v0.y == 0)? 0.00001 : v0.y;			v0.z = (v0.y == 0)? 0.00001 : v0.z;			va.x = (va.x == 0)? 0.00001 : va.x;			va.y = (va.y == 0)? 0.00001 : va.y;			va.z = (va.z == 0)? 0.00001 : va.z;			v1.x = (v1.x == 0)? 0.00001 : v1.x;			v1.y = (v1.y == 0)? 0.00001 : v1.y;			v1.z = (v1.z == 0)? 0.00001 : v1.z;			*/			for (i in 0...n) {				aPts.push(PathUtils.getNewPoint(v0.x, v0.y, v0.z, va.x, va.y, va.z, v1.x, v1.y, v1.z, i / n));			}			return aPts;		}				public static function getNewPoint(?x0:Int = 0, ?y0:Int = 0, ?z0:Int=0, ?aX:Int = 0, ?aY:Int = 0, ?aZ:Int=0, ?x1:Int = 0, ?y1:Int = 0, ?z1:Int=0, ?t:Int = 0):Number3D 		{			return new Number3D(x0 + t * (2 * (1 - t) * (aX - x0) + t * (x1 - x0)), y0 + t * (2 * (1 - t) * (aY - y0) + t * (y1 - y0)), z0 + t * (2 * (1 - t) * (aZ - z0) + t * (z1 - z0)));		}      		    }