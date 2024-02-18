# Product Information Retrieval App

This Flask-based application allows users to retrieve product information by providing a barcode as a parameter in the API endpoint.

## Overview

The application uses a CSV file (`sample.csv`) containing product information. When a user makes a GET request to the `/get_product_info` endpoint with a `barcode` parameter, the application fetches the corresponding product information from the CSV file and returns it as a JSON response.

## Installation and Setup

1. Clone the repository or download the application files.

2. Ensure you have Python installed on your system.

3. Install the required dependencies using pip:

   ```bash
   pip install -r requirements.txt
   ```

4. Place your product information in a CSV file named `data.csv` in the same directory as `app.py`. Ensure the CSV file contains columns relevant to product information such as `barcode`, `name`, `description`, etc.

## Usage

1. Start the Flask application by running the `app.py` file.

   ```bash
   python app.py
   ```

2. Once the application is running, you can make GET requests to retrieve product information using the `/get_product_info` endpoint.

   Example:

   ```http
   GET /get_product_info?barcode=1234567890
   ```

   Replace `1234567890` with the barcode you want to search for. The application will respond with the corresponding product information in JSON format.

## API Endpoint

- `/get_product_info`

  - Method: GET
  - Parameters:
    - `barcode` (required): The barcode of the product to retrieve information for.
    - `language` (default: en) set language(en/kor)

Example Request:

  ```sh
 http://0.0.0.0:5000/get_product_info?barcode=8801094202804&language=en
 http://0.0.0.0:5000/get_product_info?barcode=8801094202804&language=kor
  ```

Example Response:

  ```json
{
  "product_info": {
    "barcode": "8801094202804",
    "boycott": "company",
    "boycott_reason": "The “Coca-Cola” brand is a product of the “Coca-Cola Beverage Co., Ltd.”. The “Coca-Cola Beverage Co., Ltd.” has a factory in the illegal Israeli settlement of Atarot, built in Occupied Palestine.",
    "certificate": null,
    "company": "Coca-Cola Korea Co., Ltd.",
    "country": "South Korea",
    "image_url": "https://storage.googleapis.com/product-search-bds/images/8801094202804.jpg",
    "package": "pet",
    "product": "Sprite",
    "type": "Sparkling water",
    "volume_ml": "1000"
}
}
{
  "product_info": {
    "barcode": "8801094202804",
    "boycott": "company",
    "boycott_reason": "“코카-콜라” 브랜드는 “코카-콜라음료(주)”회사의 제품이며 “코카-콜라음료(주)” 점령된 팔레스타인에 건설된 이스라엘 불법 정착촌인 아타로트(Atarot)에 공장을 가지고 있다.",
    "certificate": null,
    "company": "한국코카콜라(유), 코카-콜라음료(주)",
    "country": "대한민국",
    "image_url": "https://storage.googleapis.com/product-search-bds/images/8801094202804.jpg",
    "package": "패트",
    "product": "스프라이트",
    "type": "탄산음료",
    "volume_ml": "1000"
}
}
  ```

## Demo Request

You can make a demo request to the live endpoint:

Sample request:

```http
GET http://211.112.85.26:150/get_product_info?barcode=8801094202804&language=en
```

#### Expected Response

```json
{
  "product_info": {
    "barcode": "8801094202804",
    "boycott": "company",
    "boycott_reason": "The “Coca-Cola” brand is a product of the “Coca-Cola Beverage Co., Ltd.”. The “Coca-Cola Beverage Co., Ltd.” has a factory in the illegal Israeli settlement of Atarot, built in Occupied Palestine.",
    "certificate": null,
    "company": "Coca-Cola Korea Co., Ltd.",
    "country": "South Korea",
    "image_url": "https://storage.googleapis.com/product-search-bds/images/8801094202804.jpg",
    "package": "pet",
    "product": "Sprite",
    "type": "Sparkling water",
    "volume_ml": "1000"
}
```
