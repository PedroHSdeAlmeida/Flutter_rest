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
      home: ApiHomePage(title: 'TRABALHO API RESTFUL FLUTTER'),
    );
  }
}

class Cliente {
  final int id;
  final String nome;
  final String categoria;

  Cliente({required this.id, required this.nome, required this.categoria});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: int.parse(json['id'].toString()),
      nome: json['nome'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
    };
  }
}

class ApiHomePage extends StatefulWidget {
  ApiHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ApiHomePageState createState() => _ApiHomePageState();
}

class _ApiHomePageState extends State<ApiHomePage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  List<Cliente> _clientes = [];

  final String _baseUrl = 'http://10.0.2.2/api/testeApi.php/cliente';

  @override
  void initState() {
    super.initState();
    _getClientes();
  }

  Future<void> _getClientes() async {
    final url = Uri.parse('$_baseUrl/list');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _clientes = data.map((item) => Cliente.fromJson(item)).toList();
        });
      } else {
        _showMessage('Erro ao obter dados: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Erro ao executar solicitação GET: $error');
    }
  }

  Future<void> _createCliente() async {
    final url = Uri.parse(_baseUrl);
    try {
      final cliente = Cliente(
        id: 0,
        nome: _nomeController.text,
        categoria: _categoriaController.text,
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(cliente.toJson()),
      );
      final data = jsonDecode(response.body);
      _showMessage(data['message']);
      _getClientes();
    } catch (error) {
      _showMessage('Erro ao executar solicitação POST: $error');
    }
  }

  Future<void> _updateCliente() async {
    final url = Uri.parse('$_baseUrl/${_idController.text}');
    try {
      final cliente = Cliente(
        id: int.parse(_idController.text),
        nome: _nomeController.text,
        categoria: _categoriaController.text,
      );
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(cliente.toJson()),
      );
      final data = jsonDecode(response.body);
      _showMessage(data['message']);
      _getClientes();
    } catch (error) {
      _showMessage('Erro ao executar solicitação PUT: $error');
    }
  }

  Future<void> _deleteCliente() async {
    final url = Uri.parse('$_baseUrl/${_idController.text}');
    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);
      _showMessage(data['message']);
      _getClientes();
    } catch (error) {
      _showMessage('Erro ao executar solicitação DELETE: $error');
    }
  }

  void _selectCliente(Cliente cliente) {
    setState(() {
      _idController.text = cliente.id.toString();
      _nomeController.text = cliente.nome;
      _categoriaController.text = cliente.categoria;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
                ElevatedButton(
                    onPressed: _getClientes, child: Text('Atualizar')),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _createCliente, child: Text('Criar')),
                SizedBox(width: 8),
                ElevatedButton(
                    onPressed: _updateCliente, child: Text('Alterar')),
                SizedBox(width: 8),
                ElevatedButton(
                    onPressed: _deleteCliente, child: Text('Excluir')),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _clientes.isNotEmpty
                  ? ListView.builder(
                      itemCount: _clientes.length,
                      itemBuilder: (context, index) {
                        final cliente = _clientes[index];
                        return ListTile(
                          title: Text(cliente.nome),
                          subtitle: Text(cliente.categoria),
                          onTap: () => _selectCliente(cliente),
                        );
                      },
                    )
                  : Center(child: Text('Nenhum dado disponível')),
            ),
          ],
        ),
      ),
    );
  }
}