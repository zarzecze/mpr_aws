from os import listdir
from os.path import isfile, join

word_dict = {}
path = './'
for file in [open(path + f, "r", encoding="ISO-8859-1") for f in listdir(path) if isfile(join(path, f))]:
    for line in file:
        words = line.split(' ')
        for word in words:
            if word in word_dict:
                word_dict[word] += 1
            else:
                word_dict[word] = 1

for word, counter in word_dict.items():
    print(word, counter)