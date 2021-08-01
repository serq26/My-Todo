
import 'package:flutter/material.dart';
import 'package:mytodo/Db/dbHelper.dart';
import 'package:mytodo/Db/dbHelper_wrapper.dart';
import 'package:mytodo/Models/model.dart';

class Importants extends StatefulWidget{
  @override
  _ImportantsState createState() => _ImportantsState();
}
class _ImportantsState extends State<Importants> {
  List<Todo> todos;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (todos == null) {
      getData();
    }
    return MaterialApp(
      title: "Todo",
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          backgroundColor: Color(0xfffff5eb),
        ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              FloatingActionButton(
                child: new Icon(Icons.arrow_back_outlined,),
                backgroundColor: Colors.transparent,
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text("Önemli Görevler")
            ],
          ),
          backgroundColor: Colors.blueGrey,
        ),
        body:importantsTodo()
      )
    );
  }

  ListView importantsTodo(){
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) => Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColor(this.todos[position].category),
                child: Icon(Icons.star,color: Colors.white)
              ),
              title: Text(this.todos[position].title),
              subtitle: Text(this.todos[position].category),
            )
        )
    );
  }

  void getData() {
    final todosFuture = DBWrapper.sharedInstance.getTImportants();
    todosFuture.then((result) => {
      setState(() {
        todos = result;
        count = todos.length;
      })
    });
  }

  Color getColor(String category) {
    switch (category) {
      case "Bugün":
        return Colors.red;
      case "Yarın":
        return Colors.orange;
      case "Hafta":
        return Colors.green;
      case "Ay":
        return Colors.black;
      default:
        return Colors.green;
    }
  }
}