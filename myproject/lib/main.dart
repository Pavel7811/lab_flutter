import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Страны и деньги',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Главная'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List sortMethods;
  bool isDown1 = false;

  Future getUserData(bool isDown) async {
    var response = await http
        .get(Uri.https('countriesnow.space', 'api/v0.1/countries/currency'));
    var jsonData = jsonDecode(response.body);
    List<Coin> coins = [];
    var json = jsonData['data'];

    for (var u in json) {
      Coin coin = Coin(u["name"], u["currency"]);

      coins.add(coin);
    }
    List<Coin> sortedCoin = [];
    sortedCoin = coins;
    sortedCoin.sort((a, b) => a.name.compareTo(b.name));
    final sortedItems = isDown ? sortedCoin : sortedCoin.reversed.toList();
    return sortedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Data'),
      ),
      body: Column(
        children: [
          TextButton.icon(
            icon: const RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.compare_arrows, size: 28),
            ),
            label: Text(
              isDown1 ? 'A/Z' : 'Z/A',
              style: const TextStyle(fontSize: 16),
            ),
            onPressed: () => setState(() => isDown1 = !isDown1),
          ),
          Expanded(
            child: FutureBuilder(
                future: getUserData(isDown1),
                builder: (context, AsyncSnapshot coin) {
                  if (coin.data == null) {
                    return const Center(
                      child: Text('Loading...'),
                    );
                  }
                  return ListView.builder(
                      itemCount: coin.data.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          title: Text(coin.data[i].name),
                          subtitle: Text(coin.data![i].currency),
                        );
                      });
                }),
          )
        ],
      ),
    );
  }
}

class Coin {
  final String name, currency;
  Coin(this.name, this.currency);
}