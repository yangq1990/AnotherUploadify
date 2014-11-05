package com.xinguoedu.model.ftp.process
{
	import com.xinguoedu.event.process.ProcessEvt;
	import com.xinguoedu.model.ftp.utils.Command;
	import com.xinguoedu.utils.Config;
	import com.xinguoedu.model.ftp.utils.Response;
	import com.xinguoedu.model.ftp.socket.MainSocket;
	import com.xinguoedu.model.ftp.status.CommandsStatus;
	import com.xinguoedu.model.ftp.status.ResponseStatus;
	
	/**
	 * 登录过程 
	 * @author yatsen_yang
	 * 
	 */	
	public class LoginProcess extends BaseProcess
	{
		public function LoginProcess(mainSocket:MainSocket, config:Config)
		{
			super(mainSocket);
			
			_list.push(new Command(CommandsStatus.USER, config.user));
			_list.push(new Command(CommandsStatus.PASS, config.pass));
		}
		
		override public function response(rsp:Response):void
		{
			if(rsp.code == ResponseStatus.LOGIN.NEED_PASS) 
			{
				executeCommand();
			}
			else if(rsp.code == ResponseStatus.LOGIN.SUCCESS) 
			{
				dispatchEvent(new ProcessEvt(ProcessEvt.LOGIN_SUCCESS));
			}
		}
	}
}