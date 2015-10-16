#! /usr/bin/env python
# coding:utf-8

import tornado.ioloop
import tornado.web
import cv2
import numpy
import time

import sockjs.tornado
import base64

from camera import Camera


class IndexHandler(tornado.web.RequestHandler):

	def get(self):
		self.render("tpl/index.html")


class CameraConnection(sockjs.tornado.SockJSConnection):
	'''
	def on_message(self, msg):
		print self.session
		param = msg.split(",")
		#while 1:
		#cap = Camera(0, [480,320], 100)
		#frame = cap.get_frame()
		#self.send("data:image/jpeg;base64,"+base64.b64encode(frame))
		#print param
		cap = Camera(0, [int(param[0]), int(param[1])], 60)
		ret, frame = cap.cam.read()

		encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 90]
		while ret:
			print self.session.headers
			result, imgencode = cv2.imencode(".jpg", frame, encode_param)
			data = numpy.array(imgencode)
			string_data = data.tostring()
			self.send("data:image/jpeg;base64,"+base64.b64encode(string_data))
			time.sleep(0.08)
			ret, frame = cap.cam.read()

		self.close()
		del cap
	'''
	def on_message(self, msg):
		param = msg.split(",")
		if param[0] == "init":
			self.cap = Camera(0, [int(param[1]), int(param[2])], 60)
			self.encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 80]

		if param[0] == "robot_control":
			self.robot_control(param[1])

		elif param[0] == "video_stream":
			self.video_stream()

	def video_stream(self):
		ret, frame = self.cap.cam.read()
		result, imgencode = cv2.imencode(".jpg", frame, self.encode_param)
		data = numpy.array(imgencode)
		string_data = data.tostring()
		self.send("data:image/jpeg;base64,"+base64.b64encode(string_data))

	def robot_control(self, direction):
		print direction



class RobotConnection(sockjs.tornado.SockJSConnection):

	def on_message(self, msg):
		self.send(msg)




if __name__ == "__main__":
	import logging
	import os

	logging.getLogger().setLevel(logging.DEBUG)

	CameraRouter = sockjs.tornado.SockJSRouter(CameraConnection, "/camera")
	RobotRouter = sockjs.tornado.SockJSRouter(RobotConnection, "/robot")

	settings = {
		"static_path": os.path.join(os.path.dirname(__file__), "stc")
	}

	app = tornado.web.Application(
		[
			(r"/", IndexHandler)
		]
		+ RobotRouter.urls
		+ CameraRouter.urls
		, **settings
	)

	app.listen(8080)
	tornado.ioloop.IOLoop.instance().start()