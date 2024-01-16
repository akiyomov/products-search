from flask import Flask, request, jsonify
import pandas as pd
from utils import get_by_barcode

app = Flask(__name__)

df = pd.read_csv('data.csv', encoding='utf-8')

@app.route('/get_product_info', methods=['GET'])
def get_product_info():
    barcode = request.args.get('barcode')
    if barcode is None:
        return jsonify({'error': 'Barcode parameter is missing'})

    product_info = get_by_barcode(df, barcode)
    print(product_info)
    
    if product_info is not None:
        # Use Flask's jsonify to handle JSON response
        return jsonify({'product_info': product_info})
    else:
        return jsonify({'error': 'Product information not found for the given barcode'})

# Remove the app.run() from here as it's not needed for deployment

# Ensuring this block runs only when the script is directly executed
if __name__ == '__main__':
    app.run(debug=False)