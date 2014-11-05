package com.xinguoedu.model.base
{
	import com.xinguoedu.event.module.ModuleEvt;
	import com.xinguoedu.utils.Config;
	import com.xinguoedu.utils.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;

	public class BaseModule extends EventDispatcher
	{
		protected var _fileRefList:FileReferenceList;
		protected var _fileRef:FileReference;
		protected var _config:Config;
		
		public function BaseModule()
		{
			
		}
		
		/**
		 * 添加文件 
		 * @param config
		 * 
		 */		
		public function addItem(config:Config):void
		{
			_config = config;
			
			if(_fileRefList == null)
			{
				_fileRefList = new FileReferenceList();
			} 
			_fileRefList.addEventListener(Event.SELECT, onSelect);
			_fileRefList.addEventListener(Event.CANCEL, onCancel);					
			_fileRefList.browse([new FileFilter(config.description, config.extension)]);
		}
		
		protected function onSelect(evt:Event):void
		{
			dispatchModuleEvt(ModuleEvt.SELECT, evt.target.fileList);
		}
		
		protected function onCancel(evt:Event):void
		{
			
		}
		
		/**
		 * 开始上传 
		 * @param fileRef
		 * 
		 */		
		public function startLoad(fileRef:FileReference):void
		{
			_fileRef = fileRef;
		}
		
		/**
		 * 删除 
		 * @param fileRef
		 * 
		 */		
		public function deleteItem(fileRef:FileReference):void
		{
			_fileRef = fileRef;
		}
		
		protected function dispatchModuleEvt(type:String, data:*=null):void
		{
			dispatchEvent(new ModuleEvt(type, data));
		}
		
		protected function addFileRefListeners():void
		{
			_fileRef.addEventListener(Event.COMPLETE, onComplete);
			_fileRef.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);	
		}
		
		protected function removeFileRefListeners():void
		{
			if(_fileRef != null)
			{
				_fileRef.removeEventListener(Event.COMPLETE, onComplete);
				_fileRef.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_fileRef.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}			
		}
		
		
		/**
		 * 对于ftp上传，指的是文件加载到内存的进度
		 * 对于http上传，指的是文件上传到服务器的进度 
		 * @param evt
		 * 
		 */		
		protected function onProgress(evt:ProgressEvent):void
		{
			 
		}
		
		/**
		 * 对于ftp上传，指的是文件加载到内存complete
		 * 对于http上传，指的是文件上传到server complete
		 * @param evt
		 * 
		 */		
		protected function onComplete(evt:Event):void
		{
			
		}
		
		protected function onIOError(evt:IOErrorEvent):void
		{
			Logger.error('BaseModule', evt.toString()+":"+_fileRef.name);
			dispatchModuleEvt(ModuleEvt.IOERROR, _fileRef);
		}
		
		protected function onSecurityError(evt:SecurityErrorEvent):void
		{
			Logger.error('BaseModule', evt.toString()+":"+_fileRef.name);
			dispatchModuleEvt(ModuleEvt.SECURITY_ERROR, _fileRef);
		}
	}
}