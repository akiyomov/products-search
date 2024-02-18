import pandas as pd
import requests
from functools import lru_cache
import re

class Product:
    def __init__(self, barcode, company, product, product_type, packaging, volume_ml, country, boycott, certificate, image_url, boycott_reason):
        self.barcode = barcode
        self.company = company
        self.product = product
        self.product_type = product_type
        self.packaging = packaging
        self.volume_ml = volume_ml
        self.country = country
        self.boycott = boycott
        self.certificate = certificate if pd.notna(certificate) else ""
        self.image_url = image_url
        self.boycott_reason = boycott_reason

class ProductDatabase:
    BOYCOTT_REASONS = {
        "Coca-Cola": {
            "en": "The “Coca-Cola” brand is a product of the “Coca-Cola Beverage Co., Ltd.”. The “Coca-Cola Beverage Co., Ltd.” has a factory in the illegal Israeli settlement of Atarot, built in Occupied Palestine.",
            "kor": "“코카-콜라” 브랜드는 “코카-콜라음료(주)”회사의 제품이며 “코카-콜라음료(주)” 점령된 팔레스타인에 건설된 이스라엘 불법 정착촌인 아타로트(Atarot)에 공장을 가지고 있다."
        },
        "Nestle": {
            "en": "Nestlé, the world’s leading food company, holds a majority share in Osem, signaling a robust investment in Israel. With a continuous increase in financial support, Nestlé reaffirms its commitment to the Israeli economy and holds interests in various Israeli companies.",
            "kor": "세계 최대 식품 회사인 네슬레는 오셈에 대다수 지분을 보유하며 이스라엘에 강력한 투자를 하고 있으며 지속적인 재정 지원으로 이스라엘 회사들을 도와주고 있다."
        },
        "Starbucks": {
            "en": "Starbucks, led by CEO Howard Schultz, is recognized for its strong support of Israel. The company’s partnerships and initiatives align with Israel’s interests, and its presence extends to US military bases, including Guantanamo Bay.",
            "kor": "하워드 슐츠 CEO가 이끄는 스타벅스는 이스라엘에 대한 강력한 지원으로 인정받고 있다. 회사의 파트너십과 이니셔티브는 이스라엘을 도와주는 것과 마찬가지이다."
        },
        "Pepsico": {
            "en": "Strauss and PepsiCo have cultivated a collaboration spanning over two decades. Originating in 1990 with the establishment of a salty snacks production site in Sderot, Israel, the partnership began under the umbrella of PepsiCo Frito-Lay. The two companies jointly own Strauss Frito Lay, with each holding a 50% stake. This collaboration includes a licensing agreement granting exclusive rights to manufacture and distribute various snacks in Israel.",
            "kor": "스트라우스와 펩시코는 20년 이상에 걸친 협력을 발전시켰습니다. 1990년 이스라엘 스데롯에 짠 간식 생산지를 설립하면서 시작된 파트너십은 펩시코 프리토레이의 주도 하에 시작되었습니다. 두 회사는 스트라우스 프리토 레이를 공동 소유하며 각각 50%의 지분을 보유합니다. 이 협력에는 이스라엘에서 다양한 간식을 제조 및 유통할 수 있는 독점권을 부여하는 라이선스 계약이 포함됩니다."
        }
    }

    def __init__(self, data_source):
        self.df = pd.read_csv(data_source, encoding='utf-8', dtype={'barcode': str})

    @staticmethod
    def validate_barcode(barcode):
        return re.match(r'^\d+$', barcode) is not None

    def get_by_barcode(self, barcode, language='en'):
        if not self.validate_barcode(barcode):
            return None

        try:
            product_row = self.df.loc[self.df['barcode'] == barcode].iloc[0]
        except IndexError:  # If no matching product is found
            return None

        lang_suffix = "-kor" if language == 'kor' else "-en"
        boycott_reason = self._get_boycott_reason(product_row['company-en'], language)  # Fetching based on English name as key

        product = Product(
            barcode=barcode,
            company=product_row[f'company{lang_suffix}'],
            product=product_row[f'product{lang_suffix}'],
            product_type=product_row[f'type{lang_suffix}'],
            packaging=product_row[f'package{lang_suffix}'],
            volume_ml=product_row['volume-ml'],
            country=product_row[f'country{lang_suffix}'],
            boycott=product_row['boycott'],
            certificate=product_row.get('certificate', ''),
            image_url=self._get_image_url(barcode),
            boycott_reason=boycott_reason
        )

        return product

    def _get_boycott_reason(self, company_name, language):
        for company, reasons in self.BOYCOTT_REASONS.items():
            if company.lower() in company_name.lower():
                return reasons.get(language, "")
        return ""

    @staticmethod
    @lru_cache(maxsize=1024)
    def _image_exists(bucket_url):
        try:
            response = requests.head(bucket_url, timeout=5)
            return response.status_code == 200
        except requests.RequestException:
            return False

    def _get_image_url(self, barcode):
        image_url = f'https://storage.googleapis.com/product-search-bds/images/{barcode}.jpg'
        if self._image_exists(image_url):
            return image_url
        return 'https://storage.googleapis.com/product-search-bds/images/default.png'
