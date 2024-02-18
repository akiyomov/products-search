import pandas as pd
import requests
from functools import lru_cache
import re

class ProductDatabase:
    """
    Manages product information from a CSV database, including retrieval of
    product details and boycott reasons based on company. Supports responses
    in both English and Korean.
    """
    
    # Define a mapping of companies to boycott reasons in both English and Korean
    BOYCOTT_REASONS = {
        "Coca-Cola": {
            "en": "Coca-Cola has a factory in the illegal Israeli settlement of Atarot, built in Occupied Palestine.",
            "kor": "코카콜라는 점령된 팔레스타인 지역, 아타로트의 불법 이스라엘 정착지에 공장을 가지고 있습니다."
        },
        "Nestle": {
            "en": "Nestlé, the world’s leading food company, holds a majority share in Osem, signaling a robust investment in Israel. With a continuous increase in financial support, Nestlé reaffirms its commitment to the Israeli economy and holds interests in various Israeli companies.",
            "kor": "세계 최대 식품 회사인 네슬레는 오셈에 대다수 지분을 보유하며 이스라엘에 대한 강력한 투자를 신호합니다. 지속적인 재정 지원 증가로 네슬레는 이스라엘 경제에 대한 약속을 재확인하며 다양한 이스라엘 회사에 관심을 가지고 있습니다."
        },
        "Starbucks": {
            "en": "Starbucks, led by CEO Howard Schultz, is recognized for its strong support of Israel. The company’s partnerships and initiatives align with Israel’s interests, and its presence extends to US military bases, including Guantanamo Bay.",
            "kor": "하워드 슐츠 CEO가 이끄는 스타벅스는 이스라엘에 대한 강력한 지원으로 인정받습니다. 회사의 파트너십과 이니셔티브는 이스라엘의 이익과 일치하며, 그 존재는 군타나모 베이를 포함한 미군 기지까지 확장됩니다."
        },
        "Pepsico": {
            "en": "Strauss and PepsiCo have cultivated a collaboration spanning over two decades. Originating in 1990 with the establishment of a salty snacks production site in Sderot, Israel, the partnership began under the umbrella of PepsiCo Frito-Lay. The two companies jointly own Strauss Frito Lay, with each holding a 50% stake. This collaboration includes a licensing agreement granting exclusive rights to manufacture and distribute various snacks in Israel.",
            "kor": "스트라우스와 펩시코는 20년 이상에 걸친 협력을 발전시켰습니다. 1990년 이스라엘 스데롯에 짠 간식 생산지를 설립하면서 시작된 파트너십은 펩시코 프리토레이의 주도 하에 시작되었습니다. 두 회사는 스트라우스 프리토 레이를 공동 소유하며 각각 50%의 지분을 보유합니다. 이 협력에는 이스라엘에서 다양한 간식을 제조 및 유통할 수 있는 독점권을 부여하는 라이선스 계약이 포함됩니다."
        }
    }

    def __init__(self, data_source):
        self.df = pd.read_csv(data_source, encoding='utf-8', dtype={'barcode': str}).set_index('barcode', drop=False)

    @staticmethod
    def validate_barcode(barcode):
        return re.match(r'^\d+$', barcode) is not None

    def get_by_barcode(self, barcode, language='en'):
        if not self.validate_barcode(barcode):
            return None

        try:
            product_info = self.df.loc[barcode]
        except KeyError:
            return None

        # Ensure product info is filtered for requested language
        product_info_filtered = {key: value for key, value in product_info.items() if key.endswith(language) or key == 'barcode'}
        product_info_filtered['image'] = self._get_image_url(barcode)

        # Handle company name in English for matching, but return reason in requested language
        company_name_english = product_info.get('company-en', '').lower()  # Assuming there's an 'company-en' column
        boycott_reason = self._match_company_to_boycott_reason(company_name_english, language)
        product_info_filtered['boycott_reason'] = boycott_reason

        return product_info_filtered

    def _match_company_to_boycott_reason(self, company_name, language):
        for company, reasons in self.BOYCOTT_REASONS.items():
            if company.lower() in company_name:
                return reasons.get(language)
        return None

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
