
from icecream import ic

a = range(1, 11)

# range
ic(a)

# convert to list
ic(list(a))
ic(list(a[:]))

# individual items
ic(a[0])
ic(a[1])
ic(a[-2])
ic(a[-1])

# slice start:stop
ic(list(a[2:5]))
ic(list(a[0:5]))
ic(list(a[0:-1]))
ic(list(a[:-2]))
ic(list(a[2:]))

# stepping
ic(list(a[::2]))
ic(list(a[::-1]))
ic(list(a[::-2]))

# two lists joined
ic(list(a[:5]) + list(a[6:]))

# strings
s = "Hello";
ic(s[-3:])