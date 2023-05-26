import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'coin_data.dart';
import 'dart:io' show Platform;

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'AUD';
  Map<String, String> cryptoPrices = {};
  bool isWaiting = false;

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in CoinData().currenciesList) {
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropdownItems.add(newItem);
    }

    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedCurrency = value!;
          getData();
        });
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> pickerItems = [];
    for (String currency in CoinData().currenciesList) {
      pickerItems.add(Text(currency));
    }

    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        print(selectedIndex);
        getData();
      },
      children: pickerItems,
    );
  }

  Future<void> getData() async {
    setState(() {
      isWaiting = true;
    });

    try {
      var coinData = await CoinData().getCoinData(selectedCurrency);
      setState(() {
        cryptoPrices = coinData;
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      isWaiting = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CryptoCard(
            bitCoinRate: isWaiting ? '?' : cryptoPrices['BTC'],
            selectedCurrency: selectedCurrency,
            cryptocurrency: 'BTC',
          ),
          CryptoCard(
            bitCoinRate: isWaiting ? '?' : cryptoPrices['ETH'],
            selectedCurrency: selectedCurrency,
            cryptocurrency: 'ETH',
          ),
          CryptoCard(
            bitCoinRate: isWaiting ? '?' : cryptoPrices['LTC'],
            selectedCurrency: selectedCurrency,
            cryptocurrency: 'LTC',
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  const CryptoCard({
    Key? key,
    required this.bitCoinRate,
    required this.selectedCurrency,
    required this.cryptocurrency,
  }) : super(key: key);

  final String? bitCoinRate; // Updated to allow nullable values
  final String selectedCurrency;
  final String cryptocurrency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            bitCoinRate != null
                ? '1 $cryptocurrency = $bitCoinRate $selectedCurrency'
                : 'Loading...', // Show loading message if bitCoinRate is null
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
