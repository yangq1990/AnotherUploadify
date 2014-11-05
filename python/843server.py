#!/user/bin/env python
# -*- coding: utf-8 -*-

'''

as3使用socket进行数据传输的时候，先要请求843端口，加载策略文件

'''

__author__ = 'yangq'

import sys
import socket
import threading

if len(sys.argv) == 1:
    print 'please input server ip'
    sys.exit()

host = sys.argv[1]

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((host, 843))
s.listen(0)
print 'waiting for connection '


def tcplink(sock, addr):
    print 'Accept new connection from %s:%s' % addr
    sock.send('<cross-domain-policy><site-control permitted-cross-domain-policies="all"/><allow-access-from domain="*" to-ports="*"/></cross-domain-policy>')
    sock.close()


while True:
    sock, addr = s.accept()
    t = threading.Thread(target=tcplink, args=(sock, addr))
    t.start()

