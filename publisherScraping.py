import os
import sys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup

DATE = sys.argv[1]
baseURL = "https://hub.docker.com/search?q=&type=image&image_filter=store&operating_system=linux"
OUT_PATH = "targetList/"

def searching(baseURL):
    option = Options()
    option.add_argument('--headless')    

    for num in range(1, 101):
        url = baseURL + "&page=" + str(num)
        driver = webdriver.Chrome(options=option)
        driver.get(url)
        wait = WebDriverWait(driver, 100)
        element = wait.until(EC.presence_of_element_located((By.XPATH, '//*[@data-testid="product-title"]')))
        html = driver.page_source
        driver.quit()

        soup = BeautifulSoup(html, 'html.parser')
        elements = soup.find_all('strong', {'data-testid': 'product-title'})
        
        for element in elements:
            with open(OUT_PATH+DATE+"publisher.txt", mode="a") as file:
                element = element.text.split("/")[0].lower()
                file.write(element+"\n")
        print("page"+str(num)+" complete")
    print("all complete")

searching(baseURL)