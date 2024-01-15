import os
import sys
import glob
import markdown
from bs4 import BeautifulSoup
import requests
import json
from pkg_resources import parse_version

DATE = sys.argv[1]
IN_PATH = "targetList/"+DATE+"/"
OUT_PATH = "targetList/"

def searching(path):
    paths = []
    for i in glob.iglob(os.path.join(path, "**", "README.md"), recursive=True):
        paths.append(i)
    return sorted(paths[1:])

def tagSearch(target):
    url = "https://hub.docker.com/v2/repositories/"+target+"/tags/"
    response = requests.get(url)
    data = response.json()
    with open(OUT_PATH+"test.json", mode="w") as file:
        json.dump(data, file, indent=4)


def main():
    def makingSoups(soups, list):
        for path in list:
            with open(path) as file:
                soup = BeautifulSoup(markdown.markdown(file.read()), "html.parser")
                soups.append([path.split("/")[2], soup])
        return soups

    def preTag(list):
        if len(list) == 1 and list[0] == "latest":
            return list
        else:
            list = [i for i in list if i != "latest"]
            sortL = sorted(list, key=parse_version, reverse=True)
            return sortL

    def pouringSoups(soup):
        urlL, tagL = [], []
        for liTag in soup.find_all("li"):
            link = liTag.find("a")
            if link:
                href = link.get("href")
                if "Dockerfile" in href.split("/")[-1]:
                    codeTags = link.find_all("code")
                    urlL.append(href)
                    tagL.append(preTag([code.text for code in codeTags]))
        return urlL, tagL

    def convRaw(url):
        parts = url.split("/")
        parts[2] = "raw.githubusercontent.com"
        parts.remove("blob")
        return "/".join(parts)
    
    soups = makingSoups([], searching(IN_PATH))
    
    with open(OUT_PATH+DATE+"target.txt", mode="w") as file:
        pass
    with open(OUT_PATH+DATE+"Dockerfile.txt", mode="w") as file:
        pass
    with open(OUT_PATH+DATE+"rawURL.txt", mode="w") as file:
        pass

    for target, soup in soups:
        urlL, tagL = pouringSoups(soup)
        if urlL != [] and tagL != []:
            for tag in tagL:
                with open(OUT_PATH+DATE+"target.txt", mode="a") as file:
                    file.write("{}:{}\n".format(target, tag[0]))
            for url, tag in zip(urlL, tagL):
                with open(OUT_PATH+DATE+"Dockerfile.txt", mode="a") as file:
                    file.write("{}:{} {}\n".format(target, tag[0], url))
                with open(OUT_PATH+DATE+"rawURL.txt", mode="a") as file:
                    file.write("{}:{} {}\n".format(target, tag[0], convRaw(url)))

main()