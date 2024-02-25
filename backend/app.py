from flask import Flask, request, jsonify
from backend.utils import ProductDatabase
from werkzeug.exceptions import BadRequest

app = Flask(__name__)
product_db = ProductDatabase('backend/sample.csv')  # Ensure this path points to your actual CSV file

@app.route('/get_product_info', methods=['GET'])
def get_product_info():
    barcode = request.args.get('barcode')
    language = request.args.get('language', 'en')  # Default to English

    if not barcode or not ProductDatabase.validate_barcode(barcode):
        raise BadRequest('Invalid or missing barcode parameter')

    product = product_db.get_by_barcode(barcode, language)
    if product:
        # Serialize the Product object to a JSON-friendly format
        product_info = {
            "barcode": product.barcode,
            "company": product.company if product.company else None,
            "product": product.product if product.product else None,
            "type": product.product_type if product.product_type else None,
            "package": product.packaging if product.packaging else None,
            "volume_ml": product.volume_ml if product.volume_ml else None,
            "country": product.country if product.country else None,
            "boycott": product.boycott if product.boycott else None,
            "certificate": product.certificate if product.certificate else None,
            "image_url": product.image_url if product.image_url else None,
            "boycott_reason": product.boycott_reason if product.boycott_reason else None,
        }
        return jsonify({'product_info': product_info})
    else:
        return jsonify({'error': 'Product information not found for the given barcode'}), 404

@app.errorhandler(BadRequest)
def handle_bad_request(e):
    return jsonify({'error': 'Bad request', 'message': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True, port=8080)
