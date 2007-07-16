package away3d.core
{
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.loaders.*;

    import flash.display.BitmapData;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    //import mx.core.BitmapAsset;

    /** Helper class for casting assets to usable objects */
    public class Cast
    {
        public static function string(data:*):String
        {
            if (data is Class)
                data = new data;

            if (data is String)
                return data;

            return String(data);
        }
    
        public static function bytearray(data:*):ByteArray
        {
            if (data is Class)
                data = new data;

            if (data is ByteArray)
                return data;

            return ByteArray(data);
        }
    
        public static function xml(data:*):XML
        {
            if (data is Class)
                data = new data;

            if (data is XML)
                return data;

            return XML(data);
        }
    
        private static var colornames:Dictionary;

        public static function trycolor(data:*):uint
        {
            if (data is uint)
                return data as uint;

            if (data is int)
                return data as uint;

            if (data is String)
            {
                if (data == "random")
                    return uint(Math.random()*0x1000000);
            
                if (colornames == null)
                {
                    colornames = new Dictionary();
                    colornames["steelblue"] = 0x4682B4;
                    colornames["royalblue"] = 0x041690;
                    colornames["cornflowerblue"] = 0x6495ED;
                    colornames["lightsteelblue"] = 0xB0C4DE;
                    colornames["mediumslateblue"] = 0x7B68EE;
                    colornames["slateblue"] = 0x6A5ACD;
                    colornames["darkslateblue"] = 0x483D8B;
                    colornames["midnightblue"] = 0x191970;
                    colornames["navy"] = 0x000080;
                    colornames["darkblue"] = 0x00008B;
                    colornames["mediumblue"] = 0x0000CD;
                    colornames["blue"] = 0x0000FF;
                    colornames["dodgerblue"] = 0x1E90FF;
                    colornames["deepskyblue"] = 0x00BFFF;
                    colornames["lightskyblue"] = 0x87CEFA;
                    colornames["skyblue"] = 0x87CEEB;
                    colornames["lightblue"] = 0xADD8E6;
                    colornames["powderblue"] = 0xB0E0E6;
                    colornames["azure"] = 0xF0FFFF;
                    colornames["lightcyan"] = 0xE0FFFF;
                    colornames["paleturquoise"] = 0xAFEEEE;
                    colornames["mediumturquoise"] = 0x48D1CC;
                    colornames["lightseagreen"] = 0x20B2AA;
                    colornames["darkcyan"] = 0x008B8B;
                    colornames["teal"] = 0x008080;
                    colornames["cadetblue"] = 0x5F9EA0;
                    colornames["darkturquoise"] = 0x00CED1;
                    colornames["aqua"] = 0x00FFFF;
                    colornames["cyan"] = 0x00FFFF;
                    colornames["turquoise"] = 0x40E0D0;
                    colornames["aquamarine"] = 0x7FFFD4;
                    colornames["mediumaquamarine"] = 0x66CDAA;
                    colornames["darkseagreen"] = 0x8FBC8F;
                    colornames["mediumseagreen"] = 0x3CB371;
                    colornames["seagreen"] = 0x2E8B57;
                    colornames["darkgreen"] = 0x006400;
                    colornames["green"] = 0x008000;
                    colornames["forestgreen"] = 0x228B22;
                    colornames["limegreen"] = 0x32CD32;
                    colornames["lime"] = 0x00FF00;
                    colornames["chartreuse"] = 0x7FFF00;
                    colornames["lawngreen"] = 0x7CFC00;
                    colornames["greenyellow"] = 0xADFF2F;
                    colornames["yellowgreen"] = 0x9ACD32;
                    colornames["palegreen"] = 0x98FB98;
                    colornames["lightgreen"] = 0x90EE90;
                    colornames["springgreen"] = 0x00FF7F;
                    colornames["mediumspringgreen"] = 0x00FA9A;
                    colornames["darkolivegreen"] = 0x556B2F;
                    colornames["olivedrab"] = 0x6B8E23;
                    colornames["olive"] = 0x808000;
                    colornames["darkkhaki"] = 0xBDB76B;
                    colornames["darkgoldenrod"] = 0xB8860B;
                    colornames["goldenrod"] = 0xDAA520;
                    colornames["gold"] = 0xFFD700;
                    colornames["yellow"] = 0xFFFF00;
                    colornames["khaki"] = 0xF0E68C;
                    colornames["palegoldenrod"] = 0xEEE8AA;
                    colornames["blanchedalmond"] = 0xFFEBCD;
                    colornames["moccasin"] = 0xFFE4B5;
                    colornames["wheat"] = 0xF5DEB3;
                    colornames["navajowhite"] = 0xFFDEAD;
                    colornames["burlywood"] = 0xDEB887;
                    colornames["tan"] = 0xD2B48C;
                    colornames["rosybrown"] = 0xBC8F8F;
                    colornames["sienna"] = 0xA0522D;
                    colornames["saddlebrown"] = 0x8B4513;
                    colornames["chocolate"] = 0xD2691E;
                    colornames["peru"] = 0xCD853F;
                    colornames["sandybrown"] = 0xF4A460;
                    colornames["darkred"] = 0x8B0000;
                    colornames["maroon"] = 0x800000;
                    colornames["brown"] = 0xA52A2A;
                    colornames["firebrick"] = 0xB22222;
                    colornames["indianred"] = 0xCD5C5C;
                    colornames["lightcoral"] = 0xF08080;
                    colornames["salmon"] = 0xFA8072;
                    colornames["darksalmon"] = 0xE9967A;
                    colornames["lightsalmon"] = 0xFFA07A;
                    colornames["coral"] = 0xFF7F50;
                    colornames["tomato"] = 0xFF6347;
                    colornames["darkorange"] = 0xFF8C00;
                    colornames["orange"] = 0xFFA500;
                    colornames["orangered"] = 0xFF4500;
                    colornames["crimson"] = 0xDC143C;
                    colornames["red"] = 0xFF0000;
                    colornames["deeppink"] = 0xFF1493;
                    colornames["fuchsia"] = 0xFF00FF;
                    colornames["magenta"] = 0xFF00FF;
                    colornames["hotpink"] = 0xFF69B4;
                    colornames["lightpink"] = 0xFFB6C1;
                    colornames["pink"] = 0xFFC0CB;
                    colornames["palevioletred"] = 0xDB7093;
                    colornames["mediumvioletred"] = 0xC71585;
                    colornames["purple"] = 0x800080;
                    colornames["darkmagenta"] = 0x8B008B;
                    colornames["mediumpurple"] = 0x9370DB;
                    colornames["blueviolet"] = 0x8A2BE2;
                    colornames["indigo"] = 0x4B0082;
                    colornames["darkviolet"] = 0x9400D3;
                    colornames["darkorchid"] = 0x9932CC;
                    colornames["mediumorchid"] = 0xBA55D3;
                    colornames["orchid"] = 0xDA70D6;
                    colornames["violet"] = 0xEE82EE;
                    colornames["plum"] = 0xDDA0DD;
                    colornames["thistle"] = 0xD8BFD8;
                    colornames["lavender"] = 0xE6E6FA;
                    colornames["ghostwhite"] = 0xF8F8FF;
                    colornames["aliceblue"] = 0xF0F8FF;
                    colornames["mintcream"] = 0xF5FFFA;
                    colornames["honeydew"] = 0xF0FFF0;
                    colornames["lightgoldenrodyellow"] = 0xFAFAD2;
                    colornames["lemonchiffon"] = 0xFFFACD;
                    colornames["cornsilk"] = 0xFFF8DC;
                    colornames["lightyellow"] = 0xFFFFE0;
                    colornames["ivory"] = 0xFFFFF0;
                    colornames["floralwhite"] = 0xFFFAF0;
                    colornames["linen"] = 0xFAF0E6;
                    colornames["oldlace"] = 0xFDF5E6;
                    colornames["antiquewhite"] = 0xFAEBD7;
                    colornames["bisque"] = 0xFFE4C4;
                    colornames["peachpuff"] = 0xFFDAB9;
                    colornames["papayawhip"] = 0xFFEFD5;
                    colornames["beige"] = 0xF5F5DC;
                    colornames["seashell"] = 0xFFF5EE;
                    colornames["lavenderblush"] = 0xFFF0F5;
                    colornames["mistyrose"] = 0xFFE4E1;
                    colornames["snow"] = 0xFFFAFA;
                    colornames["white"] = 0xFFFFFF;
                    colornames["whitesmoke"] = 0xF5F5F5;
                    colornames["gainsboro"] = 0xDCDCDC;
                    colornames["lightgrey"] = 0xD3D3D3;
                    colornames["silver"] = 0xC0C0C0;
                    colornames["darkgrey"] = 0xA9A9A9;
                    colornames["grey"] = 0x808080;
                    colornames["lightslategrey"] = 0x778899;
                    colornames["slategrey"] = 0x708090;
                    colornames["dimgrey"] = 0x696969;
                    colornames["darkslategrey"] = 0x2F4F4F;
                    colornames["black"] = 0x000000;
                    colornames["transparent"] = 0xFF000000;
                }
            
                if (colornames[data] != null)
                    return colornames[data];
            
                //throw new Error(data+" "+parseInt("0x"+data));
                if (data.length == 6)
                    return parseInt("0x"+data);
            }

            return 0xFFFFFFFF;                                  
        }

        public static function color(data:*):uint
        {
            var result:uint = trycolor(data);

            if (result == 0xFFFFFFFF)
                throw new Error("Can't cast to color: "+data);

            return result;
        }

        public static function bitmap(data:*):BitmapData
        {
            if (data == null)
                return null;

            if (data is Class)
                data = new data;

            if (data is BitmapData)
                return data;

            if (data.hasOwnProperty("bitmapData")) // if (data is BitmapAsset)
                return data.bitmapData;

            throw new Error("Can't cast to bitmap: "+data);
        }

        public static function material(data:*):IMaterial
        {
            if (data == null)
                return null;

            if (data is Class)
                data = new data;

            if (data is IMaterial)
                return data;

            if (data is int) 
                return new ColorMaterial(data);

            if (data is String) 
            {
                if (data == "")
                    return null;

                if (data == "transparent")
                    return new TransparentMaterial();

                if (data.indexOf("#") == -1)
                    return new ColorMaterial(color(data));
                else
                {
                    if (data == "#")
                        return new WireframeMaterial();

                    var hash:Array = data.split("#");
                    if (hash[1] == "")
                        return new WireColorMaterial(color(hash[0]));

                    if (hash[1].indexOf("|") == -1)
                    {
                        if (hash[0] == "")
                            return new WireframeMaterial(color(hash[1]));
                        else
                            return new WireColorMaterial(color(hash[0]), {wirecolor:color(hash[1])});
                    }
                    else
                    {
                        var line:Array = hash[1].split("|");
                        if (hash[0] == "")
                            //throw new Error(line[0]+" <-> "+line[1]); 
                            return new WireframeMaterial(color(line[0]), {width:parseFloat(line[1])});
                        else
                            return new WireColorMaterial(color(hash[0]), {wirecolor:color(line[0]), width:parseFloat(line[1])});
                    }
                }
            }

            if (data is BitmapData)
                return new BitmapMaterial(data, {smooth:true});

            if (data.hasOwnProperty("bitmapData")) // if (data is BitmapAsset)
                return new BitmapMaterial(data.bitmapData, {smooth:true});

            throw new Error("Can't cast to material: "+data);
        }

        public static function library(data:*):MaterialLibrary
        {
            if (data == null)
                return new MaterialLibrary();

            if (data is Class)
                data = new data;

            if (data is MaterialLibrary)
                return data;

            /*
            if (data is IMaterial)
                return new MaterialLibrary(data);

            if (data is BitmapData)
                return new MaterialLibrary(new BitmapMaterial(data, {smooth:true}));

            // if (data is BitmapAsset)
            if (data.bitmapData) 
                return new MaterialLibrary(new BitmapMaterial(data.bitmapData, {smooth:true}));
            */

            var result:MaterialLibrary = new MaterialLibrary();
            for (var name:String in data)
                result.add(Cast.material(data[name]), name);

            return result;
        }

    }
}
