package com.xinguoedu.model.ftp
{
	import cn.wecoding.utils.YatsenLog;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import com.xinguoedu.utils.Config;
	
	/**
	 * 数据连接 负责被动模式下与FTP的连接
	 * @author yatsen_yang
	 */
	public class DataSocket extends EventDispatcher
	{
		private var socket:Socket = null;
		
		public var pending:Number = 0;
		
		/** 注册的函数回调  **/		
		public var responseFunc:Function = null;	
		
		/** FTP文件信息为空，即没有数据返回时调用  **/
		public var noSocketDataBackFunc:Function = null;
		
		/**
		 * 所接收到的数据
		 */
		private var _byteArray:ByteArray = new ByteArray();
		
		private var _haveSocketData:Boolean = false;
		
		public function DataSocket()
		{
			socket = new Socket();
			socket.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, pendingHandler);
			socket.addEventListener(IOErrorEvent.IO_ERROR, close);
			socket.addEventListener(Event.CLOSE, close);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, response);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, close);
		}
		
		/**
		 * 连接服务器
		 */
		public function connect(config:Config):void
		{
			YatsenLog.info("data socket--->" + config.host + ":" + config.port);
			Security.loadPolicyFile("http://192.168.1.194:8140/crossdomain.xml");
			socket.connect(config.host, int(config.port));
		}
		
		/**
		 * 关闭连接
		 * 监听连接失败
		 */
		public function close(event:* = null):void
		{
			YatsenLog.info("data socket close--->" + event);
			socket.close();
			if(event != null && !_haveSocketData && noSocketDataBackFunc != null)
			{
				noSocketDataBackFunc();
			}
		}
		
		/**
		 * 向FTP写入数据
		 * @param byte
		 * ByteArray Data
		 */
		public function write(byte:ByteArray):void
		{
			socket.writeBytes(byte);
			socket.flush();
		}
		
		/**
		 * 读取从数据连接缓存里获取的数据
		 * @return ByteArray
		 */
		public function read():ByteArray
		{
			return _byteArray;
		}
		
		/**
		 * 数据返回时,将数据写入byte
		 * 如果FTP Server上没有文件，则此函数不会被调用
		 */
		public function response(event:*):void
		{
			_haveSocketData = true;
			//这里用utf-8读，遇到中文会出现乱码，don't know why
			var str:String = socket.readMultiByte(socket.bytesAvailable, "gb2312");
			(responseFunc != null) && responseFunc.call(null, str);
		}
		
		/**
		 *  
		 * @return 是否有socket data返回 
		 * 
		 */		
		public function get haveSocketData():Boolean
		{
			return _haveSocketData;
		}
		
		/**
		 * 推送数据时的回调
		 */
		public function pendingHandler(event:OutputProgressEvent):void
		{
			pending = event.bytesPending;
		}

	}
}