﻿package away3dlite.primitives;import away3dlite.haxeutils.FastStd;import away3dlite.materials.BitmapMaterial;import away3dlite.core.base.Object3D;import away3dlite.materials.Material;//use namespace arcane;using away3dlite.namespace.Arcane;using away3dlite.haxeutils.HaxeUtils;/*** Creates a 3d Cube primitive.*/ class Cube6 extends AbstractPrimitive{		private var __width:Float;	private var __height:Float;	private var _depth:Float;	private var _segmentsW:Int;	private var _segmentsH:Int;	private var _segmentsD:Int;	private var _pixelBorder:Int;		/**	 * @inheritDoc	 */	private override function buildPrimitive():Void	{		super.buildPrimitive();				var i:Int;		var j:Int;				var udelta:Float = _pixelBorder/600;		var vdelta:Float = _pixelBorder/400;				var a:Int;		var b:Int;		var c:Int;		var d:Int;		var inc:Int = 0;				if (FastStd.is(material, BitmapMaterial)) {			var bMaterial:BitmapMaterial = material.downcast(BitmapMaterial);			udelta = _pixelBorder/bMaterial.width;			vdelta = _pixelBorder/bMaterial.height;		}				i = -1;		while (++i <= _segmentsW)		{			j = -1;			while (++j <= _segmentsH)			{								//create front/back				_vertices.push3(__width/2 - i*__width/_segmentsW, __height/2 - j*__height/_segmentsH, -_depth/2);				_vertices.push3(__width/2 - i*__width/_segmentsW, __height/2 - j*__height/_segmentsH, _depth/2);								_uvtData.push3(1/3 - udelta - i*(1 - 6*udelta)/(3*_segmentsW), 1 - vdelta - j*(1 - 4*vdelta)/(2*_segmentsH), 1);				_uvtData.push3(1/3 + udelta + i*(1 - 6*udelta)/(3*_segmentsW), 1/2 - vdelta - j*(1 - 4*vdelta)/(2*_segmentsH), 1);								//haXeW				if (i != 0 && j != 0) {					a = 2*((_segmentsW + 1)*j + i);					b = 2*((_segmentsW + 1)*j + i - 1);					c = 2*((_segmentsW + 1)*(j - 1) + i - 1);					d = 2*((_segmentsW + 1)*(j - 1) + i);										_indices.push3(a, b, c);					_indices.push(d);					_indices.push3(b+1,a+1,d+1);					_indices.push(c + 1);					_faceLengths.push(4);					_faceLengths.push(4);				}			}		}				inc += 2*(_segmentsW + 1)*(_segmentsH + 1);				i = -1;		while (++i <= _segmentsW)		{			j = -1;			while (++j <= _segmentsD)			{								//create top/bottom				_vertices.push3(__width/2 - i*__width/_segmentsW, -__height/2, -_depth/2 + j*_depth/_segmentsD);				_vertices.push3(__width/2 - i*__width/_segmentsW, __height/2, -_depth/2 + j*_depth/_segmentsD);								_uvtData.push3(1/3 + udelta + j*(1 - 6*udelta)/(3*_segmentsW), 1 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD), 1);				_uvtData.push3(2/3 + udelta + j*(1 - 6*udelta)/(3*_segmentsW), 1/2 + vdelta + i*(1 - 4*vdelta)/(2*_segmentsD), 1);								if (i != 0 && j != 0) {					a = inc + 2*((_segmentsW + 1)*j + i);					b = inc + 2*((_segmentsW + 1)*j + i - 1);					c = inc + 2*((_segmentsW + 1)*(j - 1) + i - 1);					d = inc + 2*((_segmentsW + 1)*(j - 1) + i);										_indices.push3(a,b,c);					_indices.push(d);					_indices.push3(b+1,a+1,d+1);					_indices.push(c+1);					_faceLengths.push(4);					_faceLengths.push(4);				}			}		}				inc += 2*(_segmentsW + 1)*(_segmentsD + 1);				i = -1;		while (++i <= _segmentsH)		{			j = -1;			while (++j <= _segmentsD)			{								//create left/right				_vertices.push3(__width/2, __height/2 - i*__height/_segmentsH, -_depth/2 + j*_depth/_segmentsD);				_vertices.push3(-__width/2, __height/2 - i*__height/_segmentsH, -_depth/2 + j*_depth/_segmentsD);								_uvtData.push3(udelta + j*(1 - 6*udelta)/(3*_segmentsH), 1/2 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD), 1);				_uvtData.push3(1 - udelta - j*(1 - 6*udelta)/(3*_segmentsH), 1/2 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD), 1);								//haXeW				if (i !=0 && j != 0) {					a = inc + 2*((_segmentsH + 1)*j + i);					b = inc + 2*((_segmentsH + 1)*j + i - 1);					c = inc + 2*((_segmentsH + 1)*(j - 1) + i - 1);					d = inc + 2*((_segmentsH + 1)*(j - 1) + i);										_indices.push3(a,b,c);					_indices.push(d);					_indices.push3(b+1,a+1,d+1);					_indices.push(c+1);					_faceLengths.push(4);					_faceLengths.push(4);				}			}		}	}		/**	 * Defines the width of the cube. Defaults to 100.	 * 	 * <b>haXe specific</b> : Variable is called _width, due to haXe limitation.	 */	private override function get__width():Float	{		return __width;	}		private override function set__width(val:Float):Float	{		if (__width == val)			return val;				__width = val;		_primitiveDirty = true;		return val;	}		/**	 * Defines the height of the cube. Defaults to 100.	 * 	 * <b>haXe specific</b> : Variable is called _height, due to haXe limitation.	 */	private override function get__height():Float	{		return __height;	}		private override function set__height(val:Float):Float	{		if (__height == val)			return val;				__height = val;		_primitiveDirty = true;		return val;	}		/**	 * Defines the depth of the cube. Defaults to 100.	 */	public var depth(get_depth, set_depth):Float;	private inline function get_depth():Float	{		return _depth;	}		private function set_depth(val:Float):Float	{		if (_depth == val)			return _depth;				_depth = val;		_primitiveDirty = true;		return val;	}		/**	 * Defines the Float of horizontal segments that make up the cube. Defaults to 1.	 */	public var segmentsW(get_segmentsW, set_segmentsW):Float;	private inline function get_segmentsW():Float	{		return _segmentsW;	}		private function set_segmentsW(val:Float):Float	{		if (_segmentsW == val)			return _segmentsW;				_segmentsW = Std.int(val);		_primitiveDirty = true;		return _segmentsW;	}		/**	 * Defines the Float of vertical segments that make up the cube. Defaults to 1.	 */	public var segmentsH(get_segmentsH, set_segmentsH):Float;	private inline function get_segmentsH():Float	{		return _segmentsH;	}		private function set_segmentsH(val:Float):Float	{		if (_segmentsH == val)			return _segmentsH;				_segmentsH = Std.int(val);		_primitiveDirty = true;		return _segmentsH;	} 		/**	 * Defines the Float of depth segments that make up the cube. Defaults to 1.	 */	public var segmentsD(get_segmentsD, set_segmentsD):Float;	private inline function get_segmentsD():Float	{		return _segmentsD;	}		private function set_segmentsD(val:Float):Float	{		if (_segmentsD == val)			return val;				_segmentsD = Std.int(val);		_primitiveDirty = true;		return _segmentsD;	}		/**	 * Defines the texture mapping border in pixels used around each face of the cube. Defaults to 1	 */	public var pixelBorder(get_pixelBorder, set_pixelBorder):Int;	private inline function get_pixelBorder():Int	{		return _pixelBorder;	}		private function set_pixelBorder(val:Int):Int	{		if (_pixelBorder == val)			return val;				_pixelBorder = val;		_primitiveDirty = true;		return val;	}		/**	 * Creates a new <code>Cube</code> object.	 * 	 * @param	width		Defines the width of the cube.	 * @param	height		Defines the height of the cube.	 * @param	depth		Defines the depth of the cube.	 * @param	segmentsW	Defines the number of horizontal segments that make up the cube.	 * @param	segmentsH	Defines the number of vertical segments that make up the cube.	 * @param	segmentsD	Defines the number of depth segments that make up the cube.	 * @param	pixelBorder	Defines the texture mapping border in pixels used around each face of the cube.	 */	public function new(?material:Material, ?width:Float = 100, ?height:Float = 100, ?depth:Float = 100, ?segmentsW:Int = 1, ?segmentsH:Int = 1, ?segmentsD:Int = 1, ?pixelBorder:Int = 1)	{		super(material);				__width = width;		__height = height;		_depth = depth;		_segmentsW = segmentsW;		_segmentsH = segmentsH;		_segmentsD = segmentsD;		_pixelBorder = pixelBorder;				type = "Cube";		url = "primitive";	}				/**	 * Duplicates the cube6 properties to another <code>Cube6</code> object.	 * 	 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Cube6</code>.	 * @return						The new object instance with duplicated properties applied.	 */	public override function clone(?object:Object3D):Object3D	{		var cube6:Cube6 = (object != null) ? (object.downcast(Cube6)) : new Cube6();		super.clone(cube6);		cube6._width = __width;		cube6._height = __height;		cube6.depth = _depth;		cube6.segmentsW = _segmentsW;		cube6.segmentsH = _segmentsH;		cube6.segmentsD = _segmentsD;		cube6.pixelBorder = _pixelBorder;		cube6._primitiveDirty = false;				return cube6;	}} 