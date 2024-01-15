import requests
import sys

DATE = sys.argv[1]
IN_PATH = "targetList/"
OUT_PATH = "dockerfile/"+DATE+"/"

def main():
    with open(IN_PATH + DATE +"rawURL.txt", mode="r") as file:
        tmp = list(map(lambda l: l.rstrip("\n"), file.readlines()))
    for pack in tmp:
        filename, url = pack.split(" ")
        response = requests.get(url)
        print(filename)
        if response.status_code == 200:
            with open(OUT_PATH+filename+".Dockerfile", "w") as file:
                file.write(response.text)
                print("complete")
        else:
            print("pass")
    
main()