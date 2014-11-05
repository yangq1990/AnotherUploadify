package com.xinguoedu.model.ftp.process
{
	import com.xinguoedu.event.process.ProcessEvt;
	import com.xinguoedu.utils.Config;
	import com.xinguoedu.model.ftp.socket.DataSocket;
	import com.xinguoedu.model.ftp.socket.MainSocket;
	import com.xinguoedu.model.ftp.status.CommandsStatus;
	import com.xinguoedu.model.ftp.status.ResponseStatus;
	import com.xinguoedu.model.ftp.utils.Command;
	import com.xinguoedu.model.ftp.utils.Response;
	import com.xinguoedu.utils.Logger;
	
	import flash.utils.Dictionary;
	
	/**
	 * 显示ftp server上文件列表的过程 
	 * @author yatsen_yang
	 * 
	 */	
	public class ListProcess extends BaseProcess
	{
		private var data:DataSocket;
		
		public function ListProcess(mainSocket:MainSocket)
		{
			super(mainSocket);
			
			_list.push(new Command(CommandsStatus.PWD));
			//_list.push(new Command(CommandsStatus.CWD));			
			_list.push(new Command(CommandsStatus.PASV));
			_list.push(new Command(CommandsStatus.LIST, "-al"));
			_list.push(new Command(CommandsStatus.MKD, 'yangqyangq'));
		}
		
		override public function response(rsp:Response):void
		{
			//trace('listprocess--->', rsp.code);
			if(rsp.code == ResponseStatus.PWD.SUCCESS && _list.length > 0) 
			{
				executeCommand();
			}
			else if(rsp.code == ResponseStatus.CWD.SUCCESS)
			{
				executeCommand();
			}				
			else if(rsp.code == ResponseStatus.PASV.SUCCESS) 
			{
				data = new DataSocket();
				data.connect(rsp.data as Config);
				data.responseFunc = dataResponseFunc;
				data.noSocketDataBackFunc = noSocketDataBackHandler;
				executeCommand();
			}
			/*else if(rsp.code == ResponseStatus.LIST.END) 
			{
				
			}*/
		}
		
		public function dataResponseFunc(str:String):void
		{
			var arr:Array = str.split("\n"); //windows为\r\n  
			var pattern:RegExp = /^.*?\s+\d+\s+\d+\s+\d+\s+(\d+)\s+\w+\s+\d+\s+\d+\:\d+\s+\.*(.*)$/;
			var execArr:Array; //匹配后生成的数组
			var fileInfoDict:Dictionary = new Dictionary();
			for each(var item:* in arr)
			{
				execArr = pattern.exec(item);
				//omit . .. bashrc bash_profile bash_logout
				if(execArr == null || execArr[2]=="" || execArr[2]=="bashrc" || execArr[2]=="bash_profile" || execArr[2]=="bash_logout")
					continue;				
				
				fileInfoDict[execArr[2]] = int(execArr[1]);
				Logger.info("ListProcess", "name:" + execArr[2] + "---size:" + execArr[1]); 
			}
			
			dispatchEvent(new ProcessEvt(ProcessEvt.READ_FILELIST_SUCCESS, fileInfoDict));
			
			data.close();
		}
		
		/**
		 * 没有socket data 数据返回时调用 
		 * 
		 */		
		public function noSocketDataBackHandler():void
		{
			dispatchEvent(new ProcessEvt(ProcessEvt.READ_FILELIST_SUCCESS, new Dictionary()));
			
			data.close();
		}
	}
}