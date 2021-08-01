
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mytodo/Widget/taskInput.dart';
import 'package:mytodo/Widget/todo.dart';
import 'package:mytodo/Widget/done.dart';
import 'package:mytodo/Models/model.dart' as Model;
import 'package:mytodo/Db/dbHelper_wrapper.dart';
import 'package:mytodo/utils.dart';
import 'package:mytodo/Widget/popup.dart';

import 'Screens/importants.dart';

void main() => runApp(TodosApp());

class TodosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        backgroundColor: Color(0xfffff5eb),
      ),
      title: "Todo",
      home: Scaffold(
      appBar: AppBar(
          title: Builder(
            builder: (context) =>Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Todo",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),),
                InkWell(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.star,color: Colors.white,)),
                      Text("Önemli Görevler",style: TextStyle(fontSize: 14),)
                    ],
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Importants()),
                    );
                  },
                )
              ],
            ),
          ),
          backgroundColor: Colors.blueGrey,
      ),
      body: HomeScreen(),
      )
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  String welcomeMsg;
  List<Model.Todo> todos;
  List<Model.Todo> dones;
  TabController tabController;
  String selectedTabCategory = "Bugün";

  @override
  void dispose() {
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
    tabController.dispose();
    tabController = null;
  }

  @override
  void initState() {
    super.initState();
    getTodosAndDones(selectedTabCategory);
    WidgetsBinding.instance.addObserver(this);
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
    tabController.addListener(() {
      getTodosAndDones(selectedTabCategory);
    });
  }
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.grey;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: 50),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      todoBody("Bugün"),
                      todoBody("Yarın"),
                      todoBody("Hafta"),
                      todoBody("Ay"),
                    ],
                  ),
                ),
              ],
            ),
            Material(
              elevation: 4,
              child: TabBar(
                onTap: (index){
                  if(index == 0){ selectedTabCategory = "Bugün";}
                  else if(index == 1){selectedTabCategory = "Yarın";}
                  else if(index == 2){selectedTabCategory = "Hafta";}
                  else{selectedTabCategory = "Ay";}
                },
                controller: tabController,
                indicatorColor: Colors.blueGrey,
                labelColor: Colors.blueGrey,
                unselectedLabelColor: Colors.black.withOpacity(.3),
                overlayColor: MaterialStateProperty.resolveWith(getColor),
                tabs: [
                  Tab(text: 'Bugün'),
                  Tab(text: 'Yarın'),
                  Tab(text: 'Hafta'),
                  Tab(text: 'Ay'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget todoBody(String value){
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          Utils.hideKeyboard(context);
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    height: 0,
                                    child: Popup(
                                      getTodosAndDones: getTodosAndDones,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 2.0),
                              child: TaskInput(
                                onSubmitted: addTaskInTodo,
                                categoryName: value,
                              ), // Add Todos
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              expandedHeight: 100,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  switch (index) {
                    case 0:
                      return TodoWidget(
                        todos: todos,
                        onTap: markTodoAsDone,
                        onDeleteTask: deleteTask,
                      ); // Active todos
                    case 1:
                      return SizedBox(
                        height: 30,
                      );
                    case 2:
                      return Done(
                        dones: dones,
                        onTap: markDoneAsTodo,
                        onDeleteTask: deleteTask,
                      );
                    default:
                      return FlatButton(
                        color: Colors.white,
                        textColor: Colors.grey,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.black,
                        padding: EdgeInsets.all(8.0),
                        splashColor: Colors.redAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.info),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10,0,0,0),
                              child: Text("Uygulama Hakkında"),
                            )
                          ],
                        ),
                        onPressed: () {
                          return showDialog<void>(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text("'Todo Eklemek için': Görev ekleme kutusuna eklemek istediğiniz görevi yazıp ekleyebilirsiniz,"
                                      "Silmek için': sola doğru kaydırmanız yeterli,"
                                      "Eklenen görev yapıldıysa 'Done kutusuna eklemek için': Todo kutusunda biten işin üstene basın."),
                                  actions: [
                                    TextButton(
                                    child: Text("Tamam"),
                                    onPressed: () { Navigator.pop(context);},
                                    )
                                  ],
                                );
                              }
                          );
                        },
                      );
                  }
                },
                childCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
}



  void getTodosAndDones(String selectedCategory) async {
    final _todos = await DBWrapper.sharedInstance.getTodos(selectedCategory);
    final _dones = await DBWrapper.sharedInstance.getDones(selectedCategory);

    setState(() {
      todos = _todos;
      dones = _dones;
    });
  }

  void addTaskInTodo({@required TextEditingController controller}) {
    final inputText = controller.text.trim();

    if (inputText.length > 0) {
      // Add todos
      Model.Todo todo = Model.Todo(
          title: inputText,
          created: DateTime.now(),
          updated: DateTime.now(),
          status: Model.TodoStatus.active.index,
          category:selectedTabCategory
      );

      DBWrapper.sharedInstance.addTodo(todo);
      getTodosAndDones(selectedTabCategory);
    } else {
      Utils.hideKeyboard(context);
    }

    controller.text = '';
  }

  void markTodoAsDone({@required int pos}) {
    DBWrapper.sharedInstance.markTodoAsDone(todos[pos]);
    getTodosAndDones(selectedTabCategory);
  }

  void markDoneAsTodo({@required int pos}) {
    DBWrapper.sharedInstance.markDoneAsTodo(dones[pos]);
    getTodosAndDones(selectedTabCategory);
  }

  void deleteTask({@required Model.Todo todo}) {
    DBWrapper.sharedInstance.deleteTodo(todo);
    getTodosAndDones(selectedTabCategory);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  void navigateSecondPage() {
    Route route = MaterialPageRoute(builder: (context) => Importants());
    Navigator.push(context, route).then(onGoBack);
  }
}
