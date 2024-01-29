import sys
import csv
import collections
from myfile import *
import ast

DATEB = sys.argv[1]
DATEA = sys.argv[2]
IN_PATH_B = "step3OUT/"+DATEB+"/"
IN_PATH_A = "step3OUT/"+DATEA+"/"
OUT_PATH = "step4OUT/weeks/"+DATEB+"-"+DATEA+"/"
OUT_PATHB = "step4OUT/"+DATEB+"/"
OUT_PATHA = "step4OUT/"+DATEA+"/"

def main():

    def setEnvVar(select):
        if select == "before":
            return DATEB, IN_PATH_B, OUT_PATHB
        elif select == "after":
            return DATEA, IN_PATH_A, OUT_PATHA

    def resultMain():
        with open(OUT_PATH+"resultMain.txt", mode="w") as file:
            before = loadingDifCSV(IN_PATH_B+"main.csv")
            after = loadingDifCSV(IN_PATH_A+"main.csv")
            
            for b, a in zip(sorted(before), sorted(after)):
                file.write(a[0]+"\n")
                if a == b and b[1] == a[1]:
                    file.write("NOT CHANGED\n")
                    file.write("now: {}\n".format(a[1]))
                    file.write("now: {}\n".format(a[2:]))
                elif b[1] != a[1]:
                    file.write("IMAGE UPDATED\n")
                    file.write("old: {} -> now: {}\n".format(b[1], a[1]))
                    file.write("old: {}\n".format(b[2:]))
                    file.write("now: {}\n".format(a[2:]))
                else:
                    file.write("CHANGE DETECTED\n")
                    file.write("now: {}\n".format(a[1]))
                    file.write("old: {}\n".format(b[2:]))
                    file.write("now: {}\n".format(a[2:]))
                file.write("\n")

    def cal(datalist):
        tmp = [[],[],[],[],[]]
        for ab in datalist:
            if ab[1] == "UNKNOWN":
                tmp[4].append(ab[0])
            elif ab[1] == "LOW":
                tmp[3].append(ab[0])
            elif ab[1] == "MEDIUM":
                tmp[2].append(ab[0])
            elif ab[1] == "HIGH":
                tmp[1].append(ab[0])
            elif ab[1] == "CRITICAL":
                tmp[0].append(ab[0])
        return tmp

    def severitySplit(select):
        date, inpath, outpath = setEnvVar(select)
        datalist = loadingDifCSV(inpath+"cveDB.csv")
        
        def printRANK(list, OUT_PATH):
            with open(OUT_PATH+"rankCRITICAL.csv", mode="w") as file:
                w = csv.writer(file)
                w.writerows(sorted(collections.Counter(list[0]).items(), reverse=True, key=lambda x: x[1]))
            with open(OUT_PATH+"rankHIGH.csv", mode="w") as file:
                w = csv.writer(file)
                w.writerows(sorted(collections.Counter(list[1]).items(), reverse=True, key=lambda x: x[1]))
            with open(OUT_PATH+"rankMEDIUM.csv", mode="w") as file:
                w = csv.writer(file)
                w.writerows(sorted(collections.Counter(list[2]).items(), reverse=True, key=lambda x: x[1]))
            with open(OUT_PATH+"rankLOW.csv", mode="w") as file:
                w = csv.writer(file)
                w.writerows(sorted(collections.Counter(list[3]).items(), reverse=True, key=lambda x: x[1]))

        printRANK(cal(datalist), outpath)
        return

    def mainCSV(select):
        date, inpath, outpath = setEnvVar(select)
        datalist = loadingDifCSV(inpath+"main.csv")

        def timeset(form):
            b, a = form.split("T")
            y, m, d = b.split("-")
            return "/".join([y, m, d])

        result = []
        for tmp in datalist:
            total = [ast.literal_eval(i)[1:] for i in tmp[2:]]
            total = [[int(item) for item in sublist] for sublist in total]
            total = [sum(column) for column in zip(*total)]
            target, version = tmp[0].split(":")
            date = timeset(tmp[1])
            try:
                fin = [target, version, date, total[0], total[1], total[2], total[3], total[4], total[5]]
            except:
                fin = [target, version, date, "null"]
            result.append(fin)
        with open(outpath+"LastMain.csv", mode="w") as file:
            w = csv.writer(file)
            w.writerows(result)

    def uniqueCVEID():
        before = loadingDifCSV(IN_PATH_B+"cveDB.csv")
        after = loadingDifCSV(IN_PATH_A+"cveDB.csv")

        def vulNumDiff(tmpB, tmpA):
            with open(OUT_PATH+"vulNumDiff.txt", mode="w") as file:
                def writeVari(oldnow, tmp):
                    sev = [len(row) for row in tmp]
                    file.write(oldnow+" TOTAL: {}\n".format(sum(sev)))
                    file.write("CRITICAL: {}, HIGH: {}, MEDIUM: {}, LOW: {}, UNKNOWN: {}\n"
                            .format(sev[0], sev[1], sev[2], sev[3], sev[4]))
                    
                writeVari("old", tmpB)
                file.write("\n")
                writeVari("now", tmpA)
        
        vulNumDiff(cal(before), cal(after))
 
        def uniformization():
            tmp = {}
            for b in before:
                if b[0] not in tmp:
                    tmp[b[0]] = [(b[1], b[2])]
                else:
                    tmp[b[0]].append((b[1], b[2]))
            for a in after:
                if a[0] not in tmp:
                    tmp[a[0]] = [(a[1], a[2])]
                else:
                    tmp[a[0]].append((a[1], a[2]))
            return tmp.items()
        
        cveDB = []
        for i, j in uniformization():
            cveDB.append([i, list(set(j))])
            

        with open(OUT_PATH+"uniqueCVEID.csv", mode="w") as file:           
            w = csv.writer(file)
            w.writerows(cveDB)
        return

    def countPKGDB(select):
        date, inpath, outpath = setEnvVar(select)
        datalist = loadingDifCSV(inpath+"pkgDB.csv")

        def transDict(data, dict, date):
            for key, ver, id, severity in data:
                if (key, ver) in dict:
                    dict[(key, ver)].append((id, severity))
                else:
                    dict[(key, ver)] = [(id, severity)]

            result = []
            for (key, ver), values in dict.items():
                setKey = [
                    key,
                    ver,
                    len(values),
                    len(set(values)),
                    int(len(values)/len(set(values)))
                ]
                result.append(setKey)

            with open(outpath+"/count.csv", mode="w") as file:
                w = csv.writer(file)
                w.writerow(["name", "version", "総検出数", "内包数", "使用回数"])
                w.writerows(result)
            return 

        transDict(datalist, {}, date)
        return

    def compMain():
        before = loadingDifCSV(OUT_PATHB+"LastMain.csv")
        after = loadingDifCSV(OUT_PATHA+"LastMain.csv")
        result = []
        res1, res2 = [], []

        for b, a in zip(sorted(before), sorted(after)):
            if b[3] == "null":
                b1, b2, b3, b4, b5, b6 = 0, 0, 0, 0, 0, 0
            else :
                b1, b2, b3, b4, b5, b6 = int(b[3]), int(b[4]), int(b[5]), int(b[6]), int(b[7]), int(b[8])
            if a[3] == "null":
                a1, a2, a3, a4, a5, a6 = 0, 0, 0, 0, 0, 0
            else :
                a1, a2, a3, a4, a5, a6 = int(a[3]), int(a[4]), int(a[5]), int(a[6]), int(a[7]), int(a[8])
            p1, p2, p3, p4, p5, p6= a1 - b1, a2 - b2, a3 - b3, a4 - b4, a5 - b5, a6 - b6

            if b[2] == a[2]:
                result.append([b[0], b[1], b[2], "null", "NOT UPDATED", p1, p2, p3, p4, p5, p6])
                res1.append([b[0], b[1], b[2], "null", "NOT UPDATED", p1, p2, p3, p4, p5, p6])
            else:
                result.append([b[0], b[1], b[2], a[2], "IMAGE UPDATED", p1, p2, p3, p4, p5, p6])
                res2.append([b[0], b[1], b[2], a[2], "IMAGE UPDATED", p1, p2, p3, p4, p5, p6])

        out = [
            ["TOTAL", len(result),\
                sum([tmp[5] for tmp in result]), sum([tmp[6] for tmp in result]), sum([tmp[7] for tmp in result]),\
                sum([tmp[8] for tmp in result]), sum([tmp[9] for tmp in result]), sum([tmp[10] for tmp in result])],
            ["NOT UPDATED", len(res1),\
                sum([tmp[5] for tmp in res1]), sum([tmp[6] for tmp in res1]), sum([tmp[7] for tmp in res1]),\
                sum([tmp[8] for tmp in res1]), sum([tmp[9] for tmp in res1]), sum([tmp[10] for tmp in res1])],
            ["IMAGE UPDATED", len(res2),\
                sum([tmp[5] for tmp in res2]), sum([tmp[6] for tmp in res2]), sum([tmp[7] for tmp in res2]),\
                sum([tmp[8] for tmp in res2]), sum([tmp[9] for tmp in res2]), sum([tmp[10] for tmp in res2])]
        ]

        with open(OUT_PATH+"CompMain.csv", mode="w") as file:
            w = csv.writer(file)
            w.writerows(result)
        with open(OUT_PATH+"nor.csv", mode="w") as file:
            w = csv.writer(file)
            w.writerows(out)
        return
    
    uniqueCVEID()
    for i in ["before", "after"]:
        severitySplit(i)
        mainCSV(i)
        countPKGDB(i)
    resultMain()
    compMain()

main()

