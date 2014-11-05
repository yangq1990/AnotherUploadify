package com.xinguoedu.model.ftp.status
{	
	/**
	 * 状态码对照表
	 */
	public class ResponseStatus
	{
		
		/**
		 * 连接
		 */
		public static const CONNECTION:Object = {
			SUCCESS:220
		};
		
		/**
		 * 登录流程
		 */
		public static const LOGIN:Object = {
			NEED_PASS:331,
			SUCCESS:230
		};
		
		/**
		 * 当前目录
		 */
		public static const PWD:Object = {
			SUCCESS:257
		};
		
		/**
		 * 列表流程
		 */
		public static const LIST:Object = {
			START:[125,150],
			END:226
		};
		
		/**
		 * 设置目录
		 */
		public static const CWD:Object = {
			SUCCESS:250,
			ERROR:550
		};
		
		/**
		 * 创建目录
		 */
		public static const MKD:Object = {
			SUCCESS:257
		};
		
		/**
		 * 被动模式
		 */
		public static const PASV:Object = {
			SUCCESS:227
		};
		
		/**
		 * 下载
		 */
		public static const RETR:Object = {
			START:[125,150],
			END:226
		};
		
		/**
		 * 上传
		 */
		public static const STOR:Object = {
			START:[125,150],
			END:226
		}
		
		/**
		 * 删除
		 */
		public static const DELE:Object = {
			SUCCESS:250,
			ERROR:550
		}
	}
}