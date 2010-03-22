package away3d.graphs.bsp
{
	import away3d.events.MouseEvent3D;
	import away3d.graphs.*;
	import away3d.core.math.MatrixAway3D;
	import away3d.events.Object3DEvent;
	import away3d.materials.ITriangleMaterial;
	import away3d.core.base.UV;
	import away3d.core.base.Face;
	import away3d.core.geom.Plane3D;
	import away3d.core.base.Vertex;
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.core.base.Mesh;

	import flash.events.Event;


	use namespace arcane;
	
	/**
	 * @author David Lenaerts
	 */
	internal class BSPMeshManager
	{
		private var _mesh : Mesh;
		private var _sourceMesh : Mesh;
		private var _splitMeshes : Array;
		private var _faces : Array;
		private var _vertices : Array;
		
		private var _centerX : Number;
		private var _centerY : Number;
		private var _centerZ : Number;
		private var _extentX : Number;
		private var _extentY : Number;
		private var _extentZ : Number;
		private var _posFaceVerts : Vector.<Vertex>;
		private var _negFaceVerts : Vector.<Vertex>;
		private var _posFaceUV : Vector.<UV>;
		private var _negFaceUV : Vector.<UV>;
		
		private var _bspLeaves : Vector.<BSPNode>;

		private var _tree : BSPTree;

/*
 * Object pools
 */
		private var _meshPool : Vector.<Mesh>;
		private var _meshPoolLen : int = -1;
		private var _usedMeshes : Vector.<Mesh>;
		private var _usedMeshLen : int = -1;
		
		private var _facePool : Vector.<Face>;
		private var _facePoolLen : int = -1;
		private var _usedFaces : Vector.<Face>;
		private var _usedFaceLen : int = -1;
		
		private var _vertexPool : Vector.<Vertex>;
		private var _vertexPoolLen : int = -1;
		private var _usedVerts : Vector.<Vertex>;
		private var _usedVertLen : int = -1;
		
		private var _uvPool : Vector.<UV>;
		private var _uvPoolLen : int = -1;
		private var _usedUV : Vector.<UV>;
		private var _usedUVLen : int = -1;
		
		public function BSPMeshManager(mesh : Mesh, tree: BSPTree)
		{
			_tree = tree;
			_sourceMesh = _mesh = mesh;
			_posFaceVerts = new Vector.<Vertex>();
			_negFaceVerts = new Vector.<Vertex>();
			_posFaceUV = new Vector.<UV>();
			_negFaceUV = new Vector.<UV>();
			_bspLeaves = new Vector.<BSPNode>();
			_meshPool = new Vector.<Mesh>();
			_usedMeshes = new Vector.<Mesh>();
			_facePool = new Vector.<Face>();
			_usedFaces = new Vector.<Face>();
			_vertexPool = new Vector.<Vertex>();
			_usedVerts = new Vector.<Vertex>();
			_uvPool = new Vector.<UV>();
			_usedUV = new Vector.<UV>();
			mesh.addOnTransformChange(onTransformChange);
			sendDownTree(_tree._rootNode);
		}
		
		public function destroy() : void
		{
			mesh.removeOnTransformChange(onTransformChange);
			var i : int;
			
			i = _bspLeaves.length;
			while (--i >= 0) {
				_bspLeaves[i].removeMesh(this);
			}
			
			_posFaceVerts = null;
			_negFaceVerts = null;
			_posFaceUV = null;
			_negFaceUV = null;
			_bspLeaves = null;
			_meshPool = null;
			_usedMeshes = null;
			_facePool = null;
			_usedFaces = null;
			_vertexPool = null;
			_usedVerts = null;
			_uvPool = null;
			_usedUV = null;
			_splitMeshes = null;
			_faces = null;
			_vertices = null;
			_sourceMesh = null;
			_mesh = null;
		}

		private function onTransformChange(event : Object3DEvent) : void 
		{
			sendDownTree(_tree._rootNode);
		}

		private function sendDownTree(node : BSPNode) : void
		{
			var side : int;
			var mesh : Mesh;
			
			// root node
			if (node == _tree._rootNode) {
				update();
				cleanUp();
			}
			
			// reduce recursion as much as possible
			do {
				if (node._isLeaf) {
					mesh = getNewMesh();
					addListeners(mesh);
					buildMesh(mesh, _faces[node.nodeId]);
					_tree.addTemporaryChild(mesh);
					_splitMeshes[node.leafId] = mesh;
					_bspLeaves.push(node);
					node.addMesh(this);
					return;
				}
				side = split(node);
				if (side == Plane3D.FRONT)
					node = node._positiveNode;
				else if (side == Plane3D.BACK)
					node = node._negativeNode;
			} while (node && side != Plane3D.INTERSECT);
			
			if (side == Plane3D.INTERSECT) {
				sendDownTree(node._positiveNode);
				if (node._negativeNode) sendDownTree(node._negativeNode);
			}
		}

		private function buildMesh(mesh : Mesh, faces : Array) : void 
		{
			var geom : Geometry = mesh._geometry;
			var orgFaces : Array = geom.faces;
			var i : int = orgFaces.length;
			
			while (--i >= 0) {
				geom.removeFace(Face(orgFaces[0]));
			}
			
			i = faces.length;
			
			while (--i >= 0) {
				geom.addFace(Face(faces[i]));
			}
		}

		private function update() : void
		{
			_splitMeshes = [];
			_faces = [];
			_vertices = [];
			_centerX = (_sourceMesh.maxX+_sourceMesh._minX)*.5;
			_centerY = (_sourceMesh._maxY+_sourceMesh._minY)*.5;
			_centerZ = (_sourceMesh._maxZ+_sourceMesh._minZ)*.5;
			_extentX = (_sourceMesh._maxX-_sourceMesh._minX)*.5;
			_extentY = (_sourceMesh._maxY-_sourceMesh._minY)*.5;
			_extentZ = (_sourceMesh._maxZ-_sourceMesh._minZ)*.5;
		}
		
		private function cleanUp() : void
		{
			var mesh : Mesh;
			var face : Face;
			var i : int;
			
			i = _bspLeaves.length;
			while (--i >= 0) {
				_bspLeaves[i].removeMesh(this);
			}
			_bspLeaves.length = 0;
			
			// move everything back on pool-stacks
			while (_usedMeshLen >= 0) {
				_meshPool[++_meshPoolLen] = mesh = _usedMeshes[_usedMeshLen--];
				clearListeners(mesh);
				_tree.removeTemporaryChild(mesh);
			}
			while (_usedFaceLen >= 0) {
				_facePool[++_facePoolLen] = face = _usedFaces[_usedFaceLen--];
				face.uv0 = face.uv1 = face.uv2 = null;
			}
			while (_usedVertLen >= 0) {
				_vertexPool[++_vertexPoolLen] = _usedVerts[_usedVertLen--];
			}
			while (_usedUVLen >= 0) {
				_uvPool[++_uvPoolLen] = _usedUV[_usedUVLen--];
			}
		}

		private function addListeners(mesh : Mesh) : void
		{
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, forwardEvent);
			mesh.addEventListener(MouseEvent3D.MOUSE_MOVE, forwardEvent);
			mesh.addEventListener(MouseEvent3D.MOUSE_UP, forwardEvent);
			mesh.addEventListener(MouseEvent3D.MOUSE_OUT, forwardEvent);
			mesh.addEventListener(MouseEvent3D.MOUSE_OVER, forwardEvent);
			mesh.addEventListener(MouseEvent3D.ROLL_OUT, forwardEvent);
			mesh.addEventListener(MouseEvent3D.ROLL_OVER, forwardEvent);
		}

		private function clearListeners(mesh : Mesh) : void
		{
			mesh.removeEventListener(MouseEvent3D.MOUSE_DOWN, forwardEvent);
			mesh.removeEventListener(MouseEvent3D.MOUSE_MOVE, forwardEvent);
			mesh.removeEventListener(MouseEvent3D.MOUSE_UP, forwardEvent);
			mesh.removeEventListener(MouseEvent3D.MOUSE_OUT, forwardEvent);
			mesh.removeEventListener(MouseEvent3D.MOUSE_OVER, forwardEvent);
			mesh.removeEventListener(MouseEvent3D.ROLL_OUT, forwardEvent);
			mesh.removeEventListener(MouseEvent3D.ROLL_OVER, forwardEvent);
		}

		private function forwardEvent(event : Event) : void
		{
			_sourceMesh.dispatchEvent(event);
		}
		
		/**
		 * Splits the mesh along a node's plane
		 * @param node The BSPNode against which plane to split
		 * @return The side of the plane in which the mesh lies
		 */
		public function split(node : BSPNode) : int
		{
			var vertices : Array;
			var faces : Array;
			var i : int;
			var v : Vertex;
			var plane : Plane3D = node._partitionPlane;
			var offset : Number;
			var dist : Number;
			var a : Number, b : Number, c : Number, d : Number;
			var al : Number, bl : Number, cl : Number, dl : Number;
			var l : Number;
			var mat : MatrixAway3D = _sourceMesh.transform;
			var numPos : Number;
			var numNeg : Number;
			var createNeg : Boolean = node._negativeNode != null;
			var posFaces : Array = [];
			var negFaces : Array;
			var posVerts : Array = [];
			var negVerts : Array;
			var id : int;
			
			// if rootnode (no splits performed), use original geometry
			if (node == _tree._rootNode) {
				vertices = _sourceMesh._geometry.vertices;
				faces = _sourceMesh._geometry.faces;
			}
			else {
				vertices = _vertices[node.nodeId];
				faces = _faces[node.nodeId];
			}
			
			if (createNeg) {
				negFaces = [];
				negVerts = [];
			}
			
			a = plane.a;
			b = plane.b;
			c = plane.c;
			d = plane.d;

			// transform the plane to local coords (inline)
			al = a*mat.sxx + b*mat.syx + c*mat.szx + d*mat.swx;
			bl = a*mat.sxy + b*mat.syy + c*mat.szy + d*mat.swy;
			cl = a*mat.sxz + b*mat.syz + c*mat.szz + d*mat.swz;
			dl = a*mat.tx + b*mat.ty + c*mat.tz + d*mat.tw;
			
			l = 1/Math.sqrt(al*al + bl*bl + cl*cl);
			al *= l;
			bl *= l;
			cl *= l;
			dl *= l;

			// do early test on bounding box, to determine if possibly straddling plane
			offset = 	(al > 0? al*_extentX : -al*_extentX) +
						(bl > 0? bl*_extentY : -bl*_extentY) +
						(cl > 0? cl*_extentZ : -cl*_extentZ);
			dist = al*_centerX + bl*_centerY + cl*_centerZ + dl;
			
			if (dist > offset) {
				id = node._positiveNode.nodeId;
				_vertices[id] = vertices;
				_faces[id] = faces;
				return Plane3D.FRONT;
			}
			if (dist < -offset) {
				if (createNeg) {
					id = node._negativeNode.nodeId;
					_vertices[id] = vertices;
					_faces[id] = faces;
				}
				return Plane3D.BACK;
			}
			
			i = vertices.length;
			// cache all vertex distances, so we don't need to do this per face
			while (--i >= 0) {
				v = Vertex(vertices[i]);
				dist = v._distance = v._x*al + v._y*bl + v._z*cl + dl;
				if (dist >= 0) {
					posVerts.push(v);
					++numPos;
				}
				if (dist <= 0) {
					if (createNeg) negVerts.push(v);
					++numNeg;
				}
			}
			
			if (numPos == 0) {
				if (createNeg) {
					id = node._negativeNode.nodeId;
					_vertices[id] = vertices;
					_faces[id] = faces;
				}
				return Plane3D.BACK;
			}
			if (numNeg == 0) {
				id = node._positiveNode.nodeId;
				_vertices[id] = vertices;
				_faces[id] = faces;
				return Plane3D.FRONT;
			}
			
			i =  faces.length;
			
			while (--i >= 0) {
				splitFace(Face(faces[i]), posFaces, negFaces, posVerts, negVerts);
			}
			
			id = node._positiveNode.nodeId;
			_vertices[id] = posVerts;
			_faces[id] = posFaces;
			if (createNeg) {
				id = node._negativeNode.nodeId;
				_vertices[id] = negVerts;
				_faces[id] = negFaces;
			}
			
			if (posFaces.length == 0) return Plane3D.BACK;
			if (createNeg && negFaces.length == 0) return Plane3D.FRONT;
			
			return Plane3D.INTERSECT;
		}
		
		private function splitFace(face : Face, posFaces : Array, negFaces : Array, posVerts : Array, negVerts : Array) : void
		{
			var uv0 : UV, uv1 : UV, uv2 : UV;
			var v : Vertex, uv : UV;
			var v0 : Vertex = face._v0,
				v1 : Vertex = face._v1,
				v2 : Vertex = face._v2;
			var d0 : Number = v0._distance,
				d1 : Number = v1._distance,
				d2 : Number = v2._distance;
			var t : Number;
			var posLen : int = -1, negLen : int = -1;
			var i : int, j : int;
			var material : ITriangleMaterial;
			
			// quick checks
			if (d0 > 0 && d1 > 0 && d2 > 0) {
				posFaces.push(face);
				return;
			}
			if (d0 < 0 && d1 < 0 && d2 < 0) {
				if (negFaces) negFaces.push(face);
				return;
			}
			
			uv0 = face._uv0;
			uv1 = face._uv1;
			uv2 = face._uv2;
			
			if (d0 >= 0) {
				_posFaceVerts[++posLen] = v0;
				_posFaceUV[posLen] = uv0;
			}
			if (d0 <= 0 && negFaces) {
				_negFaceVerts[++negLen] = v0;
				_negFaceUV[negLen] = uv0;
			}
			
			if (d0*d1 < 0) {
				t = d0/(d0-d1);
    			v = getNewVertex(v0._x + t*(v1._x-v0._x), v0._y + t*(v1._y-v0._y), v0._z + t*(v1._z-v0._z));
    			uv = getNewUV(uv0._u + t*(uv1._u-uv0._u), uv0._v + t*(uv1._v-uv0._v));
				posVerts.push(v);
				_posFaceVerts[++posLen] = v;
				_posFaceUV[posLen] = uv;
				if (negFaces) {
					negVerts.push(v);
					_negFaceVerts[++negLen] = v;
					_negFaceUV[negLen] = uv;
				}
			}
			
			if (d1 >= 0) {
				_posFaceVerts[++posLen] = v1;
				_posFaceUV[posLen] = uv1;
			}
			if (d1 <= 0 && negFaces) {
				_negFaceVerts[++negLen] = v1;
				_negFaceUV[negLen] = uv1;
			}
			
			if (d1*d2 < 0) {
				t = d1/(d1-d2);
        		v = getNewVertex(v1._x + t*(v2._x-v1._x), v1._y + t*(v2._y-v1._y), v1._z + t*(v2._z-v1._z));
        		uv = getNewUV(uv1._u + t*(uv2._u-uv1._u), uv1._v + t*(uv2._v-uv1._v));
        		posVerts.push(v);
    			_posFaceVerts[++posLen] = v;
				_posFaceUV[posLen] = uv;
				if (negFaces) {
					negVerts.push(v);
					_negFaceVerts[++negLen] = v;
					_negFaceUV[negLen] = uv;
				}
			}
			
			if (d2 >= 0) {
				_posFaceVerts[++posLen] = v2;
				_posFaceUV[posLen] = uv2;
			}
			if (d2 <= 0 && negFaces) {
				_negFaceVerts[++negLen] = v2;
				_negFaceUV[negLen] = uv2;
			}
			
			if (d2*d0 < 0) {
				t = d2/(d2-d0);
    			v = getNewVertex(v2._x + t*(v0._x-v2._x), v2._y + t*(v0._y-v2._y), v2._z + t*(v0._z-v2._z));
    			uv = getNewUV(uv2._u + t*(uv0._u-uv2._u), uv2._v + t*(uv0._v-uv2._v));
    			posVerts.push(v);
    			_posFaceVerts[++posLen] = v;
    			_posFaceUV[posLen] = uv;
    			if (negFaces) {
    				negVerts.push(v);
					_negFaceVerts[++negLen] = v;
					_negFaceUV[negLen] = uv;
    			}
			}
			
			
			// retriangulate
			material = face.material;
			v0 = _posFaceVerts[0];
			uv0 = _posFaceUV[0];
			i = 0;
    		j = 1;
    		while (++i < posLen) {
    			++j;
    			posFaces.push(getNewFace(v0, _posFaceVerts[i], _posFaceVerts[j], material, uv0, _posFaceUV[i], _posFaceUV[j]));
    		}
    		
    		if (negFaces) {
				v0 = _negFaceVerts[0];
				uv0 = _negFaceUV[0];
				i = 0;
	    		j = 1;
	    		while (++i < negLen) {
	    			++j;
	    			negFaces.push(getNewFace(v0, _negFaceVerts[i], _negFaceVerts[j], material, uv0, _negFaceUV[i], _negFaceUV[j]));
	    		}
    		}
		}
		
		public function setLeaf(id : int) : void
		{
			if (id < 0)
				_mesh = _sourceMesh;
			else
				_mesh = _splitMeshes[id];
		}

		public function get sourceMesh() : Mesh
		{
			return _sourceMesh;
		}
		
		public function get mesh() : Mesh
		{
			return _mesh;
		}
		
		private function getNewMesh() : Mesh
		{
			var mesh : Mesh = _meshPoolLen == -1? new Mesh() : _meshPool[_meshPoolLen--];
			mesh.transform = _sourceMesh.transform;
			mesh.type = _sourceMesh.type;
			mesh.material = _sourceMesh.material;
            mesh.outline = _sourceMesh.outline;
            mesh.back = _sourceMesh.back;
            mesh.bothsides = _sourceMesh.bothsides;
            mesh.debugbb = _sourceMesh.debugbb;
            _usedMeshes[++_usedMeshLen] = mesh;
			return mesh;
		}

		/*private function getNewGeometry() : Geometry
		{
			var geom : Geometry = _geomPoolLen == -1? new Geometry() : _geomPool[_geomPoolLen--];
//			geom.vertices.length = 0;
			_usedGeom[++_usedGeomLen] = geom;
			return geom;
		}*/
		
		private function getNewFace(v0:Vertex, v1:Vertex, v2:Vertex, material:ITriangleMaterial, uv0:UV, uv1:UV, uv2:UV) : Face
		{
			var face : Face = _facePoolLen == -1? new Face() : _facePool[_facePoolLen--];
			face.v0 = v0;
			face.v1 = v1;
			face.v2 = v2;
			face.material = material;
			face.uv0 = uv0;
			face.uv1 = uv1;
			face.uv2 = uv2;
			_usedFaces[++_usedFaceLen] = face;
			return face;
		}
		
		private function getNewVertex(x : Number, y : Number, z : Number) : Vertex
		{
			var v : Vertex = _vertexPoolLen == -1? new Vertex() : _vertexPool[_vertexPoolLen--];
			v.x = x;
			v.y = y;
			v.z = z;
			_usedVerts[++_usedVertLen] = v;
			return v; 
		}
		
		private function getNewUV(u : Number, v : Number) : UV
		{
			var uv : UV = _uvPoolLen == -1? new UV() : _uvPool[_uvPoolLen--];
			uv._u = u;
			uv._v = v;
			_usedUV[++_usedUVLen] = uv;
			return uv; 
		}
	}
}
