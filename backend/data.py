import requests
from pathlib import Path
import pandas as pd

def save_csv_with_specific_columns(url, destination_filename):
    """
    Downloads a CSV file from the given URL, filters specific columns,
    and saves it locally.

    Args:
    - url (str): The URL of the CSV file to download.
    - destination_filename (str): The filename to save the filtered CSV.

    Returns:
    - None
    """
    try:
        # Make an HTTP GET request to the provided URL
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for HTTP error status codes (4XX or 5XX)
        
        # Read the CSV content into a DataFrame
        df = pd.read_csv(url)
        
        # Filter DataFrame to retain only specific columns
        required_columns = ['company', 'productname', 'type', 'package', 'volumeml', 'country', 'boycott', 'certificate', 'barcode']
        df_filtered = df[required_columns]
        
        # Save the filtered DataFrame to a new CSV file
        df_filtered.to_csv(destination_filename, index=False)
        
        print(f"CSV file with specific columns saved as '{destination_filename}'")
    except (requests.RequestException, pd.errors.ParserError) as e:
        # Catch exceptions related to the HTTP request or DataFrame parsing
        print(f"Failed to download or process CSV file: {e}")

def main():
    # Example Google Sheets URL
    google_sheets_url = "https://docs.google.com/spreadsheets/d/1KfX6j5O_OkVP0LLlMf4j7F_IidxXMAVln9MBYv6JJkM/export?format=csv"
    
    # Output filename for the downloaded CSV file
    output_filename = "data.csv"

    # Download the CSV file using the provided URL and save it locally
    save_csv_with_specific_columns(google_sheets_url, output_filename)

if __name__ == "__main__":
    main()
