package away3d.test;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;


/**
 * Simple rounded rectangle button
 */
class Button extends SimpleButton  {
	
	public var selected:Bool;
	

	public function new(text:String, ?pwidth:Int=80, ?pheight:Int=20) {
		// autogenerated
		super();
		this.selected = false;
		
		
		upState = Type.createInstance(ButtonState, []);
		overState = Type.createInstance(ButtonState, []);
		downState = Type.createInstance(ButtonState, []);
		hitTestState = Type.createInstance(ButtonState, []);
	}

}

