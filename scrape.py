import os
import requests
import re
import pandas as pd
from urllib.parse import quote
import random
import time

# Load the CSV file into a pandas DataFrame
data = pd.read_csv('data.csv')
headers = {
    "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.19582"
}

# Example url
url = "https://www.lotteon.com/search/search/search.ecn?render=search&platform=pc&q={}{}&mallId=1"

def update_volume_format(volume):
    if '*' in volume:  # Format like '250*6'
        extracted_volume = int(volume.split('*')[0])
        if extracted_volume < 1000:
            return ''
        return str(extracted_volume)
    elif volume.isdigit():  # Format like '1800', '1500', '1000'
        volume_ml = int(volume)
        if volume_ml < 1000:
            return ''
        return f"{volume_ml / 1000}L"
    else:
        return volume

searchs = data['productname'].tolist()
barcodes = data['barcode'].tolist()
volume = data['volumeml'].tolist()
volume = [update_volume_format(v) for v in volume]

for search, vol, barcode in zip(searchs, volume, barcodes):
    encoded_query = quote(search, safe='')

    search_url = url.format(encoded_query, vol)
    # print(search_url)

    response = requests.get(search_url, headers=headers)
    # print("Status code: ", response.status_code)

    text = response.text

    pattern = re.compile(r'"productImage":"(https://[^"]+/LO\d+_\d+_\d+\.jpg[^"]*)')
    matches = pattern.search(text)

    if matches:
        product_image_url = matches.group(1)
        print(product_image_url)
        
        image_content = requests.get(product_image_url).content

        image_filename = f'images/{barcode}.jpg'
        with open(image_filename, 'wb') as f:
            f.write(image_content)
        print(f"Image saved as {image_filename}")
    else:
        print("No match found.")

    # Random delay between 1 to 3 seconds
    delay = random.randint(1, 3)
    print(f"Waiting for {delay} seconds before the next request...")
    time.sleep(delay)
