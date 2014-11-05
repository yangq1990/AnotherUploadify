package com.xinguoedu.utils
{	
	/**
	 * 配置
	 * 包含地址,端口,用户名和密码等信息
	 * @author yatsen_yang
	 */
	public class Config
	{
		private var _protocol:String;
		private var _url:String;
		private var _host:String;
		private var _port:String;
		private var _user:String;
		private var _pass:String;
		private var _description:String;
		private var _extension:String;
		private var _chunkSize:int;
		private var _interval:int;
		private var _field:String = "Filedata";
		
		public function Config()
		{
			
		}
		
		/**
		 * ftp主机 
		 * @return 
		 * 
		 */		
		public function get host():String 
		{
			return this._host;
		}
		
		public function set host(value:String):void
		{
			_host = value;
		}
		
		/**
		 * ftp上传端口 
		 * @return 
		 * 
		 */		
		public function get port():String 
		{
			return this._port;
		}
		
		public function set port(value:String):void
		{
			_port = value;
		}
		
		/**
		 * ftp登陆账号 
		 * @return 
		 * 
		 */		
		public function get user():String 
		{
			return this._user;
		}
		
		public function set user(value:String):void
		{
			_user = value;
		}
		
		/**
		 * ftp登陆密码 
		 * @return 
		 * 
		 */		
		public function get pass():String 
		{
			return this._pass;
		}	

		public function set pass(value:String):void
		{
			_pass = value;
		}
		
		/**
		 * 文件对话框描述信息 
		 * @return 
		 * 
		 */		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}
		
		/**
		 * 上传文件的扩展名
		 * @return 
		 * 
		 */		
		public function get extension():String
		{
			return _extension;
		}
		
		public function set extension(value:String):void
		{
			_extension = value;
		}

		/**
		 * ftp socket每次数据发送的大小 
		 * @return 
		 * 
		 */		
		public function get chunkSize():int
		{
			return _chunkSize;
		}

		public function set chunkSize(value:int):void
		{
			_chunkSize = value;
		}

		/**
		 * ftp数据发送间隔 
		 * @return 
		 * 
		 */		
		public function get interval():int
		{
			return _interval;
		}

		public function set interval(value:int):void
		{
			_interval = value;
		}

		/**
		 * 上传协议 
		 * @return 
		 * 
		 */		
		public function get protocol():String
		{
			return _protocol;
		}

		public function set protocol(value:String):void
		{
			_protocol = value;
		}

		/**
		 * http上传的地址
		 * @return 
		 * 
		 */		
		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}

		/**
		 * http上传字段，默认值Filedata 
		 * @return 
		 * 
		 */		
		public function get field():String
		{
			return _field;
		}

		public function set field(value:String):void
		{
			_field = value;
		}


	}
}