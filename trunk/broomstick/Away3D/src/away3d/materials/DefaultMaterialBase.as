package away3d.materials{	import away3d.arcane;	import away3d.core.managers.Texture3DProxy;	import away3d.materials.methods.BasicAmbientMethod;	import away3d.materials.methods.BasicDiffuseMethod;	import away3d.materials.methods.BasicSpecularMethod;	import away3d.materials.methods.ShadingMethodBase;	import away3d.materials.passes.DefaultScreenPass;	import flash.display.BitmapData;	import flash.display.BitmapDataChannel;	import flash.display3D.Context3D;	import flash.geom.ColorTransform;	import flash.geom.Point;	use namespace arcane;	/**	 * DefaultMaterialBase forms an abstract base class for the default materials provided by Away3D and use methods	 * to define their appearance.	 */	public class DefaultMaterialBase extends MaterialBase	{		private var _specularMap : BitmapData;		private var _glossMap : BitmapData;		private var _specularGlossMap : BitmapData;		private const MAX:uint = 2048;		private var _specularGlossMapDirty : Boolean;		protected var _screenPass : DefaultScreenPass;		private var _normalMapTexture : Texture3DProxy;		/**		 * Creates a new DefaultMaterialBase object.		 */		public function DefaultMaterialBase()		{			super();			addPass(_screenPass = new DefaultScreenPass());			_screenPass.material = this;		}		/**		 * The ColorTransform object to transform the colour of the material with.		 */		public function get colorTransform() : ColorTransform		{			return _screenPass.colorTransform;		}		public function set colorTransform(value : ColorTransform) : void		{			_screenPass.colorTransform = value;		}		/**		 * @inheritDoc		 */		override public function get requiresBlending() : Boolean		{			return super.requiresBlending || (_screenPass.colorTransform && _screenPass.colorTransform.alphaMultiplier < 1);		}		/**		 * The method to perform diffuse shading.		 */		public function get ambientMethod() : BasicAmbientMethod		{			return _screenPass.ambientMethod;		}		public function set ambientMethod(value : BasicAmbientMethod) : void		{			_screenPass.ambientMethod = value;		}		/**		 * The method to perform diffuse shading.		 */		public function get diffuseMethod() : BasicDiffuseMethod		{			return _screenPass.diffuseMethod;		}		public function set diffuseMethod(value : BasicDiffuseMethod) : void		{			_screenPass.diffuseMethod = value;		}		/**		 * The method to perform specular shading.		 */		public function get specularMethod() : BasicSpecularMethod		{			return _screenPass.specularMethod;		}		public function set specularMethod(value : BasicSpecularMethod) : void		{			_screenPass.specularMethod = value;		}		public function addMethod(method : ShadingMethodBase) : void		{			_screenPass.addMethod(method);		}		public function addMethodAt(method : ShadingMethodBase, index : int) : void		{			_screenPass.addMethodAt(method, index);		}		public function removeMethod(method : ShadingMethodBase) : void		{			_screenPass.removeMethod(method);		}		/**		 * @inheritDoc		 */		override public function set mipmap(value : Boolean) : void		{			if (_mipmap == value) return;			super.mipmap = value;		}		/**		 * The tangent space normal map to influence the direction of the surface for each texel.		 */		public function get normalMap() : BitmapData		{			return _normalMapTexture.bitmapData;		}		public function set normalMap(value : BitmapData) : void		{			if (value) {				_normalMapTexture ||= new Texture3DProxy();								if(isBitmapDataValid(value)){					_normalMapTexture.bitmapData = value;				} else{					throw new Error("Invalid bitmapData! Must be power of 2 and not exceeding 2048");				}			} else {				if (_normalMapTexture) {					_normalMapTexture.dispose(false);					_normalMapTexture = null;				}			}			_screenPass.normalMap = _normalMapTexture;		}		/**		 * A specular map that defines the strength of specular reflections for each texel.		 */		public function get specularMap() : BitmapData		{			return _specularMap;		}		public function set specularMap(value : BitmapData) : void		{			var newMap : BitmapData;			if (_specularMap == value) return;						if(isBitmapDataValid(value)){				_specularMap = value;					newMap = _specularGlossMap;				if (value)					newMap ||= new BitmapData(_specularMap.width, _specularMap.height, false);				else if (!_glossMap && newMap) {					newMap.dispose();					newMap = null;				}					_specularGlossMap = newMap;				_specularGlossMapDirty = true;							} else{				throw new Error("Invalid bitmapData! Must be power of 2 and not exceeding 2048");			}		}		override public function dispose(deep : Boolean) : void		{			super.dispose(deep);			if (_specularGlossMap) _specularGlossMap.dispose();		}		/**		 * The sharpness of the specular highlight.		 */		public function get gloss() : Number		{			return _screenPass.specularMethod? _screenPass.specularMethod.gloss : 0;		}		public function set gloss(value : Number) : void		{			if (_screenPass.specularMethod) _screenPass.specularMethod.gloss = value;		}		/**		 * The strength of the ambient reflection.		 */		public function get ambient() : Number		{			return _screenPass.ambientMethod.ambient;		}		public function set ambient(value : Number) : void		{			_screenPass.ambientMethod.ambient = value;		}		/**		 * The overall strength of the specular reflection.		 */		public function get specular() : Number		{			return _screenPass.specularMethod? _screenPass.specularMethod.specular : 0;		}		public function set specular(value : Number) : void		{			if (_screenPass.specularMethod) _screenPass.specularMethod.specular = value;		}		/**		 * The colour of the ambient reflection.		 */		public function get ambientColor() : uint		{			return _screenPass.ambientMethod.ambientColor;		}		public function set ambientColor(value : uint) : void		{			_screenPass.ambientMethod.ambientColor = value;		}		/**		 * The colour of the specular reflection.		 */		public function get specularColor() : uint		{			return _screenPass.specularMethod.specularColor;		}		public function set specularColor(value : uint) : void		{			_screenPass.specularMethod.specularColor = value;		}		/**		 * @inheritDoc		 */		arcane override function updateMaterial(context : Context3D) : void		{			if (_screenPass._passesDirty) {				clearPasses();				if (_screenPass._passes) {					var len : uint = _screenPass._passes.length;					for (var i : uint = 0; i < len; ++i)						addPass(_screenPass._passes[i]);				}				addPass(_screenPass);				_screenPass._passesDirty = false;			}			if (_specularGlossMapDirty) {				updateSpecularGlossMap(context);				_specularGlossMapDirty = false;			}		}		/**		 * Updates the specular gloss map		 */		private function updateSpecularGlossMap(context : Context3D) : void		{			if (!_specularGlossMap) return;			_specularGlossMap.fillRect(_specularGlossMap.rect, 0xffffff);			if (_specularMap)				_specularGlossMap.copyChannel(_specularMap, _specularGlossMap.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.RED);			if (_glossMap)				_specularGlossMap.copyChannel(_glossMap, _specularGlossMap.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);			if (_screenPass.specularMethod)				_screenPass.specularMethod.bitmapData = _specularGlossMap;		}				public function isBitmapDataValid(bitmapData : BitmapData) : Boolean		{			var w:int = bitmapData.width;			var h:int = bitmapData.height;						if(w<2 || h<2 || w>MAX || h>MAX) return false;			
			if(_screenPass.diffuseMethod.bitmapData && bitmapData != _screenPass.diffuseMethod.bitmapData ){				if(w != _screenPass.diffuseMethod.bitmapData.width || h != _screenPass.diffuseMethod.bitmapData.height)					trace("WARNING: all material maps should have equal width and height.");			}
			if(isPowerOfTwo(w) && isPowerOfTwo(h)) return true;									return false;		}				private function isPowerOfTwo(value:int): Boolean		{			return value ? ((value & -value) == value) : false;		}	}}