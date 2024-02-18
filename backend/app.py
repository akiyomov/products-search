from flask import Flask, request, jsonify
from backend.utils import ProductDatabase
from werkzeug.exceptions import BadRequest

app = Flask(__name__)
product_db = ProductDatabase('backend/sample.csv')  # Update with the actual path to your CSV file

@app.route('/get_product_info', methods=['GET'])
def get_product_info():
    barcode = request.args.get('barcode')
    language = request.args.get('language', 'en')  # Default to English
    print(barcode,language)
    if not barcode or not ProductDatabase.validate_barcode(barcode):
        raise BadRequest('Invalid or missing barcode parameter')

    product_info = product_db.get_by_barcode(barcode, language)
    if product_info:
        return jsonify({'product_info': product_info})
    else:
        return jsonify({'error': 'Product information not found for the given barcode'}), 404

@app.errorhandler(BadRequest)
def handle_bad_request(e):
    return jsonify({'error': 'Bad request', 'message': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
