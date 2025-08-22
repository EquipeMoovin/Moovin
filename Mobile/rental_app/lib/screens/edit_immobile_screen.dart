import 'package:flutter/material.dart';
import '../models/owner.dart';
import '../models/immobile.dart';
import '../services/api_service.dart';
import '../models/owner.dart';
import '../models/immobile.dart';
class EditImmobileScreen extends StatefulWidget {
  final Immobile immobile;

  const EditImmobileScreen({Key? key, required this.immobile}) : super(key: key);

  @override
  State<EditImmobileScreen> createState() => _EditImmobileScreenState();
}

class _EditImmobileScreenState extends State<EditImmobileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _areaController;
  late TextEditingController _rentController;
  bool _noNumber = false;
  bool _airConditioning = false;
  bool _garage = false;
  bool _pool = false;
  bool _furnished = false;
  bool _petFriendly = false;
  bool _nearbyMarket = false;
  bool _nearbyBus = false;
  bool _internet = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.immobile.street);
    _numberController = TextEditingController(text: widget.immobile.number ?? '');
    _cityController = TextEditingController(text: widget.immobile.city);
    _stateController = TextEditingController(text: widget.immobile.state);
    _zipCodeController = TextEditingController(text: widget.immobile.zipCode);
    _descriptionController = TextEditingController(text: widget.immobile.description);
    _areaController = TextEditingController(text: widget.immobile.area.toString());
    _rentController = TextEditingController(text: widget.immobile.rent.toString());
    _noNumber = widget.immobile.noNumber;
    _airConditioning = widget.immobile.airConditioning;
    _garage = widget.immobile.garage;
    _pool = widget.immobile.pool;
    _furnished = widget.immobile.furnished;
    _petFriendly = widget.immobile.petFriendly;
    _nearbyMarket = widget.immobile.nearbyMarket;
    _nearbyBus = widget.immobile.nearbyBus;
    _internet = widget.immobile.internet;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _saveImmobile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final data = <String, dynamic>{
        'street': _streetController.text.isNotEmpty ? _streetController.text : '',
        'number': _noNumber ? null : int.tryParse(_numberController.text),
        'no_number': _noNumber,
        'city': _cityController.text.isNotEmpty ? _cityController.text : '',
        'state': _stateController.text.isNotEmpty ? _stateController.text : '',
        'zip_code': _zipCodeController.text.isNotEmpty ? _zipCodeController.text : '',
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : '',

        'area': double.tryParse(_areaController.text) ?? 0.0,
        'rent': double.tryParse(_rentController.text) ?? 0.0,

        'air_conditioning': _airConditioning,
        'garage': _garage,
        'pool': _pool,
        'furnished': _furnished,
        'pet_friendly': _petFriendly,
        'nearby_market': _nearbyMarket,
        'nearby_bus': _nearbyBus,
        'internet': _internet,
      };

      try {
        final apiService = ApiService();
        await apiService.updateImmobile(data);
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imóvel atualizado com sucesso!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar imóvel: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Imóvel'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Rua'),
                validator: (value) => value == null || value.isEmpty ? 'Informe a rua' : null,
              ),
              const SizedBox(height: 16),
              if (!_noNumber)
                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(labelText: 'Número'),
                ),
              SwitchListTile(
                title: const Text('Sem número'),
                value: _noNumber,
                onChanged: (value) {
                  setState(() {
                    _noNumber = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator: (value) => value == null || value.isEmpty ? 'Informe a cidade' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'Estado'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o estado' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(labelText: 'CEP'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o CEP' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Área (m²)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rentController,
                decoration: const InputDecoration(labelText: 'Aluguel (R\$)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text('Características', style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: const Text('Ar condicionado'),
                value: _airConditioning,
                onChanged: (value) => setState(() => _airConditioning = value!),
              ),
              CheckboxListTile(
                title: const Text('Garagem'),
                value: _garage,
                onChanged: (value) => setState(() => _garage = value!),
              ),
              CheckboxListTile(
                title: const Text('Piscina'),
                value: _pool,
                onChanged: (value) => setState(() => _pool = value!),
              ),
              CheckboxListTile(
                title: const Text('Mobiliado'),
                value: _furnished,
                onChanged: (value) => setState(() => _furnished = value!),
              ),
              CheckboxListTile(
                title: const Text('Aceita pets'),
                value: _petFriendly,
                onChanged: (value) => setState(() => _petFriendly = value!),
              ),
              CheckboxListTile(
                title: const Text('Mercado próximo'),
                value: _nearbyMarket,
                onChanged: (value) => setState(() => _nearbyMarket = value!),
              ),
              CheckboxListTile(
                title: const Text('Ponto de ônibus próximo'),
                value: _nearbyBus,
                onChanged: (value) => setState(() => _nearbyBus = value!),
              ),
              CheckboxListTile(
                title: const Text('Internet disponível'),
                value: _internet,
                onChanged: (value) => setState(() => _internet = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveImmobile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Salvar Imóvel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
