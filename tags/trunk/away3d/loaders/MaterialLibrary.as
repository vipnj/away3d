package away3d.loaders
{
    import away3d.core.material.*;
    import flash.utils.Dictionary;
    
    /** Set of the named materials */
    public class MaterialLibrary
    {
        private var materials:Dictionary = new Dictionary();
    
        public function MaterialLibrary(def:ITriangleMaterial = null):void
        {
        }
    
        public function add(material:ITriangleMaterial, name:String):void
        {
            materials[name] = material;
        }
    
        public function getMaterial(name:String):ITriangleMaterial
        {
            return materials[name];
        }
    
    }
}
