package com.xinguoedu.model.ftp.process
{
	import com.xinguoedu.event.process.ProcessEvt;
	import com.xinguoedu.model.ftp.socket.DataSocket;
	import com.xinguoedu.model.ftp.socket.MainSocket;
	import com.xinguoedu.model.ftp.status.CommandsStatus;
	import com.xinguoedu.model.ftp.status.ResponseStatus;
	import com.xinguoedu.model.ftp.utils.Command;
	import com.xinguoedu.model.ftp.utils.Response;
	import com.xinguoedu.utils.Config;
	import com.xinguoedu.utils.Logger;
	
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * 上传过程 
	 * @author yatsen_yang
	 * 
	 */	
	public class UploadProcess extends BaseProcess
	{
		private var _dataSocket:DataSocket;
		
		private var _byteArray:ByteArray;
		
		private var _fileRef:FileReference;
		
		private var _timer:Timer;
		
		private var _config:Config;
		
		private var _position:uint = 0; //ByteArray指针的当前位置，用于断点续传, 默认从头开始上传
		/** 是否上传完成 **/
		private var _isComplete:Boolean = false;
		
		/**
		 *  
		 * @param mainSocket socket主链接
		 * @param fileRef 文件引用
		 * @param config 配置
		 * @param position 断点续传，上次上传的位置
		 * 
		 */		
		public function UploadProcess(mainSocket:MainSocket, fileRef:FileReference, config:Config, position:uint=0)
		{
			super(mainSocket);
						
			_fileRef = fileRef;			
			_config = config;
			_position = position;
			
			_list.push(new Command(CommandsStatus.PASV));
			(position == 0) ? _list.push(new Command(CommandsStatus.STOR, fileRef.name)) : _list.push(new Command(CommandsStatus.APPE, fileRef.name));
			_list.push(new Command(CommandsStatus.DELE, fileRef.name));
		}
		
		override public function response(rsp:Response):void
		{
			if(rsp.code == ResponseStatus.PASV.SUCCESS)
			{
				_dataSocket = new DataSocket();
				_dataSocket.connect(rsp.data as Config);
				executeCommand();
			}
			else if(ResponseStatus.STOR.START.indexOf(rsp.code) >= 0) 
			{
				upload();
			}
			else if(rsp.code == ResponseStatus.STOR.END) 
			{
				Logger.info("UploadProcess", "stor end:" + _isComplete);
				//上传成功或者上传过程中断开链接，返回的rsp.code都是226， 表明结束数据连
				_isComplete && dispatchEvent(new ProcessEvt(ProcessEvt.UPLOAD_COMPLETE));		
			}
			else if(rsp.code == ResponseStatus.DELE.SUCCESS)
			{
				destroy();
				dispatchEvent(new ProcessEvt(ProcessEvt.UPLOADING_FORCE_DELETE));		
			}
		}
		
		
		private function upload():void
		{
			_byteArray = new ByteArray();
			
			_fileRef.data.position = _position;
			
			// 每隔0.1s发送一次数据
			_timer = new Timer(_config.interval);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			_timer.start();
		}
		
		/** 
		 * public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void
		 *
		 * 从字节流中读取 length 参数指定的数据字节数。
		 * 从 offset 指定的位置开始，将字节读入 bytes 参数指定的 ByteArray 对象中，并将字节写入目标 ByteArray 中
		 * 
		 * 参数   
		 * bytes:ByteArray — 要将数据读入的 ByteArray 对象。  
		 * offset:uint (default = 0) — bytes 中的偏移（位置），应从该位置写入读取的数据。  
	     * 注意offset是在bytes中的偏移位置，而非调用者中的偏移位置
 		 * length:uint (default = 0) — 要读取的字节数。 默认值 0 导致读取所有可用的数据。 * 
		 * 
		 * 
		 * **/
		
		private function timerHandler(evt:TimerEvent):void
		{
			if(_dataSocket.pending == 0) 
			{
				//清除字节数组的内容，并将 length 和 position 属性重置为 0
				_byteArray.clear();
		
				if(_fileRef.data.bytesAvailable > _config.chunkSize)
				{
					_fileRef.data.readBytes(_byteArray, 0,  _config.chunkSize);
					_dataSocket.write(_byteArray);					
					
					dispatchEvent(new ProcessEvt(ProcessEvt.UPLOAD_PROGRESS, int((_fileRef.size - _fileRef.data.bytesAvailable) * 100 / _fileRef.size)));
				}
				else
				{
					_fileRef.data.readBytes(_byteArray);					
					_dataSocket.write(_byteArray);					
				
					destroy();					
					_isComplete = true;
					dispatchEvent(new ProcessEvt(ProcessEvt.UPLOAD_PROGRESS, 100)); //上传100%
				}
			}
		}
	
		
		/**
		 * 取消上传 
		 * 
		 */		
		public function cancel():void
		{
			destroyTimer();
			destroyDataSocket();				
			executeCommand();
		}
		
		/**
		 * 取消上传，释放资源 
		 * 
		 */		
		public function destroy():void
		{
			destroyTimer();
			destroyDataSocket();		
			
			if(_byteArray != null)
			{
				_byteArray.clear();
				_byteArray = null;
			}			
			
			_isComplete = false;
		}
		
		/** 清除计时器 **/
		private function destroyTimer():void
		{
			if(_timer != null)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				_timer = null;		
			}
		}
		
		/** 清除数据连接 **/
		private function destroyDataSocket():void
		{
			if(_dataSocket != null)
			{
				_dataSocket.close();
				_dataSocket = null;
			}
		}	
	}
}