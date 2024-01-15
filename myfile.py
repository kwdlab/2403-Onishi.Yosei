import os
import glob
import json
import csv

def searching(path):
    return glob.glob(os.path.join(path, "*.json"))

def loadingJson(pathList):
    packages = []
    for address in pathList:
        with open(address) as package:
            packages.append(json.load(package))
    return packages

def slash(tmp):
    try:
        return "_".join(tmp.split("/"))
    except:
        return tmp
    
def loadingDifCSV(path):
    with open(path) as package:
        return list(csv.reader(package))