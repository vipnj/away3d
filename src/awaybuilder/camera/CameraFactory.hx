package awaybuilder.camera;

import awaybuilder.vo.SceneCameraVO;


class CameraFactory  {
	
	private var propertyFactory:CameraPropertyFactory;
	

	public function new() {
		
		
		this.propertyFactory = new CameraPropertyFactory();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function build(vo:SceneCameraVO):SceneCameraVO {
		
		vo = this.propertyFactory.build(vo);
		return vo;
	}

}

