package com.xinguoedu.model.ftp.process
{
	import com.xinguoedu.model.ftp.socket.MainSocket;
	import com.xinguoedu.model.ftp.utils.Command;
	import com.xinguoedu.model.ftp.utils.Response;
	
	import flash.events.EventDispatcher;
	
	/**
	 * 登录ftp server, 上传文件到ftp server等等都是一个过程
	 * 此类为过程基类
	 * @author yatsen_yang
	 * 
	 */	
	public class BaseProcess extends EventDispatcher
	{
		protected var _list:Array;
		protected var _mainSocket:MainSocket;
		
		public function BaseProcess(mainSocket:MainSocket)
		{
			_list = [];
			_mainSocket = mainSocket;
			_mainSocket.responseFunc = response;
		}
		
		/**
		 * 执行命令函数
		 * 由子类重写 
		 * 
		 */		
		public function executeCommand():void
		{
			if(_list.length > 0) 
			{
				_mainSocket.send(_list[0] as Command);
				trace((_list[0] as Command).toExecuteString());
				_list.shift();
			}
		}
		
		/**
		 * 处理收到的从服务器返回的数据
		 * 由子类重写 
		 * 
		 */		
		public function response(rsp:Response):void
		{
			
		}
	}
}