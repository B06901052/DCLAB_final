from agent_tsai import agent as tsai
from agent_chao import agent as chao
from agent_feng import agent as feng
from template import agent_template, Game
from os import path, mkdir


dumpdir = "./dump/"
if not path.exists(dumpdir):
	mkdir(dumpdir)


def test(agent):
	agent1 = agent()
	agent2 = agent_template("rand")

	game = Game(agent1, agent2)
	count = 0
	for x in range(100):
		print("round: {0:2d}".format(x), end="  ")
		score = game.start(verbose=2, dump=False, filename=str(x) + ".csv")
		if score[0] > score[1]:
			count += 1
			print("score={0}  winner: {1}".format(score, game.agent1.name))
		elif score[0] < score[1]:
			print("score={0}  winner: {1}".format(
				(score[1], score[0]), game.agent2.name))
		else:
			print("score={0}  draw".format(score))

	print("rate={}%".format(count))


if __name__ == "__main__":
	# test(tsai)
	# test(chao)
	test(feng)
