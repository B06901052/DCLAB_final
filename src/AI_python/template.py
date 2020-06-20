import numpy as np
from os import system, path, mkdir
from time import time, localtime

dumpdir = "./dump/"
if not path.exists(dumpdir):
	mkdir(dumpdir)


def filename():
	t = localtime(time())
	return "{0:02d}_{1:02d}_{2:02d}_{3:02d}_{4:02d}.csv".format(t.tm_mon, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec)


class agent_template(object):
	def __init__(self, name="feng01"):  # name=agent's name
		self.name = name
		self.board = np.zeros((8, 8), dtype=np.int16)
		self.order = 0
		self.moves = np.array([(0, 1), (-1, 1), (-1, 0), (-1, -1),
                         (0, -1), (1, -1), (1, 0), (1, 1)])

	def another(self):
		return -self.order - 3

	def next_step(self, board):
		"""return your step as tuple (row, column)"""
		self.board = board
		# todo
		for x in range(1000):
			step = tuple(np.random.randint(0, 8, size=(2,)))
			if self.board[step] > 0:
				break
			if x == 1000:
				raise ValueError("over iteration")

		return step

	def _validator(self, step):
		"""check step is valid"""
		for move in self.moves:
			square = step
			boo = False
			while (0 <= square[0] < 8 and 0 <= square[1] < 8):
				square += move
				if self.board[square] == self.another():
					boo = True
				elif self.board[square] == self.order and boo:
					return True
				else:
					break

		return False

	def updater(self, step):
		"""update board"""
		moves_pos = self.decode_moves(self.board[step])
		self.board[step] = self.order

		for move in self.moves[moves_pos]:
			square = step + move
			while (0 <= square[0] < 8 and 0 <= square[1] < 8):
				if self.board[tuple(square)] == self.another():
					self.board[tuple(square)] = self.order
					square += move
				else:
					break

	def decode_moves(self, i):
		assert i > 0, "this step is invalid"
		ans = []

		for _ in range(8):
			ans.append(bool(i % 2))
			i >>= 1

		return ans


class Game(agent_template):
	def __init__(self, agent1, agent2):
		super(Game, self).__init__()
		self.agent1 = agent1  # black -1
		self.agent2 = agent2  # white -2
		self.score = (2, 2)
		self.order = -1
		self.result = []

	def start(self, verbose=0, dump=False, filename=filename()):
		"""
		game start
		verbose
			0:print board and wait
			1:print board
			2:no board
		"""
		self.result = []
		# reset board
		self.board = np.zeros((8, 8), dtype=np.int16)
		self.board[3, 4], self.board[4, 3] = -1, -1  # black -1
		self.board[3, 3], self.board[4, 4] = -2, -2  # white -2
		self.score = (2, 2)
		self.order = -1
		# choise who is the first
		self.random_order()
		# alter boart
		nstop = self.alter_board()
		# output board
		if verbose == 0:
			self.output(wait=True)
		elif verbose == 1:
			self.output(wait=False)

		while (nstop):
			if self.order == -1:
				step = self.agent1.next_step(self.board)
			else:
				step = self.agent2.next_step(self.board)

			tmp = self.board[step]
			self.board[step] = -3
			if verbose == 0:
				self.output(wait=True)
			elif verbose == 1:
				self.output(wait=False)

			self.board[step] = tmp
			self.updater(step)
			self.result.append("{0},{1},{2}".format(self.order, step[0], step[1]))

			self.order = self.another()
			nstop = self.alter_board()
			self.result[-1] += ",{0},{1}".format(self.score[0], self.score[1])

			if verbose == 0:
				self.output(wait=True)
			elif verbose == 1:
				self.output(wait=False)

		if dump:
			with open(dumpdir + filename, 'w') as f:
				f.write("\n".join(self.result))

		return self.score

	def random_order(self):
		if (np.random.randint(0, 2)):
			self.agent1, self.agent2 = self.agent2, self.agent1
		self.agent1.order = -1
		self.agent2.order = -2

	def output(self, wait=True):
		system("cls")
		print("black(1,X): {0:8}score: {1}".format(
			self.agent1.name, self.score[0]), flush=not wait)
		print("white(2,O): {0:8}score: {1}".format(
			self.agent2.name, self.score[1]), flush=not wait)
		print("current: " + str(-self.order))
		output = np.empty((8, 8))
		output = np.where(self.board >= 0, " ", output)
		output = np.where(self.board == -1, "X", output)
		output = np.where(self.board == -2, "O", output)
		output = np.where(self.board == -3, "#", output)
		print(output, flush=not wait)
		if wait:
			input()

	def alter_board(self, first=True):
		"""
		record possible step and the resulting changing move
		e.g. board[row,col]=0b00001101 means move[0], move[2], move[3] are possible
		return False if game finishs.
		"""
		# no square for next step
		nomove = True
		# iterate whole board
		score = np.zeros((2,), dtype=np.int8)
		for row in range(8):
			for col in range(8):
				# if exists piece, then break
				if self.board[row, col] < 0:
					score[-self.board[row, col] - 1] += 1
					continue
				# else compute possible move
				self.board[row, col] = 0
				for i, move in enumerate(self.moves):
					# current square
					square = np.array([row, col]) + move
					boo = False
					while ((0 <= square[0] < 8) and (0 <= square[1] < 8)):
						if self.board[tuple(square)] == self.another():
							boo = True
						elif self.board[tuple(square)] == self.order and boo:
							self.board[row, col] += (1 << i)
							nomove = False
							break
						else:
							break
						square += move

		self.score = tuple(score)
		# if no square for next step, then change order
		if nomove:
			if first:
				self.order = self.another()
				return self.alter_board(False)
			# if not first change(both players are not able to step), then stop
			else:
				return False
		else:
			return True


if __name__ == "__main__":
	agent1 = agent_template("feng")
	agent2 = agent_template("chao")

	game = Game(agent1, agent2)
	for x in range(10):
		print("round: {0:2d}".format(x), end="  ")
		score = game.start(verbose=2, dump=True, filename=str(x) + ".csv")
		if score[0] > score[1]:
			print("score={0}  winner: {1}".format(score, game.agent1.name))
		elif score[0] < score[1]:
			print("score={0}  winner: {1}".format(
				(score[1], score[0]), game.agent2.name))
		else:
			print("score={0}  draw".format(score))
