package gs.utils.tween;

import gs.plugins.ColorMatrixFilterPlugin;


class ColorMatrixFilterVars extends FilterVars  {
	
	public var matrix:Array<Dynamic>;
	private static var _ID_MATRIX:Array<Dynamic> = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
	//Red constant - used for a few color matrix filter functions
	private static var _lumR:Float = 0.212671;
	//Green constant - used for a few color matrix filter functions
	private static var _lumG:Float = 0.715160;
	//Blue constant - used for a few color matrix filter functions
	private static var _lumB:Float = 0.072169;
	

	public function new(?$colorize:Int=0xFFFFFF, ?$amount:Float=1, ?$saturation:Float=1, ?$contrast:Float=1, ?$brightness:Float=1, ?$hue:Float=0, ?$threshold:Float=-1, ?$remove:Bool=false, ?$index:Int=-1, ?$addFilter:Bool=false) {
		
		
		super($remove, $index, $addFilter);
		this.matrix = _ID_MATRIX.slice();
		if ($brightness != 1) {
			setBrightness($brightness);
		}
		if ($contrast != 1) {
			setContrast($contrast);
		}
		if ($hue != 0) {
			setHue($hue);
		}
		if ($saturation != 1) {
			setSaturation($saturation);
		}
		if ($threshold != -1) {
			setThreshold($threshold);
		}
		if ($colorize != 0xFFFFFF) {
			setColorize($colorize, $amount);
		}
	}

	public function setBrightness($n:Float):Void {
		
		this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setBrightness(this.matrix, $n);
	}

	public function setContrast($n:Float):Void {
		
		this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setContrast(this.matrix, $n);
	}

	public function setHue($n:Float):Void {
		
		this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setHue(this.matrix, $n);
	}

	public function setSaturation($n:Float):Void {
		
		this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setSaturation(this.matrix, $n);
	}

	public function setThreshold($n:Float):Void {
		
		this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setThreshold(this.matrix, $n);
	}

	public function setColorize($color:Int, ?$amount:Float=1):Void {
		
		this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.colorize(this.matrix, $color, $amount);
	}

	//for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
	public static function createFromGeneric($vars:Dynamic):ColorMatrixFilterVars {
		
		var v:ColorMatrixFilterVars;
		if (Std.is($vars, ColorMatrixFilterVars)) {
			v = cast($vars, ColorMatrixFilterVars);
		} else if ($vars.matrix != null) {
			v = new ColorMatrixFilterVars();
			v.matrix = $vars.matrix;
		} else {
			v = new ColorMatrixFilterVars($vars.colorize || 0xFFFFFF, ($vars.amount == null) ? 1 : $vars.amount, ($vars.saturation == null) ? 1 : $vars.saturation, ($vars.contrast == null) ? 1 : $vars.contrast, ($vars.brightness == null) ? 1 : $vars.brightness, ($vars.hue > 0) ? $vars.hue : 0, ($vars.threshold == null) ? -1 : $vars.threshold, $vars.remove || false, ($vars.index == null) ? -1 : $vars.index, $vars.addFilter || false);
		}
		return v;
	}

}

