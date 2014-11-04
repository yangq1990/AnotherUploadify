AnotherUploadify
================

类似JQuery的优秀插件Uploadify，目的是实现文件的批量上传。

下面是AnotherUploadify的特点介绍
1，同时支持ftp, http这两种数据传输协议。设置protocol="ftp"，使用ftp上传；设置protocol="http"，使用http上传
2，ftp上传，ftpserver主机地址，端口，数据包大小和数据包发送的频率可配置，支持大文件(超过100M)的批量上传，支持断点续传
3，支持开发者模式，打开此功能，会在浏览器控制台看到一系列的调试信息，方便调试
4，结构良好，容易扩展，如果想实现自定义socket传输，可通过继承BaseModule，重写相应的方法实现目的
5，文件上传的状态通过js展现，flash与js的接口已经定好，如果想实现自定义的风格和效果，可以在接口里修改相应的实现方法，而不用修改as3代码
