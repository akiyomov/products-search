import 'dart:io';

import 'package:check_barcode/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale/locale_keys.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KO')],
      path: 'assets/translations',
      // <-- change the path of the translation files
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('en', 'US'),
      saveLocale: true,
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDS in Korea',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map> fetchData(String barcode, {String lang = 'en'}) async {
    const String baseUrl = 'http://211.112.85.26:150/get_product_info';
    final Map<String, String> queryParams = {
      'barcode': barcode,
      'language': lang
    };
    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final Map<String, String> headers = {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*'
    };
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) {
        throw HttpException('${response.statusCode}');
      }
      Map<String, dynamic> result =
      json.decode(utf8.decode(response.bodyBytes));
      if (result.containsKey('error')) {
        return Future.error(result);
      }
      Response res = Response.fromJson(result);
      ProductInfo? data = res.productInfo;
      setState(() {
        productInfo = data!;
      });
      return {"success": true};
    } on SocketException {
      return Future.error({"error": "No Internet connection 😑"});
    } on HttpException {
      return Future.error({"error": "Couldn't find the post 😱"});
    } on FormatException {
      return Future.error({"error": "Bad response format 👎"});
    } on Exception catch (e) {
      return Future.error({"error": "$e"});
    }
  }

  String barcode = ''; // 8801094202804
  late ProductInfo productInfo;

  @override
  void initState() {
    productInfo = ProductInfo();
    super.initState();
  }

  Future<void> openScanner() async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ));
    setState(() {
      if (res is String) {
        barcode = res;
        productInfo = ProductInfo();
      }
    });
  }

  Color hexToColor(String code) {
    final int colorInt = int.parse(code.substring(1), radix: 16);
    return Color(colorInt + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('#666666'),
      appBar: AppBar(
        backgroundColor: hexToColor('#666666'),
        actions: [
          TextButton(
            onPressed: () {
              // Add your action here
              if (context.locale.toString() == 'en_US') {
                context.setLocale(const Locale('ko', 'KO'));
              } else {
                context.setLocale(const Locale('en', 'US'));
              }
              setState(() {});
            },
            child: Text(
              LocaleKeys.current_lang.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productInfo.imageUrl != null)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    productInfo.imageUrl!,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.45,
                    fit: BoxFit.fitHeight,
                  ),
                )),
          SizedBox(height: 30),
          if (barcode != '')
            FutureBuilder<Map>(
              future: fetchData(barcode, lang: context.locale.toString()[2]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "${productInfo.product ?? ''} ",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 26),
                            children: <TextSpan>[
                              TextSpan(text: productInfo.package ?? '',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 26)),
                              if(productInfo.volumeMl != null)
                                TextSpan(text: " ${productInfo.volumeMl} ml",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 26))
                            ],
                          ),
                        ),
                        if(productInfo.boycottReason != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(productInfo.boycottReason!,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        if(productInfo.boycott == 'country' || productInfo.boycottReason == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: RichText(text: TextSpan(
                                text: LocaleKeys.country1.tr(),
                                children: <TextSpan>[
                                  TextSpan(text: productInfo.company!,
                                      style: const TextStyle(color: Colors.red)),
                                  TextSpan(text: LocaleKeys.country2.tr()),
                                  TextSpan(text: productInfo.country!,
                                      style: const TextStyle(color: Colors.red)),
                                  TextSpan(text: LocaleKeys.country3.tr())
                                ]
                            )),
                          ),
                        if (productInfo.boycott == 'company' ||
                            productInfo.boycott == 'country')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(LocaleKeys.boycott_company.tr(),
                                style: const TextStyle(color: Colors.yellow)),
                          ),
                        if (productInfo.boycott ==
                            'exclusive_contract_with_origin')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(LocaleKeys.exclusive_contract.tr(),
                                style: const TextStyle(color: Colors.yellow)),
                          ),
                        if (productInfo.boycott == 'not')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: RichText(text: TextSpan(
                                text: LocaleKeys.company1.tr(),
                                children: <TextSpan>[
                                  TextSpan(text: productInfo.company!,
                                      style: const TextStyle(color: Colors.red)),
                                  TextSpan(text: LocaleKeys.company2.tr()),
                                ]
                            )),
                          ),
                        if (productInfo.boycott == 'not')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(LocaleKeys.not_boycotted.tr(),
                                style: const TextStyle(color: Colors.yellow, fontSize: 18)),
                          ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}', style: const TextStyle(color: Colors.white),));
                }
                // By default, show a loading spinner.
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
            ),
          Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(color: Colors.red, width: 2)
                  ),
                  child: TextButton.icon(
                      style:
                      TextButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () => openScanner(),
                      icon: const Icon(Icons.barcode_reader,
                          color: Colors.black, size: 36),
                      label: Text(LocaleKeys.open_scan.tr(),
                          style: TextStyle(fontSize: 24, color: Colors.black))),
                ),
              ),
              const SizedBox(height: 20),
              Text(LocaleKeys.info_text.tr(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}
