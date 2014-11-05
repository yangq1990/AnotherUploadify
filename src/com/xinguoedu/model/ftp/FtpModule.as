package com.xinguoedu.model.ftp
{
	import com.xinguoedu.event.module.ModuleEvt;
	import com.xinguoedu.model.base.BaseModule;
	import com.xinguoedu.model.ftp.core.Client;
	
	import flash.errors.IllegalOperationError;
	import flash.errors.MemoryError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	
	/**
	 * ftp上传模块 
	 * @author yatsen_yang
	 * 
	 */	
	public class FtpModule extends BaseModule
	{
		//ftp client
		private var _client:Client;
		
		public function FtpModule()
		{
			super();
		}
		
		override public function startLoad(fileRef:FileReference):void
		{
			super.startLoad(fileRef);
			
			super.addFileRefListeners();
			
			try
			{
				_fileRef.load(); //需要先调用load()函数且等到Event.COMPLETE事件派发，否则_fileRef.data为null;
			}
			catch(err:IllegalOperationError)
			{
				super.dispatchModuleEvt(ModuleEvt.ILLEGAL_OPERATION);
			}
			catch(err2:MemoryError)
			{
				super.dispatchModuleEvt(ModuleEvt.MEMORY_ERROR);
			}			
		}
		
		override public function deleteItem(fileRef:FileReference):void
		{
			super.deleteItem(fileRef);
			super.removeFileRefListeners();
			_client.cancel();
		}
		
		override protected function onProgress(evt:ProgressEvent):void
		{
			dispatchModuleEvt(ModuleEvt.LOAD_TO_MEMORY_PROGRESS, {fileRef:_fileRef, progress:int(evt.bytesLoaded * 100 / evt.bytesTotal)});
		}
		
		override protected function onComplete(evt:Event):void
		{
			if(_client == null) //未曾与ftp server建立 socket连接
			{
				_client = new Client();
				_client.fileRef = _fileRef;
				_client.addEventListener(ModuleEvt.UPLOAD_TO_SERVER_PROGRESS, eventHandler);
				_client.addEventListener(ModuleEvt.UPLOAD_TO_SERVER_COMPLETE, eventHandler);
				_client.addEventListener(ModuleEvt.DELETING_UPLOADING_ITEM, eventHandler);
				_client.addEventListener(ModuleEvt.DELETE_UPLOADING_ITEM_OK, deleteItemOKHandler);
				_client.connect(_config);
			}
			else
			{
				_client.fileRef = _fileRef;
				_client.upload();
			}
		}
		
		private function eventHandler(evt:ModuleEvt):void
		{
			super.dispatchModuleEvt(evt.type, evt.data);
		}
		
		private function deleteItemOKHandler(evt:ModuleEvt):void
		{
			_fileRef.cancel(); //取消正在对该 FileReference 对象执行的上载操作,释放_fileRef.data所占内存
			eventHandler(evt);
		}
	}
}