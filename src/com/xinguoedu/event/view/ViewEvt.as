package com.xinguoedu.event.view
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	/**
	 * 视图事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class ViewEvt extends Event
	{
		/**
		 * 添加文件 
		 */		
		public static const ADD_ITEMS:String = "add_items";
		
		/**
		 * 开始上传 
		 */		
		public static const START_UPLOAD:String = "start_upload";
		
		/**
		 * 删除文件项 
		 */		
		public static const DELETE_ITEM:String = "delete_item";			
		
		
		public var fireRef:FileReference;		
		
		public function ViewEvt(type:String, fireRef:FileReference=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.fireRef = fireRef;
		}
		
		override public function clone():Event
		{
			return new ViewEvt(type, fireRef);
		}		
	}
}