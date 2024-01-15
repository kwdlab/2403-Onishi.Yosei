import json
import sys
from myfile import *

DATE = sys.argv[1]
IN_PATH = "step1OUT/"+DATE+"/"
OUT_PATH = "step2OUT/"+DATE+"/"

def main():
    for package in loadingJson(searching(IN_PATH)):
        ArtifactName = slash(package["ArtifactName"])
        def exceptioning(sel, tag):
            try:
                return sel[tag]
            except:
                return "null"

        targets = []
        tagsCreated = {}
        meta = package["Metadata"]
        tagsCreated["RepoTags"] =  exceptioning(meta, "RepoTags")
        tagsCreated["created"] =  exceptioning(meta["ImageConfig"], "created")
        targets.append(tagsCreated)

        def extraction(targets, results):
            if results == "null":
                return targets
            
            for target in results:
                data = {}
                data["Target"] =  exceptioning(target, "Target")
                data["Class"] =  exceptioning(target, "Class")

                flatV = exceptioning(target, "Vulnerabilities")
                if flatV != "null":
                    vulnerabilities = []
                    for cve in flatV:
                        value = {}
                        value["VulnerabilityID"] = exceptioning(cve, "VulnerabilityID")
                        value["PkgName"] = exceptioning(cve, "PkgName")
                        value["InstalledVersion"] = exceptioning(cve, "InstalledVersion")
                        value["Status"] = exceptioning(cve, "Status")
                        value["FixedVersion"] = exceptioning(cve, "FixedVersion") 
                        value["Severity"] = exceptioning(cve, "Severity")
                        value["SeveritySource"] = exceptioning(cve, "SeveritySource")

                        try:
                            value["CweIDs"] = cve["CweIDs"]
                        except:
                            value["CweIDs"] = ["null"]

                        value["PublishedDate"] = exceptioning(cve, "PublishedDate")
                        value["LastModifiedDate"] = exceptioning(cve, "LastModifiedDate")
                        vulnerabilities.append(value)

                    data["Vulnerabilities"] = vulnerabilities
                    targets.append(data)
                else:
                    pass

            return targets

        out = extraction(targets, exceptioning(package, "Results"))
        with open(OUT_PATH+ArtifactName+".json", mode="w") as file:
            json.dump(out, file, indent=4)
    return
main()