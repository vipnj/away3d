package away3d.events;

import flash.events.Event;
import flash.events.EventDispatcher;
import away3d.core.clip.Clipping;


/**
 * Passed as a parameter when a clip event occurs
 */
class ClippingEvent extends Event  {
	
	/**
	 * Defines the value of the type property of a ClipingUpdated event object.
	 */
	public static inline var CLIPPING_UPDATED:String = "clippingUpdated";
	/**
	 * A reference to the session object that is relevant to the event.
	 */
	public var clipping:Clipping;
	

	/**
	 * Creates a new <code>FaceEvent</code> object.
	 * 
	 * @param	type	The type of the event. Possible values are: <code>FaceEvent.UPDATED</code></code>.
	 * @param	clip	A reference to the clipping object that is relevant to the event.
	 */
	public function new(type:String, clipping:Clipping) {
		
		
		super(type);
		this.clipping = clipping;
	}

	/**
	 * Creates a copy of the FaceEvent object and sets the value of each property to match that of the original.
	 */
	public override function clone():Event {
		
		return new ClippingEvent(type, clipping);
	}

}
