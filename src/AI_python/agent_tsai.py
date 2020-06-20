# -*- coding=utf-8 -*-
from template import agent_template
import numpy as np
"""
agent_template裡面有一些可以用的method(已經繼承惹可以直接call)，可以去研究一下template.py，
有用的話應該會寫很快，如果要新增method的話請在本檔案增加，不能動template.py
要測驗效果請打python main.py tsai debug/test
"""


class agent(agent_template):
	def __init__(self):
		tmp = len(__file__) - __file__[::-1].find("/")
		super(agent, self).__init__(name=__file__[tmp + 6:-3])

	def next_step(self, board):
		"""
		board: 8x8 np.array(np.int16), 
		黑=-1, 白=-2, 不能下=0, 1<=能下<=0xff
		從LSB到MSB依序是0度, 45度,...,315度
		e.g. 若有一格值為0b00000101，則代表下這格會導致該子右邊與上面翻棋

		self.order=-1, 我方為黑
		self.order=-2, 我方為白

		return your step as tuple (row, column)
		"""
		self.board = board.copy()  # do not modify
		# todo
		MAX = 0
		temp = 0
		row = 0
		col = 0
		temp2 = 0
		Vmap = [[31, 6, 7, 7, 7, 7, 6, 31],
                    [6, 0, 7, 7, 7, 7, 0, 6],
                    [7, 7, 7, 7, 7, 7, 7, 7],
                    [7, 7, 7, 7, 7, 7, 7, 7],
                    [7, 7, 7, 7, 7, 7, 7, 7],
                    [7, 7, 7, 7, 7, 7, 7, 7],
                    [6, 0, 7, 7, 7, 7, 0, 6],
                    [31, 6, 7, 7, 7, 7, 6, 31]]
		for j in range(8):
			for i in range(8):
				if board[i][j] > 0:
					t = (i, j)
					self.board = board.copy()
					temp = self.updater(t)
					temp2 = temp + Vmap[i][j]
					if temp2 > MAX:
						print("original row %d col %d MAX %d" % (row, col, MAX))
						MAX = temp2
						row = i
						col = j
						print("updated row %d col %d MAX %d " % (row, col, MAX))
					if(i == 5 and j == 2):
						print("row 5 col 2 score %d temp %d" % (temp2, temp))

		return (row, col)
