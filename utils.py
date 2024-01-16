import pandas as pd
import requests

def image_exists(bucket_url):
    """
    Checks if the image exists in the specified bucket using an HTTP GET request.

    Args:
    - bucket_url (str): The URL of the image in the bucket.

    Returns:
    - bool: True if the image exists, False otherwise.
    """
    response = requests.head(bucket_url)
    return response.status_code == 200

def get_by_barcode(df, barcode):
    """
    Returns product information from the given DataFrame that matches the given barcode.

    Args:
    - df (DataFrame): The DataFrame to search.
    - barcode (str or int): The barcode to search for.

    Returns:
    - dict: Product information matching the given barcode.
    """
    if not isinstance(barcode, int):
        if str(barcode).isdigit():
            barcode = int(barcode)
    columns_to_select = ['company', 'productname', 'type', 'package', 'volumeml', 'country', 'boycott', 'certificate', 'barcode']
    filtered_row = df[df["barcode"] == barcode][columns_to_select]
    if len(filtered_row) > 0:
        product_info = filtered_row.iloc[0].to_dict()

        # Replace NaN values with None
        product_info = {key: value if pd.notna(value) else None for key, value in product_info.items()}

        # Construct image URL and check if the image exists
        image_url = f'https://storage.googleapis.com/product-search-bds/images/{barcode}.jpg'
        if image_exists(image_url):
            product_info['image'] = image_url
        else:
            # If the image can't be found, use the default image URL
            product_info['image'] = 'https://storage.googleapis.com/product-search-bds/images/default.png'

        return product_info
    else:
        return None  # Return None if the barcode is not found in the DataFrame or DataFrame is empty
