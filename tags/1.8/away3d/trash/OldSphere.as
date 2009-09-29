package away3d.trash
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
    
    /** Sphere */ 
    public class OldSphere extends Mesh3D
    {
        public var segmentsW:int = 8;
        public var segmentsH:int = 6;

        public function OldSphere(material:IMaterial, init:Object = null)
        {
            super(material, init);
            
            init = Init.parse(init);

            segmentsW = init.getInt("segmentsW", 3, {min:3});
            segmentsH = init.getInt("segmentsH", 2, {min:2})
            var radius:Number = init.getNumber("radius", 100, {min:0});

            buildSphere(radius);
        }
    
        private function buildSphere(radius:Number):void
        {
            var i:int;
            var j:int;
            var grid:Array = [];

            for (j = 0; j <= segmentsH; j++)  
            { 
                var horangle:Number = j / segmentsH * Math.PI;
                var z:Number = -radius * Math.cos(horangle);
                var ringradius:Number = radius * Math.sin(horangle);
                var row:Array = [];
                var vertex:Vertex3D;

                for (i = 0; i < segmentsW; i++) 
                { 
                    var verangle:Number = 2 * i / segmentsW;
                    var x:Number = ringradius * Math.sin(verangle*Math.PI);
                    var y:Number = ringradius * Math.cos(verangle*Math.PI);

                    if (((0 < j) && (j < segmentsH)) || (i == 0)) 
                    { 
                        vertex = new Vertex3D(y,z,x);
                        vertices.push(vertex);
                    }
                    row.push(vertex);
                }
                grid.push(row);
            }

            for (j = 1; j <= segmentsH; j++) 
            {
                for (i = 0; i < segmentsW; i++) 
                {
                    var a:Vertex3D = grid[j][i];
                    var b:Vertex3D = grid[j][(i-1+segmentsW) % segmentsW];
                    var c:Vertex3D = grid[j-1][(i-1+segmentsW) % segmentsW];
                    var d:Vertex3D = grid[j-1][i];

                    var vab:Number = j     / (segmentsH + 1);
                    var vcd:Number = (j-1) / (segmentsH + 1);
                    var uad:Number = (i+1) / segmentsW;
                    var ubc:Number = i     / segmentsW;
                    var uva:UV = new UV(uad,vab);
                    var uvb:UV = new UV(ubc,vab);
                    var uvc:UV = new UV(ubc,vcd);
                    var uvd:UV = new UV(uad,vcd);

                    if (j < segmentsH)  
                        faces.push(new Face3D(a,b,c, null, uva,uvb,uvc));
                    if (j > 1)                
                        faces.push(new Face3D(a,c,d, null, uva,uvc,uvd));
                }
            }
        }
    }
}