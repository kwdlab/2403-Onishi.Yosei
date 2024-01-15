import sys
import os
import glob

DATE = sys.argv[1]
IN_PATH = "targetList/"+DATE+"/"
OUT_PATH = "targetList/"

def main():
    pathL = [os.path.splitext(os.path.basename(file))[0] for file in glob.glob(IN_PATH+"*.txt")]
    result = []
    for path in pathL:
        with open(IN_PATH+path+".txt", mode="r") as file:
            line = list(map(lambda l: l.rstrip("\n"), file.readlines()))
            line = list(map(lambda l: path+"/"+l, line))
        result.extend(line)
    with open(OUT_PATH+DATE+"tmp.txt", mode="w") as file:
        for i in result:
            file.write(i+"\n")

main()