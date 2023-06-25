import sys
filenames = sys.argv[1:]

combined = b""
files = []

for filename in filenames:
	files.append(open(filename, "rb"))

done = [False] * len(files)
while not all(done):
	char = 0
	for i, f in enumerate(files):
		if not done[i]:
			tmp = f.read(1)
			if tmp == b"":
				done[i] = True
			else:
				char |= tmp[0]
	if not all(done):
		combined += bytes([char])

with open("combined.bin", "wb") as f:
	f.write(combined)
