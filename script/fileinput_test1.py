
import fileinput

sizes = dict([line.strip().split("\t") for line in fileinput.input()])
print(sizes)
