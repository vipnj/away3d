﻿package away3d.core.draw{	import away3d.materials.*;	     /** Fog primitive class */    public class DrawFog extends DrawPrimitive    {		public var material:IFogMaterial;				public override function render():void        {			 material.renderFog(this);        }     }}