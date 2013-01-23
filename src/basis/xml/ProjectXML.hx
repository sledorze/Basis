package basis.xml;

import sys.FileSystem;
import sys.io.File;
import haxe.xml.Fast;

enum TargetType
{
	Apple;
	Android;
}

typedef Target = 
{
	var type:TargetType;
	var data:Fast;
}

class ProjectXML
{
	public var xmlPath(default, null):String;
	public var name(default, null):String;
	public var baseBuildPath(default, null):String;
	public var targets(default, null):Hash<Target>;
	public var srcPaths(default, null):Array<String>;
	
	private var _fastXML:Fast;
	
	public function new(xmlPath:String)
	{
		this.xmlPath = xmlPath;
		targets = new Hash<Target>();
		srcPaths = new Array<String>();
	}
	
	public function parse():Void
	{
		if(!FileSystem.exists(xmlPath))
			throw "File not found: " + xmlPath;
			
		var data:String = File.getContent(xmlPath);
		var xml:Xml = Xml.parse(data);
		
		_fastXML = new  Fast(xml.firstElement());
		
		name = _fastXML.att.name;
		
		for( target in _fastXML.nodes.target )
			parseTarget(target);
			
		for( src in _fastXML.nodes.src )
			parseSrc(src);
			
		parseBaseBuildPath(_fastXML.node.builddir);
	}
	
	private function parseBaseBuildPath(buildDir:Fast):Void
	{
		baseBuildPath = buildDir.att.path;
	}
	
	private function parseTarget(target:Fast):Void
	{
		switch(target.att.name)
		{
			case Std.string(TargetType.Apple):
				targets.set(target.att.name, {type:TargetType.Apple, data:target});
			
			case Std.string(TargetType.Android):
				targets.set(target.att.name, {type:TargetType.Android, data:target});
			
			default:
				throw "Target not supported: " + target.att.name;
		}
	}
	
	private function parseSrc(src:Fast):Void
	{
		srcPaths.push(src.att.path);
	}
}