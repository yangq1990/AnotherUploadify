package com.xinguoedu.c
{
	import com.xinguoedu.event.view.ViewEvt;
	import com.xinguoedu.model.Model;
	import com.xinguoedu.utils.Logger;
	import com.xinguoedu.utils.StageReference;
	import com.xinguoedu.utils.VersionUtil;
	
	import flash.display.Sprite;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * 上传组件控制器 
	 * @author yatsen_yang
	 * 
	 */	
	public class Controller
	{
		private var _m:Model;
		private var _v:Sprite;
		private var _context:ContextMenu;
		
		public function Controller(m:Model, v:Sprite)
		{
			_m = m;
			_v = v;	
			
			//加载配置文件，显示在右键菜单上
			var versionUtil:VersionUtil = new VersionUtil();
			versionUtil.getVersion(getVersionComplete);
			
			getFlashvars();		
			
			addListeners();
		}
				
		private function addListeners():void
		{
			_v.addEventListener(ViewEvt.ADD_ITEMS, addItemsHandler);
			_v.addEventListener(ViewEvt.START_UPLOAD, startUploadHandler);
			_v.addEventListener(ViewEvt.DELETE_ITEM, deleteItemHandler);
		}
		
		/** 获取flashvars里的参数  **/
		private function getFlashvars():void
		{
			var parameters:Object = StageReference.stage.loaderInfo.parameters;			
			_m.config.protocol = (!parameters.protocol) ? "ftp" : parameters.protocol;
			_m.config.url = decodeURIComponent(parameters.url); //防止url的key-value丢失
			_m.config.host = parameters.host;
			_m.config.port = parameters.port;
			_m.config.user = parameters.user;
			_m.config.pass = parameters.pass;
			_m.config.description = parameters.description;
			_m.config.extension = parameters.extension;
			//trace(int(undefined)) 输出0
			_m.config.chunkSize = int(parameters.chunkSize);
			_m.config.interval = int(parameters.interval);
			if(parameters.field)
				_m.config.field = parameters.field;
			if(parameters.developermode == "true")
				_m.isDeveloperMode = true;
			_m.isDeveloperMode && (Logger.info("Controller", 'url-->'+_m.config.url));
		}
		
		/** 读取版本配置文件complete **/
		private function getVersionComplete(verStr:String):void
		{
			_context = new ContextMenu();
			_context.hideBuiltInItems();
			_v.contextMenu = _context;
			var contextMenuItem:ContextMenuItem = new ContextMenuItem(verStr);
			_context.customItems.push(contextMenuItem);				
		}
		
		/** 添加文件项 **/
		private function addItemsHandler(evt:ViewEvt):void
		{ 			
			_m.setActiveModule();
			_m.addItem();
		}
		
		/** 开始上传 **/
		private function startUploadHandler(evt:ViewEvt):void
		{
			_m.startUpload(evt.fireRef);
		}		
		
		/** 文件上传过程中强制删除 **/
		private function deleteItemHandler(evt:ViewEvt):void
		{
			_m.deleteItem(evt.fireRef);
		}
	}
}