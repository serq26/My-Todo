
import 'package:flutter/material.dart';
import 'package:mytodo/utils.dart';

class TaskInput extends StatefulWidget {
  final Function onSubmitted;
  final String categoryName;
  TaskInput({@required Function this.onSubmitted, this.categoryName});

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  TextEditingController textEditingController = TextEditingController();

  String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 5),
              width: 40,
              child: Icon(
                Icons.add,
                color: Colors.blueGrey,
                size: 30,
              ),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 2,
                decoration: InputDecoration(
                    hintText: this.widget.categoryName + ' için bir görev ekleyiniz' ,
                    border: InputBorder.none,
                ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                textInputAction: TextInputAction.done,
                controller: textEditingController,
                onEditingComplete: () {
                  widget.onSubmitted(controller: textEditingController);
                },
              ),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
