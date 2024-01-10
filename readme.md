# Product Information Retrieval App

This Flask-based application allows users to retrieve product information by providing a barcode as a parameter in the API endpoint.

## Overview

The application uses a CSV file (`data.csv`) containing product information. When a user makes a GET request to the `/get_product_info` endpoint with a `barcode` parameter, the application fetches the corresponding product information from the CSV file and returns it as a JSON response.

## Installation and Setup

1. Clone the repository or download the application files.

2. Ensure you have Python installed on your system.

3. Install the required dependencies using pip:

   ```bash
   pip install Flask pandas
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

  Example Request:

  ```http
  GET /get_product_info?barcode=1234567890
  ```

  Example Response:

  ```json
  {
      "barcode": "1234567890",
      "name": "Product Name",
      "description": "Product Description",
      ...
  }
  ```

## Demo Request

You can make a demo request to the live endpoint:

Endpoint: [https://asadbeyy.pythonanywhere.com/get_product_info](https://asadbeyy.pythonanywhere.com/get_product_info)

Sample request:

```http
GET https://asadbeyy.pythonanywhere.com/get_product_info?barcode=8801097160064
```

#### Expected Response

```json
{
  "company": "동아오츠카(주)",
  "productname": "데미소다   애플",
  "type": "탄산음료",
  "package": "캔",
  "volumeml": "250",
  "country": "대한민국",
  "boycott": "NOT",
  "certificate": "비건",
  "barcode": 8801097160064
}
```
