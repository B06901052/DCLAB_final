# -*- coding=utf-8 -*-
from template import agent_template

"""
agent_template裡面有一些可以用的method(已經繼承惹可以直接call)，可以去研究一下template.py，
有用的話應該會寫很快，如果要新增method的話請在本檔案增加，不能動template.py
要測驗效果請打python main.py chao
"""


class agent(agent_template):
	def __init__(self):
		tmp = len(__file__) - __file__[::-1].find("/")
		super(agent, self).__init__(name=__file__[tmp+6:-3])

	def next_step(self, board):
		"""
		board: 8x8 np.array(np.int16), 
		黑=-1, 白=-2, 不能下=0, 1<=能下<=0xff
		從LSB到MSB依序是0度, 45度,...,315度
		e.g. 若有一格值為0b00000101，則代表下這格會導致該子右邊與上面翻棋

		return your step as tuple (row, column)
		"""
		self.board = board  # do not modify
		# todo
		row, col = 8, 8
		return (row, col)
