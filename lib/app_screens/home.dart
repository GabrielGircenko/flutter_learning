import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            padding: EdgeInsets.only(top: 32, left: 16, right: 16),
            alignment: Alignment.center,
            color: Colors.deepPurple,
            child: Column(children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    "Spice Jet",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 30,
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  )),
                  Expanded(
                      child: Text(
                    "From Mumbai to Bangalore via New Delhi",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 20,
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ))
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    "Jetline",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 30,
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  )),
                  Expanded(
                      child: Text(
                    "From Jaipur to Goa",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 20,
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ))
                ],
              ),
              FlightImageAsset(),
              FlightBookButton()
            ])));
  }
}

class FlightImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage('images/flight.png');
    Image image = Image(image: assetImage, width: 250, height: 250);
    return Container(child: image);
  }
}

class FlightBookButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      width: 250,
      height: 50,
      child: RaisedButton(
          color: Colors.deepOrange,
          child: Text(
            "Book Your Flight",
            style: TextStyle(
                fontFamily: "Raleway",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          elevation: 6,
          onPressed: () => bookFlight(context)),
    );
  }

  void bookFlight(BuildContext context) {
    var alertDialog = AlertDialog(
      title: Text("Flight Booked Successfully"),
      content: Text("Have a pleasant flight"),
    );

    showDialog(
        context: context, builder: (BuildContext context) => alertDialog);
  }
}
