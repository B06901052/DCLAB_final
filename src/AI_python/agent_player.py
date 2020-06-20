# -*- coding=utf-8 -*-
from template import agent_template
import numpy as np

"""
agent_template裡面有一些可以用的method(已經繼承惹可以直接call)，可以去研究一下template.py，
有用的話應該會寫很快，如果要新增method的話請在本檔案增加，不能動template.py
"""


class agent(agent_template):
	def __init__(self, method=1):
		tmp = len(__file__) - __file__[::-1].find("/")
		super(agent, self).__init__(name=__file__[tmp+6:-3])
		self.method = method

	def next_step(self, board):
		while True:
			try:
				x, y = input("your step: ").split(" ")
				step = (int(x), int(y))
				if board[step] > 0:
					return step
				else:
					continue
			except:
				continue
