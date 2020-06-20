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
		self.Vmap = np.array([[31,6,7,7,7,7,6,31],
				              [6,0,7,7,7,7,0,6],
				              [7,7,7,7,7,7,7,7],
				              [7,7,7,7,7,7,7,7],
				              [7,7,7,7,7,7,7,7],
				              [7,7,7,7,7,7,7,7],
				              [6,0,7,7,7,7,0,6],
				              [31,6,7,7,7,7,6,31]])

	def next_step(self, board):
		if self.method == 0:
			return self.next_step0(board)
		elif self.method == 1:
			return self.next_step1(board)
	
	def next_step0(self, board):
		"""
		board: 8x8 np.array(np.int16), 
		黑=-1, 白=-2, 不能下=0, 1<=能下<=0xff
		從LSB到MSB依序是0度, 45度,...,315度
		e.g. 若有一格值為0b00000101，則代表下這格會導致該子右邊與上面翻棋

		return your step as tuple (row, column)
		"""
		self.board = board  # do not modify
		# todo
		step = (8, 8)
		MAX = 0
		for row in range(8):
			for col in range(8):
				record = self.board[row, col]
				if record > 0:
					count = np.sum(self.decode_moves(record))
					if count > MAX:
						MAX = count
						step = (row, col)

		return step
	
	def recursive(self, boards, child):
		if type(boards[0]) == np.ndarray:
			board, step, flip_other = boards
			rows, cols = np.where(board > 0)
			indices = zip(rows, cols)

			boards_new = []
			for index in indices:
				self.board = board.copy()
				flip = self.updater(index) - flip_other + self.Vmap[index]
				self.order = self.another()
				nstop = self.alter_board()#notice, and hash
				boards_new.append((self.board.copy(), index, flip))
				self.order = self.another()
				
			boards_new.sort(key=lambda x:x[2])

			if len(boards_new) > child:
				boards_new = boards_new[-child:]
			return (boards_new, step, flip_other)
		else:
			return ([self.recursive(b, child) for b in boards[0]], boards[1], boards[2])

	def find_max(self, l):
		max_step, max_flip = (8,8), -np.inf
		count = 1
		for x in l[0]:
			if type(x) == list:
				step, flip = self.find_max(x)
				if flip > max_flip:
					max_step, max_flip = step, flip
				elif flip == max_flip:
					if np.random.randint(0,count) == 0:
						max_step, max_flip = step, flip
						count += 1

			elif type(x) == tuple:
				if x[2] > max_flip:
					max_step, max_flip = x[1:]
				elif x[2] == max_flip:
					if np.random.randint(0,count) == 0:
						max_step, max_flip = x[1:]
						count += 1
				
		return (max_step, max_flip)

	
	def next_step1(self, board, depth=5, child=1):
		boards = self.recursive((board, None, 0), child)

		for _ in range(depth):
			self.order = self.another()
			boards = self.recursive(boards, child)
			self.order = self.another()
			boards = self.recursive(boards, child)
		
		step, _ = self.find_max(boards)

		return step
	

