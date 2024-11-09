
from hexdump import hexdump
from icecream import ic

data = bytes(range(256))

hexdump(data)
ic(data)