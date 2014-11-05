package com.xinguoedu.event.process
{
	import flash.events.Event;
	
	/**
	 * 过程事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class ProcessEvt extends Event
	{
		/**
		 * 登录成功 
		 */		
		public static const LOGIN_SUCCESS:String = "login_success_pe";
		
		/**
		 * 拉取当前目录的文件列表信息成功 
		 */		
		public static const READ_FILELIST_SUCCESS:String = "read_filelist_success_pe";
		
		/**
		 * 上传成功 
		 */		
		public static const UPLOAD_COMPLETE:String = "upload_complete_pe";
		
		/**
		 * 上传进度 
		 */		
		public static const UPLOAD_PROGRESS:String = "upload_progress_pe";
		
		/**
		 * 上传中强制删除 
		 */		
		public static const UPLOADING_FORCE_DELETE:String = "uploading_force_delete_pe";
		
		private var _data:*;
		
		public function ProcessEvt(type:String, data:*=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_data = data;
		}
		
		/**
		 *  
		 * @return 当前上传进度  或者  文件列表信息字典
		 * 
		 */		
		public function get data():*
		{
			return _data;	
		}
		
		override public function clone():Event
		{
			return new ProcessEvt(type, _data, bubbles, cancelable);
		}
	}
}