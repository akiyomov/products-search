import pandas as pd
import requests
from functools import lru_cache
import re

class ProductDatabase:
    """
    A class to manage product information from a CSV database, allowing for retrieval
    of product details including boycott reasons based on the company.
    """
    # Define a mapping of companies to boycott reasons
    BOYCOTT_REASONS = {
        "Coca-Cola": "Coca-Cola has a factory in the illegal Israeli settlement of Atarot, built in Occupied Palestine.",
        "Nestle": "Nestlé, the world’s leading food company, holds a majority share in Osem, signaling a robust investment in Israel. With a continuous increase in financial support, Nestlé reaffirms its commitment to the Israeli economy and holds interests in various Israeli companies.",
        "Starbucks": "Starbucks, led by CEO Howard Schultz, is recognized for its strong support of Israel. The company’s partnerships and initiatives align with Israel’s interests, and its presence extends to US military bases, including Guantanamo Bay.",
        "Pepsico": "Strauss and PepsiCo have cultivated a collaboration spanning over two decades. Originating in 1990 with the establishment of a salty snacks production site in Sderot, Israel, the partnership began under the umbrella of PepsiCo Frito-Lay. The two companies jointly own Strauss Frito Lay, with each holding a 50% stake. This collaboration includes a licensing agreement granting exclusive rights to manufacture and distribute various snacks in Israel."
    }

    def __init__(self, data_source):
        """
        Initializes the ProductDatabase with product data from the specified CSV file.

        Parameters:
        - data_source (str): The path to the CSV file containing product data.
        """
        self.df = pd.read_csv(data_source, encoding='utf-8', dtype={'barcode': str}).set_index('barcode', drop=False)
    
    @staticmethod
    def validate_barcode(barcode):
        """
        Validates the barcode against a regular expression to ensure it is numeric.

        Parameters:
        - barcode (str): The barcode to validate.

        Returns:
        - bool: True if the barcode is valid, False otherwise.
        """
        return re.match(r'^\d+$', barcode) is not None
    
    def get_by_barcode(self, barcode, language='en'):
        """
        Retrieves product information for a given barcode and language, including boycott reasons if applicable.

        Parameters:
        - barcode (str): The barcode of the product to find.
        - language (str): The language of the product information ('en' for English, 'kor' for Korean).

        Returns:
        - dict: A dictionary containing product information, or None if not found.
        """
        if not self.validate_barcode(barcode):
            return None

        try:
            product_info = self.df.loc[barcode]
        except KeyError:
            return None

        # Filter and restructure the product information based on the requested language
        columns_suffix = '-kor' if language == 'kor' else '-en'
        product_info_filtered = {
            key.replace(columns_suffix, ''): value
            for key, value in product_info.to_dict().items()
            if columns_suffix in key or key == 'barcode'
        }

        # Generate the image URL for the product
        product_info_filtered['image'] = self._get_image_url(barcode)
        
        # Initialize boycott reason as None
        boycott_reason = None
        # Extract the company name for the product and check for boycott reasons
        company_name = product_info_filtered.get('company', '').lower()
        for key_company, reason in self.BOYCOTT_REASONS.items():
            if key_company.lower() in company_name:
                boycott_reason = reason
                break
        
        # Add boycott reason if applicable
        product_info_filtered['boycott_reason'] = boycott_reason

        return product_info_filtered
    
    @staticmethod
    @lru_cache(maxsize=1024)
    def _image_exists(bucket_url):
        """
        Checks if an image exists at the specified bucket URL using an HTTP HEAD request.

        Parameters:
        - bucket_url (str): The URL of the image to check.

        Returns:
        - bool: True if the image exists, False otherwise.
        """
        try:
            response = requests.head(bucket_url, timeout=5)
            return response.status_code == 200
        except requests.RequestException:
            return False
    
    def _get_image_url(self, barcode):
        """
        Constructs the URL for a product's image based on its barcode.

        Parameters:
        - barcode (str): The barcode of the product.

        Returns:
        - str: The URL to the product's image.
        """
        image_url = f'https://storage.googleapis.com/product-search-bds/images/{barcode}.jpg'
        if self._image_exists(image_url):
            return image_url
        return 'https://storage.googleapis.com/product-search-bds/images/default.png'
