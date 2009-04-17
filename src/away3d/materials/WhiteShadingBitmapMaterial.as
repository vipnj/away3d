package away3d.materials
{
	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*;

    use namespace arcane;
    
    /**
    * Bitmap material with flat white lighting
    */
    public class WhiteShadingBitmapMaterial extends CenterLightingMaterial implements IUVMaterial
    {
        private var _bitmap:BitmapData;
        private var _texturemapping:Matrix;
        private var _faceMaterialVO:FaceMaterialVO;
        private var _faceDictionary:Dictionary = new Dictionary(true);
        private var blackrender:Boolean;
        private var whiterender:Boolean;
        private var whitek:Number = 0.2;
		private var bitmapPoint:Point = new Point(0, 0);
		private var colorTransform:ColorMatrixFilter = new ColorMatrixFilter();
        private var cache:Dictionary;
        private var step:int = 1;
		private var mapping:Matrix;
		private var br:Number;
         
        private function ladder(v:Number):Number
        {
            if (v < 1/0xFF)
                return 0;
            if (v > 0xFF)
                v = 0xFF;
            return Math.exp(Math.round(Math.log(v)*step)/step);
        }
        
        /**
        * Calculates the mapping matrix required to draw the triangle texture to screen.
        * 
        * @param	tri		The data object holding all information about the triangle to be drawn.
        * @return			The required matrix object.
        */
		protected function getMapping(tri:DrawTriangle):Matrix
		{
			if (tri.generated) {
				_texturemapping = tri.transformUV(this).clone();
				_texturemapping.invert();
				
				return _texturemapping;
			}
			
			_faceMaterialVO = getFaceMaterialVO(tri.faceVO, tri.source, tri.view);
			
			if (!_faceMaterialVO.invalidated)
				return _faceMaterialVO.texturemapping;
			
			_texturemapping = tri.transformUV(this).clone();
			_texturemapping.invert();
			
			return _faceMaterialVO.texturemapping = _texturemapping;
		}
		
        /** @private */
        protected override function renderTri(tri:DrawTriangle, session:AbstractRenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            br = (kar + kag + kab + kdr + kdg + kdb + ksr + ksg + ksb)/3;
			
            mapping = getMapping(tri);
            
            v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;
            
            if ((br < 1) && (blackrender || ((step < 16) && (!_bitmap.transparent))))
            {
                session.renderTriangleBitmap(_bitmap, mapping, v0, v1, v2, smooth, repeat);
                session.renderTriangleColor(0x000000, 1 - br, v0, v1, v2);
            }
            else
            if ((br > 1) && (whiterender))
            {
                session.renderTriangleBitmap(_bitmap, mapping, v0, v1, v2, smooth, repeat);
                session.renderTriangleColor(0xFFFFFF, (br - 1)*whitek, v0, v1, v2);
            }
            else
            {
                if (step < 64)
                    if (Math.random() < 0.01)
                        doubleStepTo(64);
                var brightness:Number = ladder(br);
                var bitmap:BitmapData = cache[brightness];
                if (bitmap == null)
                {
                	bitmap = new BitmapData(_bitmap.width, _bitmap.height, true, 0x00000000);
                	colorTransform.matrix = [brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, 1, 0];
                	bitmap.applyFilter(_bitmap, bitmap.rect, bitmapPoint, colorTransform);
                    cache[brightness] = bitmap;
                }
                session.renderTriangleBitmap(bitmap, mapping, v0, v1, v2, smooth, repeat);
            }
        }
        
    	/**
    	 * Determines if texture bitmap is smoothed (bilinearly filtered) when drawn to screen
    	 */
        public var smooth:Boolean;
        
        /**
        * Determines if texture bitmap will tile in uv-space
        */
        public var repeat:Boolean;
        
		/**
		 * @inheritDoc
		 */
        public function get width():Number
        {
            return _bitmap.width;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get height():Number
        {
            return _bitmap.height;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function get visible():Boolean
        {
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getPixel32(u:Number, v:Number):uint
        {
        	return _bitmap.getPixel32(u*_bitmap.width, (1 - v)*_bitmap.height);
        }
    	
		/**
		 * Creates a new <code>WhiteShadingBitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function WhiteShadingBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            _bitmap = bitmap;
            
            super(init);

			
            smooth = ini.getBoolean("smooth", false);
            repeat = ini.getBoolean("repeat", false);
            
            if (!CacheStore.whiteShadingCache[_bitmap])
            	CacheStore.whiteShadingCache[_bitmap] = new Dictionary(true);
            	
            cache = CacheStore.whiteShadingCache[_bitmap];
        }
		
        public function doubleStepTo(limit:int):void
        {
            if (step < limit)
                step *= 2;
        }
        
        public function getFaceMaterialVO(faceVO:FaceVO, source:Object3D = null, view:View3D = null):FaceMaterialVO
        {
        	if ((_faceMaterialVO = _faceDictionary[faceVO]))
        		return _faceMaterialVO;
        	
        	return _faceDictionary[faceVO] = new FaceMaterialVO();
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clearFaces(source:Object3D = null, view:View3D = null):void
        {
        	notifyMaterialUpdate();
        	
        	for each (_faceMaterialVO in _faceDictionary)
        		if (!_faceMaterialVO.cleared)
        			_faceMaterialVO.clear();
        }
        
		/**
		 * @inheritDoc
		 */
        public function invalidateFaces(source:Object3D = null, view:View3D = null):void
        {
        	for each (_faceMaterialVO in _faceDictionary)
        		_faceMaterialVO.invalidated = true;
        }
    }
}
