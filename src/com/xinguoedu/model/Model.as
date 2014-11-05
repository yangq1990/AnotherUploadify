package com.xinguoedu.model
{
	import com.xinguoedu.event.EventBus;
	import com.xinguoedu.event.module.ModuleEvt;
	import com.xinguoedu.model.base.BaseModule;
	import com.xinguoedu.model.ftp.FtpModule;
	import com.xinguoedu.model.http.HttpModule;
	import com.xinguoedu.utils.Config;
	
	import flash.net.FileReference;
	import flash.utils.Dictionary;

	public class Model
	{
		public var config:Config = new Config();
		private var _moduleDict:Dictionary = new Dictionary();
		private var _activeModule:BaseModule;
		/** 是否开发者模式 **/
		private var _isDeveloperMode:Boolean;
		
		public function Model()
		{
			_moduleDict['ftp'] = new FtpModule();
			_moduleDict['http'] = new HttpModule();
		}
		
		/**
		 * 根据上传协议激活相应的上传模块 
		 * 
		 */		
		public function setActiveModule():void
		{
			if(_activeModule == null)
			{
				_activeModule = _moduleDict[config.protocol];			
				addListeners();	
			}
		}
		
		private function addListeners():void
		{
			_activeModule.addEventListener(ModuleEvt.SELECT, eventHandler);
			_activeModule.addEventListener(ModuleEvt.ILLEGAL_OPERATION, eventHandler);
			_activeModule.addEventListener(ModuleEvt.MEMORY_ERROR, eventHandler);
			_activeModule.addEventListener(ModuleEvt.LOAD_TO_MEMORY_PROGRESS, eventHandler);
			_activeModule.addEventListener(ModuleEvt.UPLOAD_TO_SERVER_PROGRESS, eventHandler);
			_activeModule.addEventListener(ModuleEvt.UPLOAD_TO_SERVER_COMPLETE, eventHandler);
			_activeModule.addEventListener(ModuleEvt.DELETING_UPLOADING_ITEM, eventHandler);
			_activeModule.addEventListener(ModuleEvt.DELETE_UPLOADING_ITEM_OK, eventHandler);
			_activeModule.addEventListener(ModuleEvt.IOERROR, eventHandler);
			_activeModule.addEventListener(ModuleEvt.SECURITY_ERROR, eventHandler);		
			_activeModule.addEventListener(ModuleEvt.ARGUMENT_ERROR, eventHandler);			
		}
		
		private function eventHandler(evt:ModuleEvt):void
		{
			EventBus.getInstance().dispatchEvent(evt);
		}
		
		/**
		 * 添加文件 
		 * 
		 */				
		public function addItem():void
		{
			_activeModule.addItem(config);
		}
		
		/**
		 * 开始上传 
		 * @param fileRef
		 * 
		 */		
		public function startUpload(fileRef:FileReference):void
		{
			_activeModule.startLoad(fileRef);
		}		
		
		public function deleteItem(fileRef:FileReference):void
		{
			_activeModule.deleteItem(fileRef);
		}

		public function get isDeveloperMode():Boolean
		{
			return _isDeveloperMode;
		}

		public function set isDeveloperMode(value:Boolean):void
		{
			_isDeveloperMode = value;
		}

	}
}