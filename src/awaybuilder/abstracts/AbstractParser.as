package awaybuilder.abstracts{	import flash.events.EventDispatcher;		import awaybuilder.interfaces.IParser;				/**	 * @author andreasengstrom	 */	public class AbstractParser extends EventDispatcher implements IParser	{		public function AbstractParser ( )		{			super ( ) ;		}								////////////////////		// PUBLIC METHODS //		////////////////////								public function parse ( xml : XML ) : void		{		}								public function getSections ( ) : Array		{			return new Array ( ) ;		}	}}