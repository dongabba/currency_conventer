import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Currency Converter",
      home: DailyCurrency(),
    );
  }
}


class DailyCurrency extends StatefulWidget {
  @override
  _DailyCurrencyState createState() => _DailyCurrencyState();
}

class _DailyCurrencyState extends State<DailyCurrency> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
        body: _displayCurrency(),
    );
  }
}

Widget _displayCurrency() {
  return new Container(
      color: Colors.white,
      child: FutureBuilder<List>(
        future: Network().fetchCurrency(),
        builder: (BuildContext context, AsyncSnapshot<List> snap) {
          if (snap.hasError) {
            return const Center(
              child: Text('An error has occured'),
            );
          } else {
            if (snap.hasData) {
              return ListView.builder(
                itemCount: snap.data!.length,
                itemBuilder: (BuildContext context, int i) {
                  return new CurrencyItem(
                      snap.data![i].id,
                      snap.data![i].numCode,
                      snap.data![i].charCode,
                      snap.data![i].nominal,
                      snap.data![i].name,
                      snap.data![i].value,
                      snap.data![i].previousVal,
                      snap.data![i]._isFavorite = false,
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        },
      )
  );
}

class CurrencyItem extends StatelessWidget {
  final String id;
  final String numCode;
  final String charCode;
  final int nominal;
  final String name;
  final double value;
  final double previousVal;
  final bool _isFavorite;

  CurrencyItem(this.id, this.numCode, this.charCode, this.nominal, this.name, this.value, this.previousVal, this._isFavorite);

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$value RUB за $nominal $charCode',
                      style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                          '$previousVal',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          )
                      ),
                      IconDr(previousVal, value),
                    ],
                  )
                ],
              ),
            ),
            trailing: Icon(
              Icons.star,
              color: Colors.yellow,
            )
          ],
        ),
      );
  }
}
Widget IconDr (double val1, double val2) {
  if (val2 - val1 < 0) {
    return Icon(
      Icons.arrow_downward,
      color: Colors.red,
      size: 13,
    );
  } else {
    return Icon(
      Icons.arrow_upward,
      color: Colors.green,
      size: 13,
    );
  }
}
class Currency {
  String id;
  String numCode;
  String charCode;
  int nominal;
  String name;
  double value;
  double previousVal;

  Currency({required this.id, required this.numCode, required this.charCode, required this.nominal, required this.name, required this.value, required this.previousVal});
}

class Network {
  String url =
      "https://www.cbr-xml-daily.ru/daily_json.js";
  List<Currency> currency = <Currency>[];

  Future<List<Currency>> fetchCurrency() async {
    final res = await http.get(Uri.parse(url));
    final jsonData = json.decode(res.body);
    final valute = jsonData['Valute'];
    final data = valute.values;
    for (var h in data) {
      Currency cur = new Currency(
          id: h['ID'] as String,
          numCode: h['NumCode'] as String,
          charCode: h['CharCode'] as String,
          nominal: h['Nominal'] as int,
          name: h['Name'] as String,
          value: h['Value'] as double,
          previousVal: h['Previous'] as double);
      currency.add(cur);
    }
    print("Status code: ${res.statusCode}");

    return currency;
  }
}