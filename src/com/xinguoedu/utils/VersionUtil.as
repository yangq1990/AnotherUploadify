package com.xinguoedu.utils
{
	import flash.utils.ByteArray;

	/**
	 * 版本处理工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class VersionUtil
	{		
		[Embed(source="../.version",mimeType='application/octet-stream')]
		private var versionXml:Class;
		
		public function VersionUtil()
		{
		}
		
		/**
		 * 读取版本配置文件 
		 * @param func
		 * 
		 */		
		public function getVersion(func:Function):void
		{
			if(func == null)
			{
				throw Error("function should not be null");
				return;
			}			
			
			var ba:ByteArray = new versionXml as ByteArray;
			var vxml:XML=new XML(ba.readUTFBytes(ba.length));
			
			func("version:" + vxml.value + "-" + vxml.date + " yangqiao9@gmail.com");				
		}		
	}
}