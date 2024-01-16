import json
import pandas as pd

# sample bucket url https://storage.googleapis.com/product-search-bds/images/8801037087543.jpg

def get_by_barcode(df, barcode):
    """
    Returns product information from the given DataFrame that matches the given barcode.
    
    Args:
    - df (DataFrame): The DataFrame to search.
    - barcode (str or int): The barcode to search for.
    
    Returns:
    - str: Product information matching the given barcode in JSON format.
    """
    if not isinstance(barcode, int):
        if str(barcode).isdigit():
            barcode = int(barcode)
    columns_to_select = ['company', 'productname', 'type', 'package', 'volumeml', 'country', 'boycott', 'certificate', 'barcode']
    filtered_row = df[df["barcode"] == barcode][columns_to_select]
    if len(filtered_row) > 0:
        product_info = filtered_row.iloc[0].to_dict()
        # add image url to the product info
        product_info['image'] = f'https://storage.googleapis.com/product-search-bds/images/{barcode}.jpg'
        return product_info
    else:
        return None  # Return None if barcode is not found in the DataFrame or DataFrame is empty

