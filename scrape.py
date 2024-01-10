import requests
from bs4 import BeautifulSoup
import json
import re
# sample url = https://www.lotteon.com/search/search/search.ecn?render=search&platform=pc&q=%ED%8A%B8%EB%A0%88%EB%B9%84%20%ED%94%8C%EB%A0%88%EC%9D%B8%20300&mallId=1

samples = ['트레비 플레인 300', '트레비 플레인 500','칠성사이다 500']

r = requests.get('https://www.lotteon.com/search/search/search.ecn?render=search&platform=pc&q=%ED%8A%B8%EB%A0%88%EB%B9%84%20%ED%94%8C%EB%A0%88%EC%9D%B8%20300&mallId=1')

soup = BeautifulSoup(r.text, 'html.parser')

all_scripts = soup.find_all('script')


print(all_scripts[4]['initialData'])
