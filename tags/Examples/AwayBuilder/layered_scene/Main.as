package{	import awaybuilder.WorldBuilder;	import awaybuilder.collada.ColladaLoader;	import awaybuilder.events.CameraEvent;	import awaybuilder.vo.SceneCameraVO;		import flash.display.Sprite;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.net.URLRequest;				public class Main extends Sprite	{		protected var _top : WorldBuilder;		protected var _bottom : WorldBuilder;		protected var _startCamera : String = "overviewCam";						public function Main ( )		{			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;			loadBottomLayer ( );		}								protected function loadBottomLayer ( ) : void		{			var loader : ColladaLoader = new ColladaLoader ( ) ;						loader.addEventListener ( Event.COMPLETE , onBottomLayerComplete );			loader.load ( new URLRequest ( "maya/bottom.dae" ) );		}								protected function onBottomLayerComplete ( event : Event ) : void		{			var loader : ColladaLoader = event.target as ColladaLoader;						_bottom = new WorldBuilder ( );			_bottom.data = loader.collada;			_bottom.addEventListener ( Event.COMPLETE , onBottomBuildComplete );			addChild ( _bottom );			_bottom.x = stage.stageWidth * 0.5;			_bottom.y = stage.stageHeight * 0.5;			_bottom.build ( );		}								protected function onBottomBuildComplete ( event : Event ) : void		{			loadTopLayer ( );		}								protected function loadTopLayer ( ) : void		{			var loader : ColladaLoader = new ColladaLoader ( );						loader.addEventListener ( Event.COMPLETE , onTopLoadComplete );			loader.load ( new URLRequest ( "maya/top.dae" ) );		}								protected function onTopLoadComplete ( event : Event ) : void		{			var loader : ColladaLoader = event.target as ColladaLoader;						_top = new WorldBuilder ( );			_top.data = loader.collada;			_top.startCamera = _startCamera;			_top.addEventListener ( Event.COMPLETE , onTopBuildComplete );			addChild ( _top );			_top.x = stage.stageWidth * 0.5;			_top.y = stage.stageHeight * 0.5;			_top.build ( );		}								protected function onTopBuildComplete ( event : Event ) : void		{			var camera : SceneCameraVO = _top.getCameraById ( _startCamera );						_bottom.teleportTo ( camera );			_top.addEventListener ( CameraEvent.ANIMATION_START , onAnimationStart );			stage.addEventListener ( Event.RESIZE , resize );			resize ( );		}								protected function onAnimationStart ( event : CameraEvent ) : void		{			_bottom.navigateTo ( event.targetCamera );		}								protected function resize ( event : Event = null ) : void		{			_top.x = stage.stageWidth * 0.5;			_top.y = stage.stageHeight * 0.5;			_bottom.x = stage.stageWidth * 0.5;			_bottom.y = stage.stageHeight * 0.5;		}	}}