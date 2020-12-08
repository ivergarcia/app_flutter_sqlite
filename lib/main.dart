import 'package:app_crud_sqlite/models/person.dart';
import 'package:app_crud_sqlite/utils/database_helper.dart';
import 'package:flutter/material.dart';

const darkBlueColors = Color(0xFF006064);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLUTTER CRUD SQLITE',
      theme: ThemeData(
        primaryColor: darkBlueColors,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'FLUTTER CRUD SQLITE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  Person _person = Person();
  List<Person> _persons = [];
  DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshPersonList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(color: darkBlueColors),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }

  _form() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (val) => setState(() => _person.name = val),
                validator: (val) =>
                    (val.length == 0 ? 'Este campo es requerido' : null),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Dirección'),
                onSaved: (val) => setState(() => _person.address = val),
                validator: (val) =>
                    (val.length == 0 ? 'Este campo es requerido' : null),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Telefono'),
                onSaved: (val) => setState(() => _person.phone = val),
                validator: (val) =>
                    (val.length < 8 ? 'Se requiere que tenga 8 digitos' : null),
              ),
              Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    color: darkBlueColors,
                    textColor: Colors.white,
                    child: Text('Guardar'),
                    onPressed: () => _onSubmit(),
                  ))
            ],
          ),
        ),
      );
  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading:
                        Icon(Icons.person, color: darkBlueColors, size: 40.0),
                    title: Text(
                      _persons[index].name.toUpperCase(),
                      style: TextStyle(
                          color: darkBlueColors, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_persons[index].address.toLowerCase()),
                  ),
                  Divider(height: 5.0)
                ],
              );
            },
            itemCount: _persons.length,
          ),
        ),
      );

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      // setState(() {
      //   _persons.add(Person(
      //       id: null,
      //       name: _person.name,
      //       address: _person.address,
      //       phone: _person.phone));
      // });
      await _dbHelper.insertPerson(_person);
      _refreshPersonList();
      form.reset();
    }
  }

  _refreshPersonList() async {
    List<Person> x = await _dbHelper.fetchPersons();
    setState(() {
      _persons = x;
    });
  }
}
