import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getStatesFromIBGE() async {
  final url = Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Falha ao carregar os estados da API do IBGE');
  }
}

Future<List<dynamic>> getCitiesFromIBGE(String uf) async {
  final url = Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Falha ao carregar as cidades de $uf da API do IBGE');
  }
}

class StateCitySelector extends StatefulWidget {
  const StateCitySelector({
    super.key,
    this.onStateChanged,
    this.onCityChanged,
  });

  final ValueChanged<String?>? onStateChanged;
  final ValueChanged<String?>? onCityChanged;

  @override
  State<StateCitySelector> createState() => _StateCitySelectorState();
}

class _StateCitySelectorState extends State<StateCitySelector> {
  String? _selectedStateSigla;
  String? _selectedCityName;
  List<dynamic> _states = [];
  List<dynamic> _cities = [];
  bool _loadingStates = false;
  bool _loadingCities = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() {
      _loadingStates = true;
    });
    try {
      final statesData = await getStatesFromIBGE(); // Chamada direta à função
      setState(() {
        _states = statesData;
        _loadingStates = false;
      });
    } catch (e) {
      setState(() {
        _loadingStates = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar estados: $e')),
      );
    }
  }

  Future<void> _loadCities(String uf) async {
    setState(() {
      _loadingCities = true;
      _cities = [];
      _selectedCityName = null;
    });
    try {
      final citiesData = await getCitiesFromIBGE(uf); // Chamada direta à função
      setState(() {
        _cities = citiesData;
        _loadingCities = false;
      });
    } catch (e) {
      setState(() {
        _loadingCities = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar cidades: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_loadingStates)
          const CircularProgressIndicator()
        else
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Estado'),
            value: _selectedStateSigla,
            items: _states.map((state) => DropdownMenuItem<String>(
                  value: state['sigla'],
                  child: Text(state['nome']),
                )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStateSigla = value;
              });
              widget.onStateChanged?.call(value);
              if (value != null) {
                _loadCities(value);
              } else {
                setState(() {
                  _cities = [];
                  _selectedCityName = null;
                });
              }
            },
            validator: (value) => value == null ? 'Selecione o estado' : null,
          ),
        const SizedBox(height: 16),
        if (_loadingCities)
          const CircularProgressIndicator()
        else
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Cidade'),
            value: _selectedCityName,
            items: _cities.map((city) => DropdownMenuItem<String>(
                  value: city['nome'],
                  child: Text(city['nome']),
                )).toList(),
            onChanged: _selectedStateSigla == null
                ? null
                : (value) {
                    setState(() {
                      _selectedCityName = value;
                    });
                    widget.onCityChanged?.call(value);
                  },
            validator: (value) =>
                _selectedStateSigla != null && value == null ? 'Selecione a cidade' : null,
          ),
      ],
    );
  }
}