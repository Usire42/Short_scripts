import requests
import os
import csv
from datetime import datetime as dt
import bs4
import re
import time

DATE_FORMAT = '%d.%m.%Y %H:%M:%S'
URL = "https://markets.businessinsider.com/commodities/gold-price"

def golden_price(URL) -> float:
    r = requests.get(URL)
    soup = bs4.BeautifulSoup(r.text, 'html.parser')

    price = soup.find_all('span', {'class':'price-section__current-value'})
    price = str(price)
    price = float(re.findall("\d*\.\d*", price)[0])

    return price

def write_csv_data(URL):
    price = golden_price(URL)
    pathway = 'c:/Users/Fedorko/PycharmProjects/test_engeto'
    os.chdir(pathway)
    if 'gold_prize.csv' in os.listdir():
        mode = 'a'
    else:
        mode = 'w'

    with open('gold_prize.csv', mode, newline='') as file:
        writer = csv.writer(file)
        writer.writerow([price, dt.now().strftime(DATE_FORMAT)])

if __name__ == '__main__':
    for _ in range(10):
        write_csv_data(URL)
        time.sleep(0.1)
