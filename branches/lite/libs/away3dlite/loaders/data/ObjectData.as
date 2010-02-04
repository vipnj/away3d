package away3dlite.loaders.data
{
	import flash.geom.*;
	/**
	 * Data class for a generic 3d object
	 */
	public class ObjectData
	{
		/**
		 * The name of the 3d object used as a unique reference.
		 */
		public var name:String;
		
		/**
		 * The 3d transformation matrix for the 3d object
		 */
		public var transform:Matrix3D = new Matrix3D();
		
		/**
		 * Colada animation
		 */
		public var id:String;
		public var scale:Number;

		/**
		 * Copy the object data into another <code>ObjectData</code> object.
		 */
		public function copyTo(dst:ObjectData):void
		{
			dst.name = name;
			dst.transform = transform;
			dst.id = id;
			dst.scale = scale;
		}	}
}