import unittest
from concurrent.futures import ThreadPoolExecutor
from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        app.testing = True
        self.client = app.test_client()

    def test_get_product_info_with_existing_barcode(self):
        # Test with an existing barcode value
        response = self.client.get('/get_product_info?barcode=8801097160064')
        self.assertEqual(response.status_code, 200)
        expected_result = '{"company": "동아오츠카(주)", "productname": "데미소다   애플", "type": "탄산음료", "package": "캔", "volumeml": "250", "country": "대한민국", "boycott": "NOT", "certificate": "비건", "barcode": 8801097160064}'
        self.assertEqual(response.data.decode('utf-8'), expected_result)

    def test_get_product_info_with_missing_barcode_parameter(self):
        # Test without providing the barcode parameter
        response = self.client.get('/get_product_info')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'{"error":"Barcode parameter is missing"}', response.data)

    def test_get_product_info_with_nonexistent_barcode(self):
        # Test with a barcode that does not exist in the dataset
        response = self.client.get('/get_product_info?barcode=999999')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'{"error":"Product information not found for the given barcode"}', response.data)

    def test_multiple_requests_concurrently(self):
        # Test sending multiple requests concurrently
        barcodes = ['8801097160064', '8801234567890', '8801987654321']  # Add more barcode values as needed
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = [executor.submit(self.client.get, f'/get_product_info?barcode={barcode}') for barcode in barcodes]

            for future in futures:
                response = future.result()
                self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()
