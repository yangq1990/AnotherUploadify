package
{
	import com.xinguoedu.c.Controller;
	import com.xinguoedu.event.EventBus;
	import com.xinguoedu.event.external.ExternalEvt;
	import com.xinguoedu.event.module.ModuleEvt;
	import com.xinguoedu.event.view.ViewEvt;
	import com.xinguoedu.external.ExternalAPI;
	import com.xinguoedu.model.Model;
	import com.xinguoedu.utils.Format;
	import com.xinguoedu.utils.Logger;
	import com.xinguoedu.utils.MultifunctionalLoader;
	import com.xinguoedu.utils.StageReference;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	
	/**
	 * 类似于JQuery插件uploadify
	 * KuaijiUploadify通过flash上传，js更新显示状态，包括ftp, http 
	 * @author yatsen_yang
	 * 
	 */	
	public class AnotherUploadify extends BaseInitView
	{
		private var _c:Controller;
		private var _m:Model;
		private var _btn:Sprite;
		/**
		 * 存储选中文件信息的数组，  _selectedFiles的存储的数据结构如下所示
		 * [
		 *    {
		 * 	      index:    索引
		 * 		  fileRef:  FileReference的引用
		 *        isUploading: 是否在上传中
		 * 		  isCanceled:  是否已取消
		 *    },
		 *    {
		 * 
		 *    } 
		 * ] 
		 */		
		private var _selectedFiles:Array;		
		/** 当前正在上传的文件的索引 **/
		private var _currrentIndex:int = -1;
		/** 上传成功的个数  **/
		private var _successCount:int;
		
		private var _externalAPI:ExternalAPI;
		
		public function AnotherUploadify()
		{
			super();
		}
		
		override protected function init():void
		{
			super.init();
			
			new StageReference(this);			
			_externalAPI = new ExternalAPI();
			
			var btnLoader:MultifunctionalLoader = new MultifunctionalLoader();
			btnLoader.registerFunctions(loadBtnImgeComplete);
			btnLoader.load(this.stage.loaderInfo.parameters["selectBtnImgUrl"]);			
			
			_m = new Model();
			_c = new Controller(_m, this);
			
			addListeners();
		}
		
		private function loadBtnImgeComplete(dp:DisplayObject):void
		{
			_btn = new Sprite();
			_btn.addChild(dp);
			_btn.mouseEnabled = _btn.buttonMode = true;
			_btn.addEventListener(MouseEvent.CLICK, clickBtnHandler);
			addChild(_btn);			
		}
		
		private function addListeners():void
		{
			//from model
			EventBus.getInstance().addEventListener(ModuleEvt.SELECT, selectHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.LOAD_TO_MEMORY_PROGRESS, load2MemoryProgressHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.UPLOAD_TO_SERVER_PROGRESS, upload2ServerProgressHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.UPLOAD_TO_SERVER_COMPLETE, upload2ServerCompleteHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.IOERROR, ioerrorHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.SECURITY_ERROR, securityErrorHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.MEMORY_ERROR, memoryErrorHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.ILLEGAL_OPERATION, illegalOperationHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.MAIN_SOCKET_CLOSE, mainSocketCloseHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.DELETE_UPLOADING_ITEM_OK, deleteItemOKHandler);
			
			//from external
			_externalAPI.addEventListener(ExternalEvt.DELETE_ITEM, externalDeleteItemHandler);			
		}
		
		/**
		 * 选中文件开始上传   
		 * @param evt   evt.data  FileReference数组
		 * 
		 */		
		private function selectHandler(evt:ModuleEvt):void
		{
			_selectedFiles = [];
			_currrentIndex = -1;
			
			var arr:Array = [];
			var selectFileList:Array = evt.data;
			var length:int = selectFileList.length;
			var obj:Object;			
			var fileItem:Object;	
			
			for(var i:int = 0; i < length; i++)
			{
				obj = {};
				obj.index = i + 1;
				obj.name = selectFileList[i].name;
				obj.size = Format.byte2MB(selectFileList[i].size);
				arr.push(obj);
				
				fileItem = {};
				fileItem.index = i;
				fileItem.fileRef = selectFileList[i] as FileReference;
				fileItem.isUploading = false; //上传状态标识
				fileItem.isCanceled = false; //是否已取消
				_selectedFiles.push(fileItem);
			}
			_externalAPI.select(JSON.stringify(arr));		
			_currrentIndex = 0;
			_selectedFiles[0].isUploading = true;
			dispatchEvent(new ViewEvt(ViewEvt.START_UPLOAD, _selectedFiles[0].fileRef as FileReference));
			
			_btn.mouseEnabled = false;
			_btn.alpha = 0.5;
		}
		
		/**
		 * 加载到内存的进度 
		 * @param evt  evt.data {fileRef: , progress: } 
		 * 
		 */		
		private function load2MemoryProgressHandler(evt:ModuleEvt):void
		{
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'to memory progress:' + evt.data.fileRef.name + "-->" + evt.data.progress));			
			_externalAPI.load2MemoryProgress(JSON.stringify({index:_currrentIndex + 1, progress: evt.data.progress}));
		}
		
		/**
		 * 上传进度
		 * @param evt  evt.data {fileRef: , progress: } 
		 * 
		 */		
		private function upload2ServerProgressHandler(evt:ModuleEvt):void
		{		
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'upload progress:' + evt.data.fileRef.name + '-->' + evt.data.progress));			
			_externalAPI.uploadProgress(JSON.stringify({index:_currrentIndex + 1, progress: evt.data.progress}));			
		}
		
		/**
		 * 上传complete
		 * @param evt  evt.data  fileRef 
		 * 
		 */		
		private function upload2ServerCompleteHandler(evt:ModuleEvt):void
		{
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'complete:' + evt.data.name + '--->' +  _currrentIndex));			
			_externalAPI.uploadComplete(JSON.stringify({index:_currrentIndex+1}));			
			
			_successCount += 1;			
			if(_successCount >= _selectedFiles.length || _selectedFiles.length == 1)
			{
				allComplete();				
			}
			else
			{
				uploadNext(_currrentIndex);
			}
		}
		
		/** 上传下一个 **/
		private function uploadNext(currentIndex:int):void
		{
			var len:int = _selectedFiles.length;
			var isQueueEmpty:Boolean = true; //上传队列是否为空，空表示已没有文件可上传
			for(var i:int = currentIndex+1; i < len; i++)
			{
				if(!_selectedFiles[i].isUploading && !_selectedFiles[i].isCanceled)
				{
					isQueueEmpty = false;
					_currrentIndex = i;
					_selectedFiles[i].isUploading = true;
					dispatchEvent(new ViewEvt(ViewEvt.START_UPLOAD, _selectedFiles[i].fileRef as FileReference));
					break;
				}
			}
			
			if(isQueueEmpty)
			{
				allComplete();				
			}				
		}
		
		/** 全部上传完成 **/
		private function allComplete():void
		{
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'all complete'));
			_btn.mouseEnabled = true;
			_btn.alpha = 1;
			_currrentIndex = -1;
		}
		
		/**
		 * 上传IOError
		 * @param evt   evt.data  fileRef
		 * 
		 */		
		private function ioerrorHandler(evt:ModuleEvt):void
		{
			var i:int = getfileRefIndex(evt.data);
			_selectedFiles[i].isCanceled = true;
			uploadNext(i);
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'ioerror:' + evt.data.name));
			
			_externalAPI.uploadIOError(JSON.stringify({index:i+1}));			
		}
		
		/**
		 * 上传SecurityError
		 * @param evt   evt.data  fileRef
		 * 
		 */		
		private function securityErrorHandler(evt:ModuleEvt):void
		{
			var i:int = getfileRefIndex(evt.data);
			_selectedFiles[i].isCanceled = true;
			uploadNext(i);
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'securityerror:' + evt.data.name));
			
			_externalAPI.uploadSecurityError(JSON.stringify({index:i + 1}));	
		}
		
		/**
		 * 成功删除正在上传的文件, 加载下一个文件
		 * @param evt  evt.data  fileRef
		 * 
		 */		
		private function deleteItemOKHandler(evt:ModuleEvt):void
		{
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'deleteItemOK:' + evt.data.name));
			var i:int = getfileRefIndex(evt.data);
			_externalAPI.deleteItemOK(JSON.stringify({index:i + 1}));
			uploadNext(i);
		}
		
		/**
		 * 内存错误 
		 * @param evt
		 * 
		 */		
		private function memoryErrorHandler(evt:ModuleEvt):void
		{
			_externalAPI.uploadMemoryError();
		}
		
		/**
		 * 非法操作
		 * @param evt
		 * 
		 */		
		private function illegalOperationHandler(evt:ModuleEvt):void
		{
			_externalAPI.illegalOperation();
		}
		
		/**
		 * ftp上传时与ftpserver的连接中断 
		 * @param evt
		 * 
		 */		
		private function mainSocketCloseHandler(evt:ModuleEvt):void
		{
			_externalAPI.mainSocketClose();
		}
		
		private function getfileRefIndex(fileRef:FileReference):int
		{
			var result:int;
			for each(var fileItem:Object in _selectedFiles)
			{
				if(fileRef == fileItem.fileRef)
				{
					result = fileItem.index;
					break;
				}
			} 
			return result;
		}
		
		private function clickBtnHandler(evt:MouseEvent):void
		{
			dispatchEvent(new ViewEvt(ViewEvt.ADD_ITEMS));
		}
		
		private function externalDeleteItemHandler(evt:ExternalEvt):void
		{
			var index:int = evt.index - 1;
			_m.isDeveloperMode && (Logger.info('KuaijiUploadify', 'js want to delete: ' + index)); 
			_selectedFiles[index].isCanceled = true;
			if(_selectedFiles[index].isUploading)
			{
				dispatchEvent(new ViewEvt(ViewEvt.DELETE_ITEM, _selectedFiles[index].fileRef as FileReference));			
			}	
			else
			{
				_externalAPI.deleteItemOK(JSON.stringify({index:evt.index}));
			}
		}
	}
}