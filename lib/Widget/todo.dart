import 'package:flutter/material.dart';
import 'package:mytodo/Db/dbHelper_wrapper.dart';
import 'package:mytodo/Screens/importants.dart';
import 'package:mytodo/Widget/shared.dart';
import 'package:mytodo/Models/model.dart';

const int NoTask = -1;
const int animationMilliseconds = 500;

class TodoWidget extends StatefulWidget {
  Function onTap;
  Function onDeleteTask;
  List<Todo> todos;

  TodoWidget({@required this.todos, this.onTap, this.onDeleteTask});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<TodoWidget> {
  int taskPosition = NoTask;
  bool showCompletedTaskAnimation = false;
  int important;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              if (widget.todos == null || widget.todos.length == 0)
                Container(
                  height: 10,
                ),
              if (widget.todos != null)
                for (int i = 0; i < widget.todos.length; ++i)
                  AnimatedOpacity(
                    curve: Curves.fastOutSlowIn,
                    opacity: taskPosition != i
                        ? 1.0
                        : showCompletedTaskAnimation ? 0 : 1,
                    duration: Duration(seconds: 1),
                    child: getTaskItem(
                      widget.todos[i].title,
                      index: i,
                      onTap: () {
                        setState(() {
                          taskPosition = i;
                          showCompletedTaskAnimation = true;
                        });
                        Future.delayed(
                          Duration(milliseconds: animationMilliseconds),
                        ).then((value) {
                          taskPosition = NoTask;
                          showCompletedTaskAnimation = false;
                          widget.onTap(pos: i);
                        });
                      },
                    ),
                  ),
            ],
          ),
        ),
        SharedWidget.getCardHeader(
            context: context, text: 'TO DO', customFontSize: 16),
      ],
    );
  }

  Widget getTaskItem(String text,
      {@required int index, @required Function onTap}) {
    final double height = 50.0;
    important = widget.todos[index].isImportant;
    return Container(
        child: Column(
          children: <Widget>[
            Dismissible(
              key: Key(text + '$index'),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                widget.onDeleteTask(todo: widget.todos[index]);
              },
              background: SharedWidget.getOnDismissDeleteBackground(),
              child: InkWell(
                onTap: onTap,
                child: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        width: 7,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 10, top: 15, right: 20, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                text,
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.justify,
                                style: Theme.of(context).textTheme.title.copyWith(
                                  color: Color(0xff373640),
                                ),
                              ),
                              IconButton(icon: widget.todos[index].isImportant == 0 ? Icon(Icons.star_border) : Icon(Icons.star),
                                  onPressed: (){
                                    if(important == 0){
                                      importantTodo(1,widget.todos[index].id);
                                      setState(() {
                                        important = 1;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Önemli Görevlere eklendi"),
                                      ));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Importants()),
                                      );
                                    }
                                    else{
                                      importantTodo(0,widget.todos[index].id);
                                      setState(() {
                                        important = 0;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Önemli Görevlerden silindi"),
                                      ));
                                    }
                                  }
                                  ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 0.5,
              child: Container(
                color: Colors.grey,
              ),
            ),
          ],
        ));
  }
  void importantTodo(int important, int id) {
    DBWrapper.sharedInstance.importantTodo(important,id);
  }

}