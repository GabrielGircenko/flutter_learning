import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      title: "Stateful App Example",
      home: FavoriteCity(),
    ));

class FavoriteCity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoriteCityState();
  }
}

class _FavoriteCityState extends State<FavoriteCity> {
  String nameCity = "";
  var _currencies = ["Rupees", "Dollar", "Pounds", "Others"];
  var _currentItemSelected = "Rupees";

  @override
  Widget build(BuildContext context) {
    debugPrint("Favorite City widget is created");

    return Scaffold(
      appBar: AppBar(title: Text("Stateful Example")),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              onSubmitted: (String userInput) {
                setState(() {
                  debugPrint("setState is called");
                  nameCity = userInput;
                });
              },
            ),
            DropdownButton<String>(
              items: _currencies.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem),
                );
              }).toList(),
              onChanged: (String newValueSelected) {
                _onDropDownItemSelected(newValueSelected);
              },
              value: _currentItemSelected,
            ),
            Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Your best city is $nameCity",
                  style: TextStyle(fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }

  void _onDropDownItemSelected(String newValueSelected) {
    setState(() {
      this._currentItemSelected = newValueSelected;
    });
  }
}
