
import random
import fileinput

# load list of words from hangman.txt or somewhere else
words = [line.rstrip() for line in fileinput.input(files='script/hangman.txt')]

# play game
word = random.choice(words)
print(word)

