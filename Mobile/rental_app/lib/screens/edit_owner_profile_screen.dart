import 'package:flutter/material.dart';
import '../models/owner.dart';
import '../services/api_service.dart';

class EditOwnerProfileScreen extends StatefulWidget {
  final Owner owner;

  const EditOwnerProfileScreen({Key? key, required this.owner}) : super(key: key);

  @override
  State<EditOwnerProfileScreen> createState() => _EditOwnerProfileScreenState();
}

class _EditOwnerProfileScreenState extends State<EditOwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _aboutMeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.owner.name);
    _phoneController = TextEditingController(text: widget.owner.phone);
    _cityController = TextEditingController(text: widget.owner.city);
    _stateController = TextEditingController(text: widget.owner.state);
    _aboutMeController = TextEditingController(text: widget.owner.aboutMe);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'about_me': _aboutMeController.text,
      };

      try {
        final apiService = ApiService();
        await apiService.updateCurrentOwner(data);
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
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
        title: const Text('Editar Perfil do Proprietário'),
        backgroundColor: Colors.green,
        // Adicionado para o título ser branco
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // Adicionado para os ícones serem brancos
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o telefone' : null,
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
                controller: _aboutMeController,
                decoration: const InputDecoration(labelText: 'Sobre mim'),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Salvar Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
