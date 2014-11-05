package com.xinguoedu.model.ftp.utils
{
	import com.xinguoedu.utils.Config;

	/**
	 * 返回状态解析类
	 */
	public class Parser
	{
		
		/**
		 * 标准解析
		 * 解析结果包含:状态码,文本
		 */
		public static function standableParse(message:String):Response
		{
			var code:int = int(message.substr(0, 3));
			var text:String = message.substr(4);
			return new Response(code, text);
		}
		
		/**
		 * 目录解析
		 * 解析结果包含:状态码,文本,当前目录路径
		 */
		public static function directoryParse(response:Response):Response
		{
			var text:String = response.text;
			var data:String = text.substr(text.indexOf('"')+1, text.lastIndexOf('"')-1);
			response.data = data;
			return response;
		}
		
		/**
		 * 被动模式解析
		 * 解析结果包含:状态码,文本,被动连接地址和端口
		 */
		public static function modelParse(response:Response):Response
		{
			var text:String = response.text;
			var datas:Array = text.substr(text.indexOf('(')+1, text.lastIndexOf(')')-1).split(",");
			var port:int = parseInt(datas[4])*256+parseInt(datas[5]);
		
			trace("被动模式", text,datas,port);
		
			var config:Config = new Config();
			config.host = datas[0]+"."+datas[1]+"."+datas[2]+"."+datas[3];
			config.port = port.toString();

			response.data = config;
			return response;
		}
	}
}