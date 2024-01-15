import collections
import sys
import csv
from myfile import *

DATE = sys.argv[1]
IN_PATH = "dockerfile/step2OUT/"+DATE+"/"
OUT_PATH = "dockerfile/step3OUT/"+DATE+"/"

def main():
    mainList, count = [], []
    for package in loadingJson(searching(IN_PATH)):
        result = []
        for line in package:
            result.append(line["Target"])
            result.extend([line["MisconfSummary"]["Failures"]])
            try:
                tmp = [p.get("AVDID") for p in line["Misconfigurations"]]
                count.extend(tmp)
                result.extend(tmp)                
            except:
                pass
            
            mainList.append(result)
    
    with open(OUT_PATH+"main.csv", mode="w") as file:
        w = csv.writer(file)
        w.writerows(mainList)
    with open(OUT_PATH+"count.csv", mode="w") as file:
        w = csv.writer(file)
        w.writerows(collections.Counter(count).items())
    return
main()