package com.xinguoedu.event.external
{
	import flash.events.Event;
	
	/**
	 * 与容器外部操作相关的事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class ExternalEvt extends Event
	{
		public static const DELETE_ITEM:String = "delete_item_external";
		
		public var index:int;
		
		public function ExternalEvt(type:String, index:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.index = index;
		}
		
		override public function clone():Event
		{
			return new ExternalEvt(type, index);
		}	
	}
}