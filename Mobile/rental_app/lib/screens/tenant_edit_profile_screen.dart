import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../services/api_service.dart';

class TenantEditProfileScreen extends StatefulWidget {
  final Tenant tenant;

  const TenantEditProfileScreen({super.key, required this.tenant});

  @override
  TenantEditProfileScreenState createState() => TenantEditProfileScreenState();
}

class TenantEditProfileScreenState extends State<TenantEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _jobController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _aboutMeController;
  bool _prefersStudio = false;
  bool _prefersApartment = false;
  bool _prefersSharedRent = false;
  bool _acceptsPets = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant.name);
    _ageController = TextEditingController(text: widget.tenant.age.toString());
    _jobController = TextEditingController(text: widget.tenant.job);
    _cityController = TextEditingController(text: widget.tenant.city);
    _stateController = TextEditingController(text: widget.tenant.state);
    _aboutMeController = TextEditingController(text: widget.tenant.aboutMe);
    _prefersStudio = widget.tenant.prefersStudio;
    _prefersApartment = widget.tenant.prefersApartment;
    _prefersSharedRent = widget.tenant.prefersSharedRent;
    _acceptsPets = widget.tenant.acceptsPets;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _jobController.dispose();
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
        'age': int.parse(_ageController.text),
        'job': _jobController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'about_me': _aboutMeController.text,
        'prefers_studio': _prefersStudio,
        'prefers_apartment': _prefersApartment,
        'prefers_shared_rent': _prefersSharedRent,
        'accepts_pets': _acceptsPets,
      };

      try {
        final apiService = ApiService();
        await apiService.updateTenant(data);
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
        backgroundColor: Colors.green,
        title: const Text('Editar Perfil'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // Ícones (incluindo a seta de voltar) na cor branca
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(labelText: 'Idade'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua idade';
                            }
                            if (int.tryParse(value) == null || int.parse(value) <= 0) {
                              return 'Por favor, insira uma idade válida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _jobController,
                          decoration: const InputDecoration(labelText: 'Profissão'),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'Cidade'),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(labelText: 'Estado'),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _aboutMeController,
                          decoration: const InputDecoration(labelText: 'Sobre mim'),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Preferências de aluguel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        CheckboxListTile(
                          title: const Text('Estúdio'),
                          value: _prefersStudio,
                          onChanged: (value) {
                            setState(() {
                              _prefersStudio = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Apartamento'),
                          value: _prefersApartment,
                          onChanged: (value) {
                            setState(() {
                              _prefersApartment = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Aluguel compartilhado'),
                          value: _prefersSharedRent,
                          onChanged: (value) {
                            setState(() {
                              _prefersSharedRent = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Aceita pets'),
                          value: _acceptsPets,
                          onChanged: (value) {
                            setState(() {
                              _acceptsPets = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 18),
                            ),
                            child: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
