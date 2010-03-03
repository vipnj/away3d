package away3d.exporters{	import away3d.arcane;	import away3d.core.base.Mesh;	import away3d.core.base.Object3D;	import away3d.core.geom.Plane3D;	import away3d.graphs.TreeIterator;	import away3d.graphs.bsp.BSPNode;	import away3d.graphs.bsp.BSPTree;	import away3d.events.ExporterEvent;	import away3d.materials.ITriangleMaterial;	import flash.utils.Dictionary;	use namespace arcane;		public class BSPExporter extends AWDataExporter	{		private var _iterator : TreeIterator;		private var _materialsList : Array;		private var _materialString : String;		public var materialNames : Dictionary;		public function BSPExporter()		{			super();		}		public override function export(object3d:Object3D):void		{			var asString : String;			var tree : BSPTree = BSPTree(object3d);			_materialsList = [];			_numMeshes = 0;			if(hasEventListener(ExporterEvent.COMPLETE)){				reset();				_iterator = new TreeIterator(tree._rootNode);				_iterator.performMethod(parseNode);				generateMatString();				//parse(object3d);				asString = "//AWDataExporter version 1.1, Away3D Flash 10, generated by Away3D: http://www.away3d.com\n";				asString += "#v:1.1\n"				asString += "#f:1\n";				asString += "#t:bsp\n";				//asString += "#o\n" + _meshString;				asString += "#d\n" + geoString;				asString += "#b\n" + _branchesString;				asString += "#l\n" + _leavesString;				asString += "#m\n" + _materialString;				//asString += "#c"+containerString;				asString += "\n#end of file";				var EE:ExporterEvent = new ExporterEvent(ExporterEvent.COMPLETE);				EE.data = asString;				dispatchEvent(EE);			} else {				trace("AWDataExporter Error:\nNo ExporterEvent.COMPLETE event set.\nUse the method addOnExportComplete(myfunction) before use export();\n");			}		}		private function generateMatString() : void		{			_materialString = "";			for (var i : int = 0; i < _materialsList.length; ++i) {				trace (materialNames[_materialsList[i]]);				_materialString += "images/" + materialNames[_materialsList[i]] + ".jpg\n";			}		}		private function parseNode(node : BSPNode) : void		{			if (node._isLeaf)				parseLeaf(node);			else				parseBranch(node);		}		private function parseBranch(node : BSPNode) : void		{			var plane : Plane3D;			var bevels : Vector.<Plane3D> = node._bevelPlanes;			var len : int;			var pos : BSPNode = node._positiveNode;			var neg : BSPNode = node._negativeNode;			// save:			// - node id			// - positive node id			// - negative node id			// - partition plane			// - bevel planes			_branchesString += node.nodeId + ",";			_branchesString += (pos? pos.nodeId : "-1") + ",";			_branchesString += (neg? neg.nodeId : "-1") + ",";			plane = node._partitionPlane;			_branchesString += plane._alignment + "," +							   plane.a.toString() + "," +							   plane.b.toString() + "," +							   plane.c.toString() + "," +							   plane.d.toString() + "\n";			if (bevels && bevels.length > 0) {				len = bevels.length;				for (var i : int = 0; i < len; ++i) {					plane = bevels[i];					_branchesString += 	plane.a.toString() + "," +								   		plane.b.toString() + "," +								   		plane.c.toString() + "," +								   		plane.d.toString();					if (i < len-1) _branchesString += ",";				}			}			else {				_branchesString += "-1,-1";			}			_branchesString += "\n";		}		private function parseLeaf(node : BSPNode) : void		{			var visList : Vector.<int> = node._visList;			var len : int;			var mesh : Mesh = node._mesh;			var faces : Array = mesh.geometry.faces;			var i : int;			var mat : ITriangleMaterial;			var matIndex : int;			len = faces.length;			for (i = 0; i < len; ++i) {				mat = faces[i].material;				matIndex = _materialsList.indexOf(mat);				if (matIndex == -1) {					matIndex = _materialsList.length;					_materialsList.push(mat);				}			}			_leavesString += node.nodeId.toString() + ",";			_leavesString += node.leafId.toString() + ",";			_leavesString += (_numMeshes++) + "\n";			if (visList) {				len = visList.length;				for (i = 0; i < len; ++i) {					_leavesString += visList[i].toString(16);					if (i < len-1) _leavesString += ",";				}			}			_leavesString += "\n";			//parseMesh(node._mesh);						write(node._mesh, 0, _materialsList);			//XXXXXXXXX			//here we need another loop			//bitmapdata list (for the air version) an array of urls			//and parse themesh to know which url is associated to the face			//XXXXXXXX			// save:			// - node id			// - leaf id			// - mesh (maybe we can save mesh data somewhere else, and keep leaf id?)			// - vislist		}		/*private function parseMesh(mesh : Mesh) : void		{			// I guess this can be reused from original AWD			++_numMeshes;		}*/	}}