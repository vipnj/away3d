package away3d.materials;

import away3d.haxeutils.Error;
import away3d.core.render.AbstractRenderSession;
import flash.events.EventDispatcher;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import flash.events.Event;
import away3d.events.MaterialEvent;
import flash.geom.Rectangle;
import away3d.core.base.Object3D;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import away3d.core.utils.Init;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;


// use namespace arcane;

/**
 * Container for layering multiple material objects.
 * Renders each material by drawing one triangle per meterial layer.
 * For static bitmap materials, use <code>BitmapMaterialContainer</code>.
 * 
 * @see away3d.materials.BitmapMaterialContainer
 */
class CompositeMaterial extends EventDispatcher, implements ITriangleMaterial, implements ILayerMaterial {
	public var color(getColor, setColor) : Int;
	public var alpha(getAlpha, setAlpha) : Float;
	public var visible(getVisible, null) : Bool;
	
	/** @private */
	public var _color:Int;
	/** @private */
	public var _alpha:Float;
	/** @private */
	public var _colorTransform:ColorTransform;
	/** @private */
	public var _colorTransformDirty:Bool;
	/** @private */
	public var _spriteDictionary:Dictionary;
	/** @private */
	public var _sprite:Sprite;
	/** @private */
	public var _source:Object3D;
	/** @private */
	public var _session:AbstractRenderSession;
	private var _defaultColorTransform:ColorTransform;
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	private var _material:ILayerMaterial;
	/**
	 * An array of bitmapmaterial objects to be overlayed sequentially.
	 */
	private var materials:Array<Dynamic>;
	/**
	 * Instance of the Init object used to hold and parse default property values
	 * specified by the initialiser object in the 3d object constructor.
	 */
	private var ini:Init;
	/**
	 * Defines a blendMode value for the layer container.
	 */
	public var blendMode:String;
	

	private function clearSpriteDictionary():Void {
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(_spriteDictionary)).iterator();
		for (__key in __keys) {
			_sprite = _spriteDictionary[untyped __key];

			if (_sprite != null) {
				_sprite.graphics.clear();
			}
		}

	}

	private function onMaterialUpdate(event:MaterialEvent):Void {
		
		dispatchEvent(event);
	}

	/**
	 * Updates the colortransform object applied to the texture from the <code>color</code> and <code>alpha</code> properties.
	 * 
	 * @see color
	 * @see alpha
	 */
	private function setColorTransform():Void {
		
		_colorTransformDirty = false;
		if (_alpha == 1 && _color == 0xFFFFFF) {
			_colorTransform = null;
			return;
		} else if (_colorTransform == null) {
			_colorTransform = new ColorTransform();
		}
		_colorTransform.redMultiplier = _red;
		_colorTransform.greenMultiplier = _green;
		_colorTransform.blueMultiplier = _blue;
		_colorTransform.alphaMultiplier = _alpha;
	}

	/**
	 * Defines a colored tint for the layer container.
	 */
	public function getColor():Int {
		
		return _color;
	}

	public function setColor(val:Int):Int {
		
		if (_color == val) {
			return val;
		}
		_color = val;
		_red = ((_color & 0xFF0000) >> 16) / 255;
		_green = ((_color & 0x00FF00) >> 8) / 255;
		_blue = (_color & 0x0000FF) / 255;
		_colorTransformDirty = true;
		return val;
	}

	/**
	 * Defines an alpha value for the layer container.
	 */
	public function getAlpha():Float {
		
		return _alpha;
	}

	public function setAlpha(value:Float):Float {
		
		if (value > 1) {
			value = 1;
		}
		if (value < 0) {
			value = 0;
		}
		if (_alpha == value) {
			return value;
		}
		_alpha = value;
		_colorTransformDirty = true;
		return value;
	}

	/**
	 * @inheritDoc
	 */
	public function getVisible():Bool {
		
		return true;
	}

	/**
	 * Creates a new <code>CompositeMaterial</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		// autogenerated
		super();
		this._colorTransform = new ColorTransform();
		this._spriteDictionary = new Dictionary(true);
		this._defaultColorTransform = new ColorTransform();
		
		
		ini = Init.parse(init);
		materials = ini.getArray("materials");
		blendMode = ini.getString("blendMode", BlendMode.NORMAL);
		alpha = ini.getNumber("alpha", 1, {min:0, max:1});
		color = ini.getColor("color", 0xFFFFFF);
		for (__i in 0...materials.length) {
			_material = materials[__i];

			if (_material != null) {
				_material.addOnMaterialUpdate(onMaterialUpdate);
			}
		}

		_colorTransformDirty = true;
	}

	public function addMaterial(material:ILayerMaterial):Void {
		
		material.addOnMaterialUpdate(onMaterialUpdate);
		materials.push(material);
	}

	public function removeMaterial(material:ILayerMaterial):Void {
		
		var index:Int = untyped materials.indexOf(material);
		if (index == -1) {
			return;
		}
		material.removeOnMaterialUpdate(onMaterialUpdate);
		materials.splice(index, 1);
	}

	/**
	 * @inheritDoc
	 */
	public function updateMaterial(source:Object3D, view:View3D):Void {
		
		clearSpriteDictionary();
		if (_colorTransformDirty) {
			setColorTransform();
		}
		for (__i in 0...materials.length) {
			_material = materials[__i];

			if (_material != null) {
				_material.updateMaterial(source, view);
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public function renderTriangle(tri:DrawTriangle):Void {
		
		_source = tri.source;
		_session = _source.session;
		var level:Int = 0;
		if ((_sprite = _session.spriteLayers[level]) == null) {
			_sprite = _session.spriteLayers[level] = new Sprite();
		}
		if (!_session.children[untyped _sprite]) {
			_session.addLayerObject(_sprite);
			_sprite.filters = [];
			_sprite.blendMode = blendMode;
			if ((_colorTransform != null)) {
				_sprite.transform.colorTransform = _colorTransform;
			} else {
				_sprite.transform.colorTransform = _defaultColorTransform;
			}
		}
		//call renderLayer on each material
		for (__i in 0...materials.length) {
			_material = materials[__i];

			if (_material != null) {
				_material.renderLayer(tri, _sprite, ++level);
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		if (_colorTransform == null && blendMode == BlendMode.NORMAL) {
			_sprite = layer;
		} else {
			_source = tri.source;
			_session = _source.session;
			//check to see if session sprite exists
			if ((_sprite = _session.spriteLayers[level]) == null) {
				layer.addChild(_sprite = _session.spriteLayers[level] = new Sprite());
			}
			_sprite.filters = [];
			_sprite.blendMode = blendMode;
			if ((_colorTransform != null)) {
				_sprite.transform.colorTransform = _colorTransform;
			} else {
				_sprite.transform.colorTransform = _defaultColorTransform;
			}
		}
		//call renderLayer on each material
		for (__i in 0...materials.length) {
			_material = materials[__i];

			if (_material != null) {
				_material.renderLayer(tri, _sprite, level++);
			}
		}

	}

	/**
	 * @private
	 */
	public function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO {
		
		throw new Error("Not implemented");
		
		// autogenerated
		return null;
	}

	/**
	 * @inheritDoc
	 */
	public function addOnMaterialUpdate(listener:Dynamic):Void {
		
		addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
	}

	/**
	 * @inheritDoc
	 */
	public function removeOnMaterialUpdate(listener:Dynamic):Void {
		
		removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
	}

}

