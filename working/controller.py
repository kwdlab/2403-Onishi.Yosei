import os
import sys
import glob
import subprocess
import datetime

def mkdate():
    t_delta = datetime.timedelta(hours=9)
    JST = datetime.timezone(t_delta, "JST")
    now = datetime.datetime.now(JST)
    date = now.strftime("%Y%m%d")
    return date

def mkdir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def main():
    flag = sys.argv[1] 
    date = mkdate()

    def ScrDockerfile():
        if not os.path.exists("./targetList/"+date):
            subprocess.run(["git", "clone", "https://github.com/docker-library/docs", "./targetList/"+date])
        mkdir("./dockerfile/"+date)
        mkdir("./dockerfile/step1OUT/"+date)
        mkdir("./dockerfile/step2OUT/"+date)
        mkdir("./dockerfile/step3OUT/"+date)
        subprocess.run(["python3", "./docsStep.py", date])
        subprocess.run(["python3", "./dockerStep.py", date])
        subprocess.run(["python3", "./dockerStep2.py", date])
        subprocess.run(["python3", "./dockerStep3.py", date])

    def ScrImages():
        mkdir("./targetList/"+date)
        subprocess.run(["python3", "./publisherScraping.py", date])
        with open("./targetList/"+date+"publisher.txt", mode="r") as file:
            line = list(map(lambda l: l.rstrip("\n"), file.readlines()))
        for tar in list(set(line)):
            subprocess.run(["./step0a.sh {} {}".format(tar, date)], shell=True)
        subprocess.run(["python3", "./step0b.py", date])
        subprocess.run(["python3", "./step0c.py", date])

    def flag1():
        outputDir = "./step1OUT/"
        mkdir(outputDir+date)
        targetList = "20231115VerifiedTarget"
        with open("./targetList/"+targetList+".txt", mode="r") as file:
            line = list(map(lambda l: l.rstrip("\n"), file.readlines()))

        nameList = list(range(1, len(line)+1))
        passedList = [int(os.path.splitext(os.path.basename(file))[0]) for file in glob.glob(outputDir+date+"/*.*")]
        def runTrivy(target, cnt):
            if cnt in passedList or "windowsservercore" in target or "nanoserver" in target:
                print(str(cnt)+" "+target+" pass")
            else:
                print(str(cnt)+" "+target+" run")
                subprocess.run(["./step1.sh {} {} {}".format(target, cnt, date)], shell=True)

        for target, cnt in zip(line, nameList):
            runTrivy(target, cnt)

    def flag1test(before, after):
        outputDir = "./step1OUT/"
        passedListB = [int(os.path.splitext(os.path.basename(file))[0]) for file in glob.glob(outputDir+before+"/*.*")]
        passedListA = [int(os.path.splitext(os.path.basename(file))[0]) for file in glob.glob(outputDir+after+"/*.*")]
        print(list(set(passedListB)-set(passedListA)))

    def flag2(tmp):
        mkdir("./step2OUT/"+tmp)
        subprocess.run(["python3", "./step2.py", tmp])

    def flag3(tmp):
        mkdir("./step3OUT/"+tmp)
        subprocess.run(["python3", "./step3.py", tmp])

    def flag4(tmp2, tmp3):
        mkdir("./step4OUT/weeks/"+tmp2+"-"+tmp3)
        mkdir("./step4OUT/"+tmp2)
        mkdir("./step4OUT/"+tmp3)
        subprocess.run(["python3", "./step4.py", tmp2, tmp3])
        
    def dockerfileScan(tmp):
        outputDir = "./dockerfile/step1OUT/"+tmp+"/"
        mkdir(outputDir)
        line = glob.glob(os.path.join("./dockerfile/"+tmp+"/*.Dockerfile"))
        nameList = list(range(1, len(line)+1))
        def runTrivy(target, cnt):
            print(str(cnt)+" "+target+" run")
            subprocess.run(["./policyScan.sh {} {} {}".format(target, cnt, tmp)], shell=True)

        for target, cnt in zip(line, nameList):
            print(target)
            runTrivy(target, cnt)


    if (flag=="dockerfile"): #ターゲット名を集める (実行に応じて自動的にdate算出)
        ScrDockerfile()

    elif (flag=="images"): #ターゲット名を集める (実行に応じて自動的にdate算出)
        ScrImages()

    elif (flag=="1"): #ターゲット名に従いtrivyを実行する (実行に応じて自動的にdate算出)
        flag1()

    elif (flag=="test"):
        flag1test(sys.argv[2], sys.argv[3])

    elif (flag=="2"): #生の出力からデータを切り出す (要date指定)
        flag2(sys.argv[2])

    elif (flag=="3"): #データをさらに切り出し、集計する (要date指定)
        flag3(sys.argv[2])
    
    elif (flag=="4"): #集計した2dateを比較する (要date指定 * 2)
        flag4(sys.argv[2], sys.argv[3])

    elif (flag=="scan"): #DockerfileScan (要date指定)
        dockerfileScan(sys.argv[2])

    return

main()

#python3 controler.py 0 
#python3 controler.py 1
#python3 controler.py test date date
#python3 controler.py 2 date
#python3 controler.py 3 date
#python3 controler.py 4 date date
#python3 controler.py scan date