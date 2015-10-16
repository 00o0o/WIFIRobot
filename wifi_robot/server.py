#! /usr/bin/env python
# coding:utf-8

import socket
import numpy
import cv2

from camera import Camera

class Server(object):

	def __init__(self, host="127.0.0.1", port=8081):
		self.addr = (host, port)

	def run(self):
		print "server running..."
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.bind(self.addr)
		s.listen(True)

		conn, addr = s.accept()
		print "connect succeed."

		cap = Camera(0, [480, 320], 60)
		ret, frame = cap.cam.read()

		encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 90]

		while ret:
			result, imgencode = cv2.imencode(".jpg", frame, encode_param)

			data = numpy.array(imgencode)
			string_data = data.tostring()
			conn.send(str(len(string_data)).ljust(16))
			conn.send(string_data)

			ret, frame = cap.cam.read()

			if cv2.waitKey(1) & 0xFF == ord("q"):
				break

		s.close()
		cap.release()


if __name__ == '__main__':
	server = Server()
	server.run()