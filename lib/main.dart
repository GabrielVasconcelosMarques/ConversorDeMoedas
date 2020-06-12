import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=7920db05";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
        hintStyle: TextStyle(color: Colors.amber),
      ),
    ),
    debugShowCheckedModeBanner: false,
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double dolar;
  double euro;

  TextEditingController controladorReal = TextEditingController();
  TextEditingController controladorDolar = TextEditingController();
  TextEditingController controladorEuro = TextEditingController();

  void realChanged(String text){
    if(controladorReal.text.isEmpty){
      return reset();
    }
    double real = double.parse(controladorReal.text);
    controladorDolar.text = (real/dolar).toStringAsFixed(2);
    controladorEuro.text = (real/euro).toStringAsFixed(2);
  }

  void dolarChanged(String text){
    if(controladorDolar.text.isEmpty){
      return reset();
    }
    double dolar = double.parse(controladorDolar.text);
    controladorReal.text = (dolar * this.dolar).toStringAsFixed(2);
    controladorEuro.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void euroChanged(String text){
    if(controladorEuro.text.isEmpty){
      return reset();
    }
    double euro = double.parse(controladorEuro.text);
    controladorReal.text = (euro * this.euro).toStringAsFixed(2);
    controladorDolar.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void reset(){
    setState(() {
      controladorDolar.text = '';
      controladorReal.text = '';
      controladorEuro.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Conversor de Moedas",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Erro ao Carregar dados",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              else{
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, color: Colors.amber, size: 150.0,),
                      FuncaoTextField("Reais", "R\$ ", controladorReal, realChanged),
                      Divider(),
                      FuncaoTextField("Dólares", "US\$ ", controladorDolar, dolarChanged),
                      Divider(),
                      FuncaoTextField("Euros", "€ ", controladorEuro, euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget FuncaoTextField(String label, String prefixo, TextEditingController controlador, Function f){
  return TextField(
    controller: controlador,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.amber,
        ),
        border: OutlineInputBorder(),
        prefixText: prefixo
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
