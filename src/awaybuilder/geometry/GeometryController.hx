package awaybuilder.geometry;

import flash.events.Event;
import away3d.core.base.Object3D;
import awaybuilder.abstracts.AbstractGeometryController;
import awaybuilder.events.GeometryEvent;
import awaybuilder.interfaces.IGeometryController;
import awaybuilder.vo.SceneGeometryVO;
import awaybuilder.vo.SceneSectionVO;


class GeometryController extends AbstractGeometryController, implements IGeometryController {
	
	private var geometry:Array<Dynamic>;
	

	public function new(geometry:Array<Dynamic>) {
		
		
		super();
		this.geometry = geometry;
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	override public function enableInteraction():Void {
		
		for (__i in 0...this.geometry.length) {
			var geometry:SceneGeometryVO = this.geometry[__i];

			if (geometry != null) {
				this.enableGeometryInteraction(geometry);
			}
		}

	}

	override public function disableInteraction():Void {
		
		for (__i in 0...this.geometry.length) {
			var geometry:SceneGeometryVO = this.geometry[__i];

			if (geometry != null) {
				this.disableGeometryInteraction(geometry);
			}
		}

	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Protected Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	private function extractGeometry(mainSection:SceneSectionVO, allGeometry:Array<Dynamic>, ?cascade:Bool=false):Array<Dynamic> {
		
		for (__i in 0...mainSection.geometry.length) {
			var geometry:SceneGeometryVO = mainSection.geometry[__i];

			if (geometry != null) {
				allGeometry.push(geometry);
			}
		}

		if (cascade) {
			for (__i in 0...mainSection.sections.length) {
				var subSection:SceneSectionVO = mainSection.sections[__i];

				if (subSection != null) {
					var a:Array<Dynamic> = this.extractGeometry(subSection, allGeometry);
					allGeometry.concat(a);
				}
			}

		}
		return allGeometry;
	}

	private function enableGeometryInteraction(geometry:SceneGeometryVO):Void {
		
		this.disableGeometryInteraction(geometry);
		if (geometry.mouseDownEnabled) {
			geometry.mesh.addOnMouseDown(this.geometryMouseDown);
		}
		if (geometry.mouseMoveEnabled) {
			geometry.mesh.addOnMouseMove(this.geometryMouseMove);
		}
		if (geometry.mouseOutEnabled) {
			geometry.mesh.addOnMouseOut(this.geometryMouseOut);
		}
		if (geometry.mouseOverEnabled) {
			geometry.mesh.addOnMouseOver(this.geometryMouseOver);
		}
		if (geometry.mouseUpEnabled) {
			geometry.mesh.addOnMouseUp(this.geometryMouseUp);
		}
	}

	private function disableGeometryInteraction(geometry:SceneGeometryVO):Void {
		
		geometry.mesh.removeOnMouseDown(this.geometryMouseDown);
		geometry.mesh.removeOnMouseMove(this.geometryMouseMove);
		geometry.mesh.removeOnMouseOut(this.geometryMouseOut);
		geometry.mesh.removeOnMouseOver(this.geometryMouseOver);
		geometry.mesh.removeOnMouseUp(this.geometryMouseUp);
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Event Handlers
	//
	////////////////////////////////////////////////////////////////////////////////
	private function geometryMouseDown(event:Event):Void {
		
		for (__i in 0...this.geometry.length) {
			var vo:SceneGeometryVO = this.geometry[__i];

			if (vo != null) {
				if (vo.mesh == event.target) {
					var interactionEvent:GeometryEvent = new GeometryEvent(GeometryEvent.DOWN);
					interactionEvent.geometry = vo;
					this.dispatchEvent(interactionEvent);
					break;
				}
			}
		}

	}

	private function geometryMouseMove(event:Event):Void {
		
		for (__i in 0...this.geometry.length) {
			var vo:SceneGeometryVO = this.geometry[__i];

			if (vo != null) {
				if (vo.mesh == event.target) {
					var interactionEvent:GeometryEvent = new GeometryEvent(GeometryEvent.MOVE);
					interactionEvent.geometry = vo;
					this.dispatchEvent(interactionEvent);
					break;
				}
			}
		}

	}

	private function geometryMouseOut(event:Event):Void {
		
		for (__i in 0...this.geometry.length) {
			var vo:SceneGeometryVO = this.geometry[__i];

			if (vo != null) {
				if (vo.mesh == event.target) {
					var interactionEvent:GeometryEvent = new GeometryEvent(GeometryEvent.OUT);
					interactionEvent.geometry = vo;
					this.dispatchEvent(interactionEvent);
					break;
				}
			}
		}

	}

	private function geometryMouseOver(event:Event):Void {
		
		for (__i in 0...this.geometry.length) {
			var vo:SceneGeometryVO = this.geometry[__i];

			if (vo != null) {
				if (vo.mesh == event.target) {
					var interactionEvent:GeometryEvent = new GeometryEvent(GeometryEvent.OVER);
					interactionEvent.geometry = vo;
					this.dispatchEvent(interactionEvent);
					break;
				}
			}
		}

	}

	private function geometryMouseUp(event:Event):Void {
		
		for (__i in 0...this.geometry.length) {
			var vo:SceneGeometryVO = this.geometry[__i];

			if (vo != null) {
				if (vo.mesh == event.target) {
					var interactionEvent:GeometryEvent = new GeometryEvent(GeometryEvent.UP);
					interactionEvent.geometry = vo;
					this.dispatchEvent(interactionEvent);
					break;
				}
			}
		}

	}

}

