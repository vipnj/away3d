package away3d.core.block
{
    import away3d.core.draw.*;

    /** Abstract primitive that can block other primitives from drawing */
    public class Blocker extends DrawPrimitive
    {
        /*
        public var screenZ:Number;
        public var minX:int;
        public var maxX:int;
        public var minY:int;
        public var maxY:int;

        public function contains(x:Number, y:Number):Boolean
        {   
            return false;
        }
        */
        public function block(pri:DrawPrimitive):Boolean
        {
            return false;
        }

    }
}
