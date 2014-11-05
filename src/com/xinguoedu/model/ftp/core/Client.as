package com.xinguoedu.model.ftp.core
{
	import com.xinguoedu.event.EventBus;
	import com.xinguoedu.event.module.MainSocketEvt;
	import com.xinguoedu.event.module.ModuleEvt;
	import com.xinguoedu.event.process.ProcessEvt;
	import com.xinguoedu.model.ftp.process.ListProcess;
	import com.xinguoedu.model.ftp.process.LoginProcess;
	import com.xinguoedu.model.ftp.process.UploadProcess;
	import com.xinguoedu.model.ftp.socket.MainSocket;
	import com.xinguoedu.model.ftp.utils.Response;
	import com.xinguoedu.utils.Config;
	
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	
	/**
	 * 包含所有的操作流程
	 * @author yatsen_yang
	 */
	public class Client extends EventDispatcher
	{	
		//主连接
		private var mainSocket:MainSocket = null;
		//回调函数
		private var _responseCall:Function;
		//当前文件的引用
		public var fileRef:FileReference;
		//ftp配置
		private var _config:Config;
		//文件列表信息字典
		private var _fileInfoDict:Dictionary;		
		//上传过程
		private var _uploadProcess:UploadProcess;
		
		/**
		 * 构造函数
		 */
		public function Client()
		{
			mainSocket = MainSocket.getInstance();
			mainSocket.addEventListener(MainSocketEvt.CLOSE, mainSocketCloseHandler);
		}
		
		/**
		 * connect to ftp server
		 */
		public function connect(config:Config):void
		{
			_config = config;
			mainSocket.responseFunc = connected2Server;
			mainSocket.connect(config.host, int(config.port));
		}	
		
		private function mainSocketCloseHandler(evt:MainSocketEvt):void
		{
			dispatchEvent(new ModuleEvt(ModuleEvt.UPLOAD_TO_SERVER_COMPLETE, fileRef));
			EventBus.getInstance().dispatchEvent(new ModuleEvt(ModuleEvt.MAIN_SOCKET_CLOSE));
		}
		
		/**
		 * 连接成功的回调
		 */
		public function connected2Server(response:Response):void
		{
			if(response.code == 220) 
			{
				login();
			}
		}
		
		/**
		 * 登录流程
		 */
		public function login():void
		{
			var loginProcess:LoginProcess = new LoginProcess(mainSocket, _config);
			loginProcess.addEventListener(ProcessEvt.LOGIN_SUCCESS, loginSuccessHandler);
			loginProcess.executeCommand();
		}
		
		/** 登录成功，读取文件列表 **/
		private function loginSuccessHandler(evt:ProcessEvt):void
		{
			list();
		}
		
		/** 显示ftp server上当前目录下的文件 **/
		private function list():void
		{
			var listProcess:ListProcess = new ListProcess(mainSocket);
			listProcess.addEventListener(ProcessEvt.READ_FILELIST_SUCCESS, readFileListSuccessHandler);
			listProcess.executeCommand();
		}
		
		private function readFileListSuccessHandler(evt:ProcessEvt):void
		{
			_fileInfoDict = evt.data;
			upload();
		}
		
		/**
		 * 上传流程
		 */
		public function upload():void
		{
			if(_fileInfoDict == null)
			{
				list();
				return;
			}
			
			if(_fileInfoDict[fileRef.name] == fileRef.size)  //上传100%，直接显示上传完成跳过
			{
				dispatchEvent(new ModuleEvt(ModuleEvt.UPLOAD_TO_SERVER_PROGRESS, {'fileRef':fileRef, 'progress':100}));
				dispatchEvent(new ModuleEvt(ModuleEvt.UPLOAD_TO_SERVER_COMPLETE, fileRef));
				return;
			}
			
			//从头开始上传文件
			if(_fileInfoDict[fileRef.name] == undefined || _fileInfoDict[fileRef.name] > fileRef.size)
			{
				_uploadProcess = new UploadProcess(mainSocket, fileRef, _config);
			}
			else if(_fileInfoDict[fileRef.name] < fileRef.size)    //从断点开始续传
			{
				_uploadProcess = new UploadProcess(mainSocket, fileRef, _config, _fileInfoDict[fileRef.name]);
			}
			_uploadProcess.addEventListener(ProcessEvt.UPLOAD_PROGRESS, uploadProgressHandler);
			_uploadProcess.addEventListener(ProcessEvt.UPLOAD_COMPLETE, uploadCompleteHandler);
			_uploadProcess.addEventListener(ProcessEvt.UPLOADING_FORCE_DELETE, uploadingForceDeleteHandler);
			_uploadProcess.executeCommand();
		}	
		
		/**
		 * 取消上传 
		 * 
		 */		
		public function cancel():void
		{
			if(_uploadProcess != null)
			{
				_uploadProcess.cancel();
				dispatchEvent(new ModuleEvt(ModuleEvt.DELETING_UPLOADING_ITEM, fileRef));
			}			
		}
		
		private function uploadProgressHandler(evt:ProcessEvt):void
		{
			dispatchEvent(new ModuleEvt(ModuleEvt.UPLOAD_TO_SERVER_PROGRESS, {"fileRef": fileRef, 'progress':evt.data}));
		}
		
		private function uploadCompleteHandler(evt:ProcessEvt):void
		{			
			dispatchEvent(new ModuleEvt(ModuleEvt.UPLOAD_TO_SERVER_COMPLETE, fileRef));
			destoryUploadProcess();			
		}	
		
		private function uploadingForceDeleteHandler(evt:ProcessEvt):void
		{
			dispatchEvent(new ModuleEvt(ModuleEvt.DELETE_UPLOADING_ITEM_OK, fileRef));
			destoryUploadProcess();
		}
		
		private function destoryUploadProcess():void
		{
			_uploadProcess.removeEventListener(ProcessEvt.UPLOAD_PROGRESS, uploadProgressHandler);
			_uploadProcess.removeEventListener(ProcessEvt.UPLOAD_COMPLETE, uploadCompleteHandler);
			_uploadProcess.removeEventListener(ProcessEvt.UPLOADING_FORCE_DELETE, uploadingForceDeleteHandler);
			_uploadProcess = null;
		}
	}
}