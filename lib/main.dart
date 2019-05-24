import 'package:flutter/material.dart';

double _padding = 16;
double _halfPadding = 8;

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Simple Interest Calculator App",
      home: SIForm(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        accentColor: Colors.indigoAccent,
      ),
    ));

class SIForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SIFormState();
  }
}

class _SIFormState extends State<SIForm> {
  var _formKey = GlobalKey<FormState>();

  var _currencies = ["Rupees", "Dollars", "Pounds"];
  var _currentItemSelected = "";

  @override
  void initState() {
    super.initState();
    _currentItemSelected = _currencies[0];
  }

  var principalController = TextEditingController();
  var roiController = TextEditingController();
  var termController = TextEditingController();

  var displayText = "";

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
//      resizeToAvoidBottomPadding: false,
        appBar: AppBar(title: Text("Simple Interest Calculator")),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(_padding),
            child: ListView(
              children: <Widget>[
                BankImage(),
                Padding(
                    padding: EdgeInsets.only(bottom: _halfPadding),
                    child: TextFormField(
                      controller: principalController,
                      validator: (String value) {
                        if (value.isEmpty) return "Please enter principal";
                      },
                      style: textStyle,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelStyle: textStyle,
                          labelText: "Principal",
                          hintText: "Enter Principal e.g. 12000",
                          errorStyle: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 15
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: _halfPadding),
                    child: TextFormField(
                      controller: roiController,
                      validator: (String value) {
                        if (value.isEmpty) return "Please enter roi";
                      },
                      style: textStyle,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "Rate of Interest",
                          hintText: "In Percent",
                          errorStyle: TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 15
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: _halfPadding),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: TextFormField(
                          controller: termController,
                          validator: (String value) {
                            if (value.isEmpty) return "Please enter term";
                          },
                          style: textStyle,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: "Term",
                              hintText: "Time in years",
                              errorStyle: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 15
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        )),
                        Container(
                          width: _halfPadding,
                        ),
                        Expanded(child: getDropdownButton())
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: _padding),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text("Calculate", textScaleFactor: 1.5),
                          onPressed: () {
                            setState(() {
                              if (_formKey.currentState.validate())
                                this.displayText = _calculateTotalReturns();
                            });
                          },
                        )),
                        Expanded(
                            child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          child: Text("Reset", textScaleFactor: 1.5),
                          onPressed: () {
                            _reset();
                          },
                        ))
                      ],
                    )),
                Container(
                    alignment: Alignment.center,
                    child: Text(
                      this.displayText,
                      style: textStyle,
                    ))
              ],
            ),
          ),
        ));
  }

  Widget getDropdownButton() => DropdownButton<String>(
        items: _currencies.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        value: _currentItemSelected,
        onChanged: (String newValueSelected) {
          _onDropDownItemSelected(newValueSelected);
        },
      );

  void _onDropDownItemSelected(String newValueSelected) {
    setState(() {
      this._currentItemSelected = newValueSelected;
    });
  }

  String _calculateTotalReturns() {
    double principal = double.parse(principalController.text);
    double roi = double.parse(roiController.text);
    double term = double.parse(termController.text);

    double totalAmountPayable = principal + (principal * roi * term) / 100;
    return "After $term years, your investment will be worth $totalAmountPayable $_currentItemSelected";
  }

  void _reset() {
    principalController.text = "";
    roiController.text = "";
    termController.text = "";
    displayText = "";
    _currentItemSelected = _currencies[0];
  }
}

class BankImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var image = Image(image: AssetImage('images/money.png'));
    return Container(
      margin: EdgeInsets.only(bottom: _padding),
      alignment: Alignment.center,
      child: image,
      width: 200,
      height: 200,
    );
  }
}
