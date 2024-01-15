import sys
import requests
from pkg_resources import parse_version

DATE = sys.argv[1]
IN_PATH = "targetList/"+DATE
OUT_PATH = "targetList/"

def main():
    with open(IN_PATH+"tmp.txt", mode="r") as file:
        line = list(map(lambda l: l.rstrip("\n"), file.readlines()))
    result = []
    for cnt, target in enumerate(line):
        url = f"https://hub.docker.com/v2/repositories/{target}/tags?page_size=10000"
        response = requests.get(url)
        if response.status_code == 200:
            json_data = response.json()
            tags = [tag['name'] for tag in json_data.get('results', [])]
            tags = [i for i in tags if i != "latest"]
            if tags == []:
                pass
            else:
                tags = [i for i in tags if i != "latest"]
                selected = sorted(tags, key=parse_version, reverse=True)[0]
                tmp = target+":"+selected
                print(tmp+" {}/{}".format(cnt+1, len(line)))
                result.append(tmp)
        else:
            pass
    
    with open(OUT_PATH+DATE+"VerifiedTarget.txt", mode="w") as file:
        for i in result:
            file.write(i)
            file.write("\n")
main()