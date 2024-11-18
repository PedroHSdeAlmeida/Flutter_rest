import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(ApiApp());

class ApiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste de Requisições',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ApiHomePage(title: 'TRABALHO API RESTFULL FLUTTER'),
    );
  }
}

class ApiHomePage extends StatefulWidget {
  ApiHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ApiHomePageState createState() => _ApiHomePageState();
}

class _ApiHomePageState extends State<ApiHomePage> {
  final TextEditingController _idController = TextEditingController(text: '0');
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _get();
  }

  Future<void> _get() async {
    final url = Uri.parse('http://10.0.2.2/api/testeApi.php/cliente/list');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      setState(() {
        _data = data;
      });
    } catch (error) {
      print('Erro ao executar solicitação GET: $error');
    }
  }

  Future<void> _post() async {
    final url = Uri.parse('http://10.0.2.2/api/testeApi.php/cliente');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nome': _nomeController.text,
          'categoria': _categoriaController.text,
        }),
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message']),
      ));
      _get();
    } catch (error) {
      print('Erro ao executar solicitação POST: $error');
    }
  }

  Future<void> _put() async {
    final url = Uri.parse(
        'http://10.0.2.2/api/testeApi.php/cliente/${_idController.text}');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nome': _nomeController.text,
          'categoria': _categoriaController.text,
        }),
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message']),
      ));
      _get();
    } catch (error) {
      print('Erro ao executar solicitação PUT: $error');
    }
  }

  Future<void> _delete() async {
    final url = Uri.parse(
        'http://10.0.2.2/api/testeApi.php/cliente/${_idController.text}');
    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message']),
      ));
      _get();
    } catch (error) {
      print('Erro ao executar solicitação DELETE: $error');
    }
  }

  void _selectRow(dynamic item) {
    setState(() {
      _idController.text = item['id'].toString();
      _nomeController.text = item['nome'];
      _categoriaController.text = item['categoria'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(labelText: 'Id'),
                    readOnly: true,
                  ),
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  TextField(
                    controller: _categoriaController,
                    decoration: InputDecoration(labelText: 'Categoria'),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      ElevatedButton(onPressed: _get, child: Text('Selecionar')),
                      SizedBox(width: 8),
                      ElevatedButton(onPressed: _post, child: Text('Criar')),
                      SizedBox(width: 8),
                      ElevatedButton(onPressed: _put, child: Text('Atualizar')),
                      SizedBox(width: 8),
                      ElevatedButton(onPressed: _delete, child: Text('Delete')),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  _data.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: _data.length,
                          itemBuilder: (context, index) {
                            final item = _data[index];
                            return ListTile(
                              title: Text(item['nome']),
                              subtitle: Text(item['categoria']),
                              onTap: () => _selectRow(item),
                            );
                          },
                        )
                      : Center(child: Text('Nenhum dado disponível')),
                ]))));
  }
}