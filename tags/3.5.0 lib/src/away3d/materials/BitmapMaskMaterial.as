﻿package away3d.materials
    import away3d.arcane;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    
    import flash.display.*;
    
	use namespace arcane;
	
    /**
    * Basic bitmap material
    */
    public class BitmapMaskMaterial extends BitmapMaterial
    {
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _scaling:Number;
        public function set offsetX(value:Number):void
        {
        	_offsetX = value;
        }
        
        public function set offsetY(value:Number):void
        {
        	_offsetY = value;
        }
        
        public function set scaling(value:Number):void
        {
        	_scaling = value;
        }
        
		/**
		 * Creates a new <code>BitmapMaskMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function BitmapMaskMaterial(bitmap:BitmapData, init:Object = null)
        {
            _offsetX = ini.getNumber("offsetX", 0);
            _offsetY = ini.getNumber("offsetY", 0);
        }
    }
}