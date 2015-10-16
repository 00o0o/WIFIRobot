#! /usr/bin/env python
# coding:utf-8

import cv2
import numpy as np

from socket import *
  
def recvall(sock, count):
    buf = b''
    while count:
        newbuf = sock.recv(count)
        if not newbuf: return None
        buf += newbuf
        count -= len(newbuf)
    return buf

host = '127.0.0.1'  
port = 8081  
bufsize = 1024  
addr = (host,port)  
client = socket(AF_INET,SOCK_STREAM)  
client.connect(addr)  

while True:  
	length = recvall(client, 16)
	string_data = recvall(client, int(length))
	data = np.fromstring(string_data, dtype="uint8")
	decimg = cv2.imdecode(data, 1)
	cv2.imshow("SERVER", decimg)
	if cv2.waitKey(1) & 0xFF == ord("q"):
		break

client.close()  

