package com.xinguoedu.model.ftp.socket
{
	import com.xinguoedu.event.module.MainSocketEvt;
	import com.xinguoedu.model.ftp.utils.Command;
	import com.xinguoedu.model.ftp.utils.Parser;
	import com.xinguoedu.model.ftp.utils.Response;
	import com.xinguoedu.utils.Logger;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	
	/**
	 * 主连接 负责对FTP的长久连接 接收状态返回和发送控制命令
	 * @author yatsen_yang
	 */
	public class MainSocket extends EventDispatcher
	{		
		public static var main:MainSocket = null;	
		
		/** 注册的函数回调  **/		
		public var responseFunc:Function = null;
		
		private var _socket:Socket = null;
		
		public function MainSocket():void
		{
			_socket = new Socket();
			_socket.addEventListener(Event.CONNECT, response);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, response);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, close);
			_socket.addEventListener(Event.CLOSE, close);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, close);
		}
		
		/**
		 * 保证唯一控制连接实例
		 */
		public static function getInstance():MainSocket
		{
			if(main == null)
				main = new MainSocket();
			
			return main;
		}
		
		/**
		 * 连接FTP
		 * @param host ftp server ip
		 * @param port 
		 */
		public function connect(host:String, port:int):void
		{
			try
			{
				Security.loadPolicyFile("xmlsocket://" + host + ":843");
				_socket.connect(host, port);
			}
			catch(err:SecurityError)
			{
				close();
			}
			catch(err:IOError)
			{
			}
		}
		
		/**
		 * 发送命令
		 * @param comm
		 * Command Command instance
		 * @see com.elfish.ftp.model.Command
		 */
		public function send(comm:Command):void
		{
			if(!_socket.connected)
			{
				Logger.error("MainSocket", "not connected");
				dispatchEvent(new MainSocketEvt(MainSocketEvt.CLOSE));
				return;
			}
			_socket.writeMultiByte(comm.toExecuteString(), "utf8");
			_socket.flush();
		}
		
		/**
		 * 关闭连接
		 * 监听连接失败
		 */
		public function close(event:* = null):void
		{
			if(event)
			{
				Logger.error("MainSocket", event.toString());
			}
			
			/*_socket.removeEventListener(Event.CONNECT, response);
			_socket.removeEventListener(ProgressEvent.SOCKET_DATA, response);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, close);
			_socket.removeEventListener(Event.CLOSE, close);
			_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, close);
			_socket.close();
			_socket = null;*/		
			
			if(event is SecurityErrorEvent)
			{
				_socket.close();	
				dispatchEvent(new MainSocketEvt(MainSocketEvt.CLOSE));	
			}						
		}
		
		/**
		 * 状态返回监听函数
		 * 处理返回的状态码以及所带的数据
		 * 使用Parser进行数据解析,提取有用数据
		 * @see com.elfish.ftp.util.Parser
		 */
		public function response(event:*):void
		{
			var message:String = _socket.readMultiByte(_socket.bytesAvailable, "utf-8");
			var messageList:Array = message.split("\r\n");
			
			Logger.info("MainSocket" , messageList.toString());
				
			for(var i:Number=0;i<messageList.length;i++)
			{	
				if(messageList[i].length > 0) 
				{					
					var result:Response = Parser.standableParse(messageList[i]);
					if(result.code == 257)
						result = Parser.directoryParse(result);
					else if(result.code == 227)
						result = Parser.modelParse(result);
	
					responseFunc.call(null, result);
				}
			}
		}

	}
}