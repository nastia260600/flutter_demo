import 'package:flutter/material.dart';
import 'package:flutter_demo/fetch_data/project.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Про додаток'),
      ),
      drawer: DrawerMain(selected: "about"),
      body: Center(
        child: Text(
          'Список Github users',
        ),
      ),
    );
  }
}

class DrawerMain extends StatefulWidget {
  DrawerMain({Key key, this.selected}) : super(key: key);

  final String selected;

  @override
  DrawerMainState createState() {
    return DrawerMainState();
  }
}

class DrawerMainState extends State<DrawerMain> {
  @override
  Widget build (BuildContext context) {
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  'Flutter demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                selected: widget.selected == 'about',
                leading: Icon(Icons.info),
                title: Text('Про нас'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
              ),
              ListTile(
                selected: widget.selected == 'projects',
                leading: Icon(Icons.list),
                title: Text('Проекти'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProjectsPage()),
                  );
                },
              ),
            ]
        )
    );
  }
}

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Project> list = List();
  bool flag = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  Future _fetchData() async {

//  list.sort();
//  list.retainWhere();
    final response = await http.get(
        "https://api.github.com/users"
    );
    if (response.statusCode == 200) {
      setState(() {
        list = (json.decode(response.body) as List)
            .map((data) => new Project.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load projects');
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_){  _refreshIndicatorKey.currentState?.show(); });
  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Проекти'),
      ),
      drawer: DrawerMain(selected: "projects"),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _fetchData,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () => {
                    setState(() {
                      list.sort((a,b) => flag
                          ? a.login
                              .toString()
                              .toLowerCase()
                              .compareTo(b.login.toString().toLowerCase())
                          : b.login
                              .toString()
                              .toLowerCase()
                              .compareTo(a.login.toString().toLowerCase()));
                      flag = !flag;
                    }),
                  },
                  child: Text(
                    'Sort'
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(

                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Image.network(
                            list[index].avatar_url,
                            fit: BoxFit.fitHeight,
                            width: 600.0,
                            height: 240.0,
                          ),
                          Text(
                            list[index].login,
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            list[index].id.toString(),
                            style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        )
      ),

    );

  }
}

