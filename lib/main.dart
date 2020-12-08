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
  final _controllerName = TextEditingController();
  final _controllerAddress = TextEditingController();
  final _controllerPhone = TextEditingController();

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
                controller: _controllerName,
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (val) => setState(() => _person.name = val),
                validator: (val) =>
                    (val.length == 0 ? 'Este campo es requerido' : null),
              ),
              TextFormField(
                controller: _controllerAddress,
                decoration: InputDecoration(labelText: 'Dirección'),
                onSaved: (val) => setState(() => _person.address = val),
                validator: (val) =>
                    (val.length == 0 ? 'Este campo es requerido' : null),
              ),
              TextFormField(
                controller: _controllerPhone,
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
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_sweep,
                        color: darkBlueColors,
                      ),
                      onPressed: () async {
                        await _dbHelper.deletePerson(_persons[index].id);
                        _resetForm();
                        _refreshPersonList();
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _person = _persons[index];
                        _controllerName.text = _persons[index].name;
                        _controllerAddress.text = _persons[index].address;
                        _controllerPhone.text = _persons[index].phone;
                      });
                    },
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
      if (_person.id == null)
        await _dbHelper.insertPerson(_person);
      else
        await _dbHelper.updatePerson(_person);
      _refreshPersonList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      _controllerName.clear();
      _controllerAddress.clear();
      _controllerPhone.clear();
      _person.id = null;
    });
  }

  _refreshPersonList() async {
    List<Person> x = await _dbHelper.fetchPersons();
    setState(() {
      _persons = x;
    });
  }
}
