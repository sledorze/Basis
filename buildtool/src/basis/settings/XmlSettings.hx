package basis.settings;

import sys.FileSystem;
import sys.io.File;
import haxe.xml.Fast;

class XmlSettings implements ISettings
{
	public var target(default, null):Target;

	public var xmlPath(default, null):String;
	private var _fastXML:Fast;
	
	public function new(xmlPath:String)
	{
		this.xmlPath = xmlPath;
		target = createTarget();
	}
	
	
	public function retrieve(completeHandler:Target->Void, errorHandler:String->Void):Void
	{
		if(!FileSystem.exists(xmlPath))
			errorHandler("File not found: " + xmlPath);
		
		var data:String = File.getContent(xmlPath);
		var xml:Xml = Xml.parse(data);
		_fastXML = new  Fast(xml.firstElement());
		
		parseTarget(_fastXML, target);
		
		completeHandler(target);
	}
	
	private function createTarget(?parentTarget:Target=null):Target
	{
		return new Target(parentTarget);
	}
	
	private function parseTarget(targetXML:Fast, currentTarget:Target):Void
	{
		if(targetXML.has.name)
			currentTarget.setSetting(Target.NAME, targetXML.att.name);
		
		if(targetXML.has.type)
			currentTarget.setSetting(Target.TYPE, targetXML.att.type.toLowerCase());
			
		if(targetXML.hasNode.main)
			parseMain(targetXML.node.main, currentTarget);
			
		if(targetXML.hasNode.builddir)
			parseBaseBuildPath(targetXML.node.builddir, currentTarget);
			
		for( source in targetXML.nodes.source )
			parseSourcePath(source, currentTarget);
			
		for( haxelib in targetXML.nodes.haxelib )
			parseHaxelib(haxelib, currentTarget);
			
		for( asset in targetXML.nodes.asset )
			parseAssetPath(asset, currentTarget);
		
		for(childTargetXML in targetXML.nodes.target)
		{
			var childTarget:Target = createTarget(currentTarget);
			currentTarget.subTargets.push(childTarget);
			parseTarget(childTargetXML, childTarget);
		}
	}
	
	private function parseBaseBuildPath(buildDir:Fast, currentTarget:Target):Void
	{
		currentTarget.setSetting(Target.BUILD_DIR, buildDir.att.path);
	}
	
	private function parseMain(mainXML:Fast, currentTarget:Target):Void
	{
		currentTarget.setSetting(Target.MAIN, mainXML.att.classpath);
	}
	
	private function parseSourcePath(src:Fast, currentTarget):Void
	{
		currentTarget.addToCollection(Target.SOURCE_PATHS, src.att.path);
	}
	
	private function parseHaxelib(haxelib:Fast, currentTarget):Void
	{
		currentTarget.addToCollection(Target.HAXE_LIBS, haxelib.att.name);
	}
	
	private function parseCommandLineArgument(arg:Fast, currentTarget):Void
	{
		currentTarget.addToCollection(Target.COMMAND_LINE_ARGUMENTS, arg.att.name);
	}
	
	private function parseAssetPath(assetPathXML:Fast, currentTarget):Void
	{
		currentTarget.addToCollection(Target.ASSET_PATHS, assetPathXML.att.path);
	}
}