package com.xinguoedu.model.ftp
{
	
	/**
	 * 命令类 用于格式化FTP命令,包含命令头和各项参数
	 * @author yatsen_yang
	 */
	public class Command
	{
		private var _command:String;
		private var _args:String;
		
		/**
		 *  
		 * @param comm ftp命令
		 * @param args 命令所带的参数
		 * 
		 */		
		public function Command(comm:String, args:String = "")
		{
			this._command = comm;
			this._args = args;
		}
		
		/**
		 * 格式化为可执行命令
		 */
		public function toExecuteString():String
		{
			return _command + " " + _args + "\r\n";
		}
		
		/**
		 * 设置命令类型
		 */
		public function set command(comm:String):void
		{
			this._command = comm;
		}
		/**
		 * 获取命令类型
		 */
		public function get command():String
		{
			return this._command;
		}
		
		/**
		 * 设置参数
		 */
		public function set args(arg:String):void
		{
			this._args = arg;
		}
		/**
		 * 获取参数
		 */
		public function get args():String
		{
			return this._args;
		}

	}
}