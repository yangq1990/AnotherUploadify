package com.xinguoedu.event.module
{
	import flash.events.Event;
	
	/**
	 * 与主链接相关的事件类
	 * 
	 */	
	public class MainSocketEvt extends Event
	{
		public static const CLOSE:String = "close_mse";
		
		public static const SECURITY_ERROR:String = "securityerror_mse";
		
		public function MainSocketEvt(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}