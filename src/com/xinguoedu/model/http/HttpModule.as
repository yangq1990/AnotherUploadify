package com.xinguoedu.model.http
{
	import com.xinguoedu.event.module.ModuleEvt;
	import com.xinguoedu.model.base.BaseModule;
	
	import flash.errors.IllegalOperationError;
	import flash.errors.MemoryError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	/**
	 * http上传模块 
	 * @author yatsen_yang
	 * 
	 */	
	public class HttpModule extends BaseModule
	{
		public function HttpModule()
		{
			super();
		}
		
		override public function startLoad(fileRef:FileReference):void
		{
			super.startLoad(fileRef);
			
			addFileRefListeners();
			
			try
			{
				_fileRef.upload(new URLRequest(_config.url), _config.field);
			}
			catch(err:IllegalOperationError)
			{
				super.dispatchModuleEvt(ModuleEvt.ILLEGAL_OPERATION);
			}
			catch(err2:MemoryError)
			{
				super.dispatchModuleEvt(ModuleEvt.MEMORY_ERROR);
			}			
			catch(err3:ArgumentError)
			{
				super.dispatchModuleEvt(ModuleEvt.ARGUMENT_ERROR);
			}
		}
		
		override public function deleteItem(fileRef:FileReference):void
		{
			super.deleteItem(fileRef);
			
			_fileRef.cancel();
			super.removeFileRefListeners();	
			super.dispatchModuleEvt(ModuleEvt.DELETE_UPLOADING_ITEM_OK, _fileRef);
		}
		
		override protected function onProgress(evt:ProgressEvent):void
		{
			super.dispatchModuleEvt(ModuleEvt.UPLOAD_TO_SERVER_PROGRESS, {fileRef:_fileRef, progress:int(evt.bytesLoaded * 100 / evt.bytesTotal)});
		}
		
		override protected function onComplete(evt:Event):void
		{
			super.dispatchModuleEvt(ModuleEvt.UPLOAD_TO_SERVER_COMPLETE, _fileRef);
		}		
	}
}