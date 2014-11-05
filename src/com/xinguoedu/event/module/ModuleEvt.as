package com.xinguoedu.event.module
{
	import flash.events.Event;
	
	/**
	 * 上传模块需要的事件 
	 * @author yatsen_yang
	 * 
	 */	
	public class ModuleEvt extends Event
	{
		/**
		 * 打开对话框选择文件 
		 */		
		public static const SELECT:String = "select";
		
		/**
		 * 非法操作，比如同时打开多个文件浏览会话 
		 */		
		public static const ILLEGAL_OPERATION:String = "illegal_operation";
		
		/**
		 * Flash Player 无法为该文件分配内存，则可能会发生此错误。文件可能太大，或者可用的内存可能太小
		 */		
		public static const MEMORY_ERROR:String = "memory_error";
		
		/**
		 * 文件加载到内存中的进度 
		 */		
		public static const LOAD_TO_MEMORY_PROGRESS:String = "load_to_memory_progress";
		
		/**
		 * 文件上传到服务器的进度 
		 */		
		public static const UPLOAD_TO_SERVER_PROGRESS:String = "upload_to_server_progress";
		
		/**
		 * 文件上传到服务器上complete 
		 */		
		public static const UPLOAD_TO_SERVER_COMPLETE:String = "upload_to_server_complete";
		
		/**
		 * 正在删除上传中的文件 
		 */		
		public static const DELETING_UPLOADING_ITEM:String = "deleting_uploading_item";
		
		/**
		 * 删除正在上传的文件ok
		 */		
		public static const DELETE_UPLOADING_ITEM_OK:String = "delete_uploading_item";
		
		/**
		 * 控制命令通道关闭 
		 */		
		public static const MAIN_SOCKET_CLOSE:String = "main_socket_close";
		
		/**
		 * 上传文件出现IO错误 
		 */		
		public static const IOERROR:String = "ioerror";
		
		/**
		 * 上传文件出现安全沙箱错误 
		 */		
		public static const SECURITY_ERROR:String = "security_error";
		
		/**
		 * 参数错误 
		 */		
		public static const ARGUMENT_ERROR:String = "argument_error";
		
		public var data:*;
		
		public function ModuleEvt(type:String, d:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
		}
		
		override public function clone():Event
		{
			return new ModuleEvt(type, data);
		}
	}
}