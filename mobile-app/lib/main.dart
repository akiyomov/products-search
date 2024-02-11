import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  Future<Map> fetchData(String barcode) async {
    const String baseUrl =
        'https://asadbeyy.pythonanywhere.com/get_product_info';
    final Map<String, String> queryParams = {'barcode': barcode};
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
      Map result = json.decode(utf8.decode(response.bodyBytes));
      if (result.containsKey('product_info')) {
        Map productInfo = result['product_info'];
        if (productInfo.containsKey('image') && productInfo['image'] != '') {
          setState(() {
            image_url = productInfo['image'];
          });
        }
        return productInfo;
      } else {
        return result;
      }
    } on SocketException {
      return {"Error": "No Internet connection 😑"};
    } on HttpException {
      return {"Error": "Couldn't find the post 😱"};
    } on FormatException {
      return {"Error": "Bad response format 👎"};
    } on Exception catch (e) {
      return {"Error": "$e"};
    }
  }

  String result = '';
  String image_url = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (image_url != '')
                Center(
                    child: Image.network(
                  image_url,
                  height: MediaQuery.sizeOf(context).height * 0.4,
                )),
              ElevatedButton(
                onPressed: () async {
                  var res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleBarcodeScannerPage(),
                      ));
                  setState(() {
                    if (res is String) {
                      result = res;
                      image_url = '';
                    }
                  });
                },
                child: const Text('Open Scanner'),
              ),
              Text('Barcode Result: $result'),
              if (result != '')
                FutureBuilder<Map>(
                  future: fetchData(result),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            // 키-값 값을 가져옵니다.
                            String key = snapshot.data?.keys.elementAt(index);
                            String value = (snapshot.data?[key]).toString();

                            // 텍스트 위젯을 사용하여 키-값 값을 표시합니다.
                            if (key != 'image') {
                              return Text(
                                "$key: $value",
                                style: GoogleFonts.nanumGothic(
                                    textStyle: const TextStyle(fontSize: 16)),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}
