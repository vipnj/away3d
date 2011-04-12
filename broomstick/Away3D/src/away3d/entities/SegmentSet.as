﻿package away3d.entities{	import away3d.animators.data.AnimationBase;	import away3d.animators.data.AnimationStateBase;	import away3d.animators.data.NullAnimation;	import away3d.arcane;	import away3d.bounds.BoundingSphere;	import away3d.bounds.BoundingVolumeBase;	import away3d.containers.View3D;	import away3d.core.base.IRenderable;	import away3d.core.partition.EntityNode;	import away3d.core.partition.RenderableNode;	import away3d.materials.MaterialBase;	import away3d.materials.SegmentMaterial;	import away3d.primitives.data.Segment;	import flash.display3D.Context3D;	import flash.display3D.IndexBuffer3D;	import flash.display3D.VertexBuffer3D;	use namespace arcane;	public class SegmentSet extends Entity implements IRenderable	{		private var _material : MaterialBase;		private var _nullAnimation : NullAnimation;		private var _animationState : AnimationStateBase;		private var _vertices : Vector.<Number>;		private var _segments : Vector.<Segment>;		private var _numVertices : uint;		private var _indices : Vector.<uint>;		private var _numIndices : uint;		private var _vertexBufferDirty : Boolean;		private var _indexBufferDirty : Boolean;		private var _vertexBuffer : VertexBuffer3D;		private var _indexBuffer : IndexBuffer3D;		private var _lineCount : uint;		public function SegmentSet(view : View3D)		{			super();			_nullAnimation ||= new NullAnimation();			_vertices = new Vector.<Number>();			_segments = new Vector.<Segment>();			_numVertices = 0;			_indices = new Vector.<uint>();			material = new SegmentMaterial(view.width, view.height);		}		public function addSegment(segment : Segment) : void		{			var t : Number = segment.thickness;			var colors : Vector.<Number> = segment.rgbColorVector;			var verts : Vector.<Number> = segment.vertices;			// to do add support for CurveSegment 			_vertices.push(	verts[0], verts[1], verts[2], verts[3], verts[4], verts[5], t, colors[0], colors[1], colors[2], 1,							verts[3], verts[4], verts[5], verts[0], verts[1], verts[2], -t, colors[3], colors[4], colors[5], 1,							verts[0], verts[1], verts[2], verts[3], verts[4], verts[5], -t, colors[0], colors[1], colors[2], 1,							verts[3], verts[4], verts[5], verts[0], verts[1], verts[2], t, colors[3], colors[4], colors[5], 1);			_segments.push(segment);			segment.segmentsBase = this;			var index : uint = _lineCount << 2;			segment.index = _indices.length;			_indices.push(index, index + 1, index + 2, index + 3, index + 2, index + 1);			_numVertices = _vertices.length / 11;			_numIndices = _indices.length;			_vertexBufferDirty = true;			_indexBufferDirty = true;			_lineCount++;		}		arcane function updateSegment(segment : Segment) : void		{			//to do add support for curve segment			var verts : Vector.<Number> = segment.vertices;			var colors : Vector.<Number> = segment.rgbColorVector;			var index : uint = segment.index;			var t : Number = segment.thickness;			_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = t;			_vertices[index++] = colors[0];			_vertices[index++] = colors[1];			_vertices[index++] = colors[2];			_vertices[index++] = 1;			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = -t;			_vertices[index++] = colors[3];			_vertices[index++] = colors[4];			_vertices[index++] = colors[5];			_vertices[index++] = 1;			_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = -t;			_vertices[index++] = colors[0];			_vertices[index++] = colors[1];			_vertices[index++] = colors[2];			_vertices[index++] = 1;			_vertices[index++] = verts[3];			_vertices[index++] = verts[4];			_vertices[index++] = verts[5];			_vertices[index++] = verts[0];			_vertices[index++] = verts[1];			_vertices[index++] = verts[2];			_vertices[index++] = t;			_vertices[index++] = colors[3];			_vertices[index++] = colors[4];			_vertices[index++] = colors[5];			_vertices[index++] = 1;			_vertexBufferDirty = true;		}		private function remove(index : uint) : void		{			var indVert : uint = _indices[index] * 11;			_indices.splice(index, 6);			_vertices.splice(indVert, 44);			_numVertices = _vertices.length / 11;			_numIndices = _indices.length;			_vertexBufferDirty = true;			_indexBufferDirty = true;		}		public function removeSegment(segment : Segment) : void		{			//to do, add support curve indices/offset			var index : uint;			for (var i : uint = 0; i < _segments.length; ++i) {				if (_segments[i] == segment) {					_segments.splice(i, 1);					remove(segment.index);					_lineCount--;				} else {					_segments[i].index = index;					index += 6;				}			}			_vertexBufferDirty = true;			_indexBufferDirty = true;		}		public function getVertexBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			if (_vertexBufferDirty) {				_vertexBuffer = context.createVertexBuffer(_numVertices, 11);				_vertexBuffer.uploadFromVector(_vertices, 0, _numVertices);				_vertexBufferDirty = false;			}			return _vertexBuffer;		}		public function getUVBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			return null;		}		public function getVertexNormalBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			return null;		}		public function getVertexTangentBuffer(context : Context3D, contextIndex : uint) : VertexBuffer3D		{			return null;		}		public function getIndexBuffer(context : Context3D, contextIndex : uint) : IndexBuffer3D		{			if (_indexBufferDirty) {				_indexBuffer = context.createIndexBuffer(_numIndices);				_indexBuffer.uploadFromVector(_indices, 0, _numIndices);				_indexBufferDirty = false;			}			return _indexBuffer;		}		public function get mouseDetails() : Boolean		{			return false;		}		public function get numTriangles() : uint		{			return _numIndices / 3;		}		public function get sourceEntity() : Entity		{			return this;		}		public function get castsShadows() : Boolean		{			return false;		}		public function get material() : MaterialBase		{			return _material;		}		public function get animation() : AnimationBase		{			return _nullAnimation;		}		public function get animationState() : AnimationStateBase		{			return _animationState;		}		public function set material(value : MaterialBase) : void		{			if (value == _material) return;			if (_material) _material.removeOwner(this);			_material = value;			if (_material) _material.addOwner(this);		}		override protected function getDefaultBoundingVolume() : BoundingVolumeBase		{			return new BoundingSphere();		}		override protected function updateBounds() : void		{			// todo: fix bounds			_bounds.fromExtremes(-100, -100, 0, 100, 100, 0);			_boundsInvalid = false;		}		override protected function createEntityPartitionNode() : EntityNode		{			return new RenderableNode(this);		}	}}