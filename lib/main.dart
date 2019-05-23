import 'package:flutter/material.dart';

// import 'app_screens/home.dart';

void main() => runApp(MaterialApp(
      title: "Exploring UI widgets",
      home: Scaffold(
        appBar: AppBar(title: Text("Basic List View")),
        body: getListViewLong(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => debugPrint("FAB clicked"),
          child: Icon(Icons.add),
          tooltip: "Add One More Item",
        ),
      ),
    ));

void showSnackBar(BuildContext context, String text) {
  var snackBar = SnackBar(
    content: Text("You just tapped $text"),
    action: SnackBarAction(
        label: "UNDO",
        onPressed: () => debugPrint("Performing dummy UNDO operation")),
  );

  Scaffold.of(context).showSnackBar(snackBar);
}

List<String> getListElements() =>
    List<String>.generate(1000, (counter) => "Item $counter");

Widget getListViewLong() {
  var listItems = getListElements();

  var listView = ListView.builder(
      itemBuilder: (context, index) => ListTile(
          title: Text(listItems[index]),
          leading: Icon(Icons.arrow_right),
          onTap: () => showSnackBar(context, listItems[index])));

  return listView;
}

Widget getListView() => ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.landscape),
          title: Text("Landscape"),
          subtitle: Text("Beautiful view!"),
          trailing: Icon(Icons.wb_sunny),
          onTap: () {
            debugPrint("Landscape tapped");
          },
        ),
        ListTile(
            leading: Icon(Icons.laptop_chromebook), title: Text("Windows")),
        ListTile(leading: Icon(Icons.phone), title: Text("Phone")),
        Text("Yet another widget")
      ],
    );
