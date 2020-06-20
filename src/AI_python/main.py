from agent_tsai import agent as tsai
from agent_tsai_unweighted import agent as tsai_unweighted
from agent_chao import agent as chao
from agent_feng import agent as feng
from agent_player import agent as player
from template import agent_template, Game
from os import path, mkdir
from sys import argv
template = agent_template
"""
python main.py (chao/tsai/feng) (test/debug)
python main.py feng debug
"""

dumpdir = "./dump/"
if not path.exists(dumpdir):
	mkdir(dumpdir)


def test(a1, a2=agent_template, mode="test"):
	agent1 = a1()
	agent2 = a2()

	if mode == "debug":
		verbose, dump, times = 0, True, 1
	else:
		verbose, dump, times = 2, False, 100

	game = Game(agent1, agent2)
	count = 0
	for x in range(times):
		print("round: {0:2d}".format(x), end="  ")
		score = game.start(verbose=verbose, dump=dump)
		if score[0] > score[1]:
			if game.agent1.name == agent1.name:
				count += 1
			print("score={0}  winner: {1}".format(score, game.agent1.name))
		elif score[0] < score[1]:
			if game.agent2.name == agent1.name:
				count += 1
			print("score={0}  winner: {1}".format(
				(score[1], score[0]), game.agent2.name))
		else:
			count += 0.5
			print("score={0}  draw".format(score))
		
	print("rate={}%".format(count*100/times))


if __name__ == "__main__":
	try:
		test(eval(argv[1]), eval(argv[3]), mode = argv[2])
	except:
		test(eval(argv[1]), mode = argv[2])
