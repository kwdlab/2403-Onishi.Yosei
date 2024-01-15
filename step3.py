import sys
import csv
import collections
from myfile import *

DATE = sys.argv[1]
IN_PATH = "step2OUT/"+DATE+"/"
OUT_PATH = "step3OUT/"+DATE+"/"

def main():
    mainList, cveDB, pkgDB  = [], [], []
    for package in loadingJson(searching(IN_PATH)):
        name = package[0]["RepoTags"][0]
        created = package[0]["created"]
        pacList = [name, created]

        if len(package) == 1:
            package.append("end")

        for classpk in package[1:]:
            classList = []
            if classpk == "end":
                classList.append("NOT DETECTED")

            elif classpk["Class"] != "secret":
                classList.append(classpk["Target"])
                vul = classpk["Vulnerabilities"]
                severity = collections.Counter([tmp.get("Severity") for tmp in vul])
                
                for id in vul:
                    cveDBset = [
                        id["VulnerabilityID"],
                        id["Severity"],
                        id["SeveritySource"],
                        id["CweIDs"],
                        id["PublishedDate"],
                        id["LastModifiedDate"],
                    ]
                    cveDB.append(cveDBset)
                    
                    pkgDBset = [
                        id["PkgName"],
                        id["InstalledVersion"],
                        id["VulnerabilityID"],
                        id["Severity"]
                    ]
                    pkgDB.append(pkgDBset)
        
                classList.extend([severity['LOW'], severity['MEDIUM'], severity['HIGH'], severity['CRITICAL'], severity['UNKNOWN'], len(vul)])
            
            else:
                pass

            pacList.append(classList)
        mainList.append(pacList)

    with open(OUT_PATH+"main.csv", mode="w") as file:
        w = csv.writer(file)
        w.writerows(mainList)

    with open(OUT_PATH+"cveDB.csv", mode="w") as file:
        w = csv.writer(file)
        w.writerows(cveDB)

    with open(OUT_PATH+"pkgDB.csv", mode="w") as file:
        w = csv.writer(file)
        w.writerows(pkgDB)

    return
main()