package away3d.core.math;

    /**
    * A point in 3D space.
    */
    public final class Number3D
     {
    	public var modulo(getModulo, null) : Float
        ;
    	public var modulo2(getModulo2, null) : Float
        ;
    	
    	var toDEGREES:Int ;
    	var mod:Float;
        var dist:Float;
        var num:Number3D;
        var vx:Float;
        var vy:Float;
        var vz:Float;
        var nx:Float;
        var ny:Float;
        var nz:Float;
        var m1:Matrix3D;
        var m2:Matrix3D;
        
        /**
        * The horizontal coordinate of the 3d number object.
        */ 
        public var x:Float;
    
        /**
        * The vertical coordinate of the 3d number object.
        */ 
        public var y:Float;
    
        /**
        * The depth coordinate of the 3d number object.
        */ 
        public var z:Float;
    	
    	/**
    	 * The modulo of the 3d number object.
    	 */
        public function getModulo():Float
        {
            return Math.sqrt(x*x + y*y + z*z);
        }
    	
    	/**
    	 * The squared modulo of the 3d number object.
    	 */
        public function getModulo2():Float
        {
            return x*x + y*y + z*z;
        }
        
		/**
		 * Creates a new <code>Number3D</code> object.
		 *
		 * @param	x	[optional]	A default value for the horizontal coordinate of the 3d number object. Defaults to 0.
		 * @param	y	[optional]	A default value for the vertical coordinate of the 3d number object. Defaults to 0.
		 * @param	z	[optional]	A default value for the depth coordinate of the 3d number object. Defaults to 0.
		 * @param	n	[optional]	Determines of the resulting 3d number object should be normalised. Defaults to false.
		 */
        public function new(?x:Int = 0, ?y:Int = 0, ?z:Int = 0, ?n:Bool = false)
        {
            
            toDEGREES = 180 / Math.PI;
            this.x = x;
            this.y = y;
            this.z = z;
            
            if (n)
            	normalize();
        }
		
		/**
		 * Duplicates the 3d number's properties to another <code>Number3D</code> object
		 * 
		 * @return	The new 3d number instance with duplicated properties applied
		 */
        public function clone(v:Number3D):Void
        {
            x = v.x;
            y = v.y;
            z = v.z;
        }
		
    	/**
    	 * Fills the 3d number object with scaled values from the given 3d number.
    	 * 
    	 * @param	v	The 3d number object used for the scaling calculation.
    	 * @param	s	The scaling value.
    	 */
        public function scale(v:Number3D, s:Float):Void
        {
            x = v.x * s;
            y = v.y * s;
            z = v.z * s;
        }  
		
    	/**
    	 * Fills the 3d number object with the result from an addition of two 3d numbers.
    	 * 
    	 * @param	v	The first 3d number in the addition.
    	 * @param	w	The second 3d number in the addition.
    	 */
        public function add(v:Number3D, w:Number3D):Void
        {
            x = v.x + w.x;
            y = v.y + w.y;
            z = v.z + w.z;
        }
		
    	/**
    	 * Fills the 3d number object with the result from a subtraction of two 3d numbers.
    	 * 
    	 * @param	v	The starting 3d number in the subtraction.
    	 * @param	w	The subtracting 3d number in the subtraction.
    	 */
        public function sub(v:Number3D, w:Number3D):Void
        {
            x = v.x - w.x;
            y = v.y - w.y;
            z = v.z - w.z;
        }
    	
    	/**
    	 * Calculates the distance from the 3d number object to the given 3d number.
    	 * 
    	 * @param	w	The 3d number object whose distance is calculated.
    	 */
        public function distance(w:Number3D):Float
        {
            return Math.sqrt((x - w.x)*(x - w.x) + (y - w.y)*(y - w.y) + (z - w.z)*(z - w.z));
        }
    	
    	/**
    	 * Calculates the dot product of the 3d number object with the given 3d number.
    	 * 
    	 * @param	w	The 3d number object to use in the calculation.
    	 * @return		The dot product result.
    	 */
        public function dot(w:Number3D):Float
        {
            return (x * w.x + y * w.y + z * w.z);
        }
		
    	/**
    	 * Fills the 3d number object with the result from an cross product of two 3d numbers.
    	 * 
    	 * @param	v	The first 3d number in the cross product calculation.
    	 * @param	w	The second 3d number in the cross product calculation.
    	 */
        public function cross(v:Number3D, w:Number3D):Void
        {
        	if (this == v || this == w)
        		throw new Error("resultant cross product cannot be the same instance as an input");
        	x = w.y * v.z - w.z * v.y;
        	y = w.z * v.x - w.x * v.z;
        	z = w.x * v.y - w.y * v.x;
        }
    	
    	/**
    	 * Returns the angle in radians made between the 3d number obejct and the given 3d number.
    	 * 
    	 * @param	w	[optional]	The 3d number object to use in the calculation.
    	 * @return					An angle in radians representing the angle between the two 3d number objects. 
    	 */
        public function getAngle(?w:Number3D = null):Float
        {
            if (w == null)
            	w = new Number3D();
            return Math.acos(dot(w)/(modulo*w.modulo));
        }
        
        /**
        * Normalises the 3d number object.
        * @param	val	[optional]	A normalisation coefficient representing the length of the resulting 3d number object. Defaults to 1.
        */
        public function normalize(?val:Int = 1):Void
        {
            mod = modulo/val;
    
            if (mod != 0 && mod != 1)
            {
                x /= mod;
                y /= mod;
                z /= mod;
            }
        }
    	
    	/**
    	 * Fills the 3d number object with the result of a 3d matrix rotation performed on a 3d number.
    	 * 
    	 * @param	v	The 3d number object to use in the calculation.
    	 * @param	m	The 3d matrix object representing the rotation.
    	 */
        public function rotate(v:Number3D, m:Matrix3D):Void
        {
        	vx = v.x;
        	vy = v.y;
        	vz = v.z;
        	
            x = vx * m.sxx + vy * m.sxy + vz * m.sxz;
            y = vx * m.syx + vy * m.syy + vz * m.syz;
            z = vx * m.szx + vy * m.szy + vz * m.szz;
        }
    	
    	/**
    	 * Fills the 3d number object with the result of a 3d matrix tranformation performed on a 3d number.
    	 * 
    	 * @param	v	The 3d number object to use in the calculation.
    	 * @param	m	The 3d matrix object representing the tranformation.
    	 */
        public function transform(v:Number3D, m:Matrix3D):Void
        {
        	vx = v.x;
        	vy = v.y;
        	vz = v.z;
        	
            x = vx * m.sxx + vy * m.sxy + vz * m.sxz + m.tx;
            y = vx * m.syx + vy * m.syy + vz * m.syz + m.ty;
            z = vx * m.szx + vy * m.szy + vz * m.szz + m.tz;
        }
            	
    	/**
    	 * Fill the 3d number object with the euler angles represented by the 3x3 matrix rotation.
    	 * 
    	 * @param	m	The 3d matrix object to use in the calculation.
    	 */
        public function matrix2euler(m:Matrix3D, ?scaleX:Int = 1, ?scaleY:Int = 1, ?scaleZ:Int = 1):Void
        {
            if (!m1)
            	m1 = new Matrix3D();
	
		    // Extract the first angle, rotationX
			x = Math.atan2(m.syz, m.szz); // rot.x = Math<T>::atan2 (M[1][2], M[2][2]);
			
			// Remove the rotationX rotation from m1, so that the remaining
			// rotation, m2 is only around two axes, and gimbal lock cannot occur.
			var c:Int   = Math.cos(x);
			var s:Int   = Math.sin(x);
			m1.sxx = m.sxx;
			m1.sxy = m.sxy*c + m.sxz*s;
			m1.sxz = -m.sxy*s + m.sxz*c;
			m1.syx = m.syx;
			m1.syy = m.syy*c + m.syz*s;
			m1.syz = -m.syy*s + m.syz*c;
			m1.szx = m.szx;
			m1.szy = m.szy*c + m.szz*s;
			m1.szz = -m.szy*s + m.szz*c;
			
			// Extract the other two angles, rot.y and rot.z, from m1.
			var cy:Int = Math.sqrt(m1.sxx*m1.sxx + m1.syx*m1.syx); // T cy = Math<T>::sqrt (N[0][0]*N[0][0] + N[0][1]*N[0][1]);
			y = Math.atan2(-m1.szx, cy); // rot.y = Math<T>::atan2 (-N[0][2], cy);
			z = Math.atan2(-m1.sxy, m1.syy); //rot.z = Math<T>::atan2 (-N[1][0], N[1][1]);
	
			// Fix angles
			if(x == Math.PI) {
				if(y > 0)
					y -= Math.PI;
				else
					y += Math.PI;
	
				x = 0;
				z += Math.PI;
			}
        }
        
        public function quaternion2euler(quarternion:Quaternion):Void
		{
			
			var test:Int = quarternion.x*quarternion.y + quarternion.z*quarternion.w;
			if (test > 0.499) { // singularity at north pole
				x = 2 * Math.atan2(quarternion.x,quarternion.w);
				y = Math.PI/2;
				z = 0;
				return;
			}
			if (test < -0.499) { // singularity at south pole
				x = -2 * Math.atan2(quarternion.x,quarternion.w);
				y = - Math.PI/2;
				z = 0;
				return;
			}
		    
		    var sqx:Int = quarternion.x*quarternion.x;
		    var sqy:Int = quarternion.y*quarternion.y;
		    var sqz:Int = quarternion.z*quarternion.z;
		    
		    x = Math.atan2(2*quarternion.y*quarternion.w - 2*quarternion.x*quarternion.z , 1 - 2*sqy - 2*sqz);
			y = Math.asin(2*test);
			z = Math.atan2(2*quarternion.x*quarternion.w-2*quarternion.y*quarternion.z , 1 - 2*sqx - 2*sqz);
		}
		
    	/**
    	 * Fill the 3d number object with the scale values represented by the 3x3 matrix.
    	 * 
    	 * @param	m	The 3d matrix object to use in the calculation.
    	 */
        public function matrix2scale(m:Matrix3D):Void
        {
            x = Math.sqrt(m.sxx*m.sxx + m.syx*m.syx + m.szx*m.szx);
            y = Math.sqrt(m.sxy*m.sxy + m.syy*m.syy + m.szy*m.szy);
            z = Math.sqrt(m.sxz*m.sxz + m.syz*m.syz + m.szz*m.szz);
        }
        
        /**
        * A 3d number object representing a relative direction forward.
        */
        inline public static var FORWARD:Number3D = new Number3D( 0,  0,  1);
        
        /**
        * A 3d number object representing a relative direction backward.
        */
        inline public static var BACKWARD:Number3D = new Number3D( 0,  0, -1);
        
        /**
        * A 3d number object representing a relative direction left.
        */
        inline public static var LEFT:Number3D = new Number3D(-1,  0,  0);
        
        /**
        * A 3d number object representing a relative direction right.
        */
        inline public static var RIGHT:Number3D = new Number3D( 1,  0,  0);
        
        /**
        * A 3d number object representing a relative direction up.
        */
        inline public static var UP:Number3D = new Number3D( 0,  1,  0);
        
        /**
        * A 3d number object representing a relative direction down.
        */
        inline public static var DOWN:Number3D = new Number3D( 0, -1,  0);
        
        /**
        * Calculates a 3d number object representing the closest point on a given plane to a given 3d point.
        * 
        * @param	p	The 3d point used in teh calculation.
        * @param	k	The plane offset used in the calculation.
        * @param	n	The plane normal used in the calculation.
        * @return		The resulting 3d point.
        */
        public function closestPointOnPlane(p:Number3D, k:Number3D, n:Number3D):Number3D
        {
        	if (!num)
        		num = new Number3D();
        	
        	num.sub(p, k);
            dist = n.dot(num);
            num.scale(n, dist);
            num.sub(p, num);
            return num;
        }
		
		/**
		 * Used to trace the values of a 3d number.
		 * 
		 * @return A string representation of the 3d number object.
		 */
        public function toString(): String
        {
            return 'x:' + x + ' y:' + y + ' z:' + z;
        }
    }
