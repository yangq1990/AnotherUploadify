package com.xinguoedu.external
{
	import com.xinguoedu.event.external.ExternalEvt;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	/**
	 * 公开给外部的API， 和调用外部容器公开的API
	 * @author yatsen_yang
	 * 
	 */	
	public class ExternalAPI extends EventDispatcher
	{
		private static var instance:ExternalAPI;
		
		public function ExternalAPI()
		{
			addCallback();
		}
		
		/** 将 ActionScript 方法注册为可从容器调用 **/
		public function addCallback():void
		{
			if(available)
			{
				ExternalInterface.addCallback("fl_delete", deleteItem);
			}
		}
		
		public function  select(data:String):void
		{
			ExternalInterface.call("js_select", data);
		}
		
		public function load2MemoryProgress(data:String):void
		{
			ExternalInterface.call("js_load2MemoryProgress", data);
		}

		public function uploadProgress(data:String):void
		{
			ExternalInterface.call("js_upload2ServerProgress", data);
		}
		
		public function uploadComplete(data:String):void
		{
			ExternalInterface.call("js_upload2ServerComplete", data);
		}
		
		public function uploadIOError(data:String):void
		{
			ExternalInterface.call("js_uploadIOError", data);
		}
		
		public function uploadSecurityError(data:String):void
		{
			ExternalInterface.call("js_uploadSecurityError", data);
		}
		
		public function uploadMemoryError():void
		{
			ExternalInterface.call("js_uploadMemoryError");
		}
		
		public function illegalOperation():void
		{
			ExternalInterface.call("js_illegalOperation");
		}
		
		public function mainSocketClose():void
		{
			ExternalInterface.call("js_mainSocketClose");
		}
		
		public function deleteItemOK(data:String):void
		{
			ExternalInterface.call("js_deleteItemOK", data);
		}
		
		
		
		private function deleteItem(index:String):void
		{			
			dispatchEvent(new ExternalEvt(ExternalEvt.DELETE_ITEM, int(index)));
		}
		
		public function get available():Boolean
		{
			return ExternalInterface.available;
		}
	}
}