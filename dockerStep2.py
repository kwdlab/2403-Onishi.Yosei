import json
import sys
from myfile import *

DATE = sys.argv[1]
IN_PATH = "dockerfile/step1OUT/"+DATE+"/"
OUT_PATH = "dockerfile/step2OUT/"+DATE+"/"

def main():
    for package in loadingJson(searching(IN_PATH)):
        ArtifactName = package["ArtifactName"].split("/")[2]
        def exceptioning(sel, tag):
            try:
                return sel[tag]
            except:
                return "null"

        def extraction(targets, results):
            if results == "null":
                return targets
            
            for target in results:
                data = {}
                data["Target"] =  exceptioning(target, "Target")
                data["Class"] =  exceptioning(target, "Class")
                if data["Class"] == "config":
                    data["MisconfSummary"] = exceptioning(target, "MisconfSummary")
                    Misconfigurations = exceptioning(target, "Misconfigurations")
                    if Misconfigurations != "null":
                        dss = []
                        for ds in Misconfigurations:
                            value = {}
                            value["AVDID"] = exceptioning(ds, "AVDID")
                            value["Severity"] = exceptioning(ds, "Severity")
                            value["Title"] = exceptioning(ds, "Title")
                            value["Description"] = exceptioning(ds, "Description")
                            dss.append(value)

                        data["Misconfigurations"] = dss
                        targets.append(data)
                    else:
                        targets.append(data)
                else:
                    pass
            return targets

        out = extraction([], exceptioning(package, "Results"))
        with open(OUT_PATH+ArtifactName+".json", mode="w") as file:
            json.dump(out, file, indent=4)
    return
main()