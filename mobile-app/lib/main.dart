import 'dart:io';

import 'package:check_barcode/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'locale/locale_keys.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
      title: 'Human Lives',
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
    // const String baseUrl = 'http://211.112.85.26:150/get_product_info';
    const String baseUrl = 'http://58.232.173.100:5000/get_product_info';
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
      if (response.statusCode != 200 && response.statusCode != 404) {
        throw HttpException('${response.statusCode}');
      }
      Map<String, dynamic> result =
          json.decode(utf8.decode(response.bodyBytes));
      if (result.containsKey('error')) {
        productInfo = ProductInfo();
        return Future.error(result);
      }
      Response res = Response.fromJson(result);
      ProductInfo? data = res.productInfo;
      productInfo = data!;
      return {"success": true};
    } on SocketException {
      productInfo = ProductInfo();
      return Future.error({"error": "No Internet connection 😑"});
    } on HttpException {
      productInfo = ProductInfo();
      return Future.error({"error": "Couldn't find the post 😱"});
    } on FormatException {
      productInfo = ProductInfo();
      return Future.error({"error": "Bad response format 👎"});
    } on Exception catch (e) {
      productInfo = ProductInfo();
      return Future.error({"error": "$e"});
    }
  }

  String barcode = ''; // 8801094202804
  late Future<Map> apiResult;
  late ProductInfo productInfo;

  @override
  void initState() {
    super.initState();
    productInfo = ProductInfo();
    FlutterNativeSplash.remove();
  }

  Future<void> openScanner() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        )).then((val) async {
      if (val != null && val is String) {
        setState(() {
          barcode = val;
          productInfo = ProductInfo();
        });
        apiResult =
            fetchData(val, lang: context.locale.toString().substring(0, 2));
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
          if (barcode != '')
            FutureBuilder<Map>(
              future: apiResult,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              productInfo.imageUrl!,
                              height: MediaQuery.of(context).size.height * 0.35,
                              fit: BoxFit.fitHeight,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Product title >>>
                        AutoSizeText.rich(
                          TextSpan(
                            text: "${productInfo.product ?? ''} ",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 26),
                            children: <TextSpan>[
                              TextSpan(
                                  text: productInfo.package ?? '',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 26)),
                              if (productInfo.volumeMl != null)
                                TextSpan(
                                    text: " ${productInfo.volumeMl} ml",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 26))
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Boycott reason >>>
                        if (productInfo.boycottReason != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AutoSizeText(
                              productInfo.boycottReason!,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // Boycott is equal 'country' and reason is null >>>>
                        if (productInfo.boycott == 'country' &&
                            productInfo.boycottReason == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AutoSizeText.rich(
                                TextSpan(
                                    text: LocaleKeys.country1.tr(),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: productInfo.company!,
                                          style: const TextStyle(
                                              color: Colors.red)),
                                      TextSpan(text: LocaleKeys.country2.tr()),
                                      TextSpan(
                                          text: productInfo.country!,
                                          style: const TextStyle(
                                              color: Colors.red)),
                                      TextSpan(text: LocaleKeys.country3.tr())
                                    ]),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                          ),
                        // Boycott is equal 'company' >>>>
                        if (productInfo.boycott == 'company')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AutoSizeText(LocaleKeys.boycott_company.tr(),
                                style: const TextStyle(color: Colors.yellow),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                          ),
                        // Boycott is equal 'country' >>>>
                        if (productInfo.boycott == 'country')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AutoSizeText(LocaleKeys.boycott_country.tr(),
                                style: const TextStyle(color: Colors.yellow),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                          ),
                        // Boycott is equal 'exclusive_contract_with_origin' >>
                        if (productInfo.boycott ==
                            'exclusive_contract_with_origin')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AutoSizeText(
                                LocaleKeys.exclusive_contract.tr(),
                                style: const TextStyle(color: Colors.yellow),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                        // Boycott is equal 'not' >>>
                        if (productInfo.boycott == 'not')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: AutoSizeText.rich(
                                TextSpan(
                                    text: LocaleKeys.company1.tr(),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: productInfo.company!,
                                          style: const TextStyle(
                                              color: Colors.red)),
                                      TextSpan(text: LocaleKeys.company2.tr()),
                                    ]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                        if (productInfo.boycott == 'not')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AutoSizeText(LocaleKeys.not_boycotted.tr(),
                                style: const TextStyle(
                                    color: Colors.yellow, fontSize: 18),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                        child: Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    )),
                  );
                }
                // By default, show a loading spinner.
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              },
            ),
          Column(
            children: [
              const SizedBox(height: 20),
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
