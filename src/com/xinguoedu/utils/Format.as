package com.xinguoedu.utils
{
	/**
	 * 格式化工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class Format
	{
		public function Format()
		{
		}
		
		/**
		 * 字节B转换为等量的MB 
		 * @param size
		 * @param precision 精度，默认为1，即小数点后保留1个数字
		 * @return 
		 * 
		 */		
		public static function byte2MB(size:Number, precision:int=1):String
		{			
			if(size < 1024)
			{
				return int(size) + "B";
			}				
			
			var str:String = (size / 1024 / 1024).toString();
			if(str.indexOf(".") != -1)
			{
				var arr:Array = str.split(".");
				if(int(arr[0]) == 0)
				{
					return arr[0] + "." + arr[1].slice(0, 2) + "MB";					
				}
				else
				{
					if(arr[1].length <= precision)
						return str + "MB";
					else
						return arr[0] + "." + arr[1].slice(0, precision) + "MB";
				}								
			}
			else
			{
				return size + "MB";	
			}						
		}
	}
}