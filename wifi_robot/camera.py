#! /usr/bin/env python
# coding:utf-8

import cv2
import string

from PIL import Image
from StringIO import StringIO

class Camera(object):

	def __init__(self, camera_id, size, fps):
		self.cam = cv2.VideoCapture(int(camera_id))
		self.cam.set(cv2.cv.CV_CAP_PROP_FPS, fps)
		self.cam.set(cv2.cv.CV_CAP_PROP_FRAME_WIDTH, size[0])
		self.cam.set(cv2.cv.CV_CAP_PROP_FRAME_HEIGHT, size[1])

	def __del__(self):
		self.cam.release()

	def get_frame(self):
		if not self.cam.isOpened():
			return ''

		ret, frame = self.cam.read()
		image = Image.fromarray(frame)
		buf = StringIO()
		image.save(buf, "JPEG")

		return buf.getvalue()


def main():

	cap = Camera(0, [480, 320], 60)
	

	while True:
		ret, frame = cap.cam.read()
		rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

		cv2.imshow("frame", frame)

		if cv2.waitKey(1) & 0xFF == ord("q"):
			break

	del cap
	#cv2.destoryAllWindows()

if __name__ == '__main__':
	main()