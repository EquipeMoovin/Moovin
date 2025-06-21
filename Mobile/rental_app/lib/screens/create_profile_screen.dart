import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateProfileScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final bool isOwner;

  const CreateProfileScreen({
    Key? key,
    required this.userId,
    required this.name,
    required this.email,
    required this.isOwner,
  }) : super(key: key);

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _ageController = TextEditingController();
  final _jobController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  @override
  void dispose() {
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _ageController.dispose();
    _jobController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  // Método para selecionar a imagem
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _selectedImageBytes = null; // Reset bytes for web
      });

      if (kIsWeb) {
        // Para web, carrega os bytes para exibição
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    }
  }

  // Método para salvar o perfil e fazer upload da imagem
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final url = widget.isOwner
        ? 'https://moovin.onrender.com/api/owners/owner_create'
        : 'https://moovin.onrender.com/api/tenants/tenant_create';

    final body = widget.isOwner
        ? {
      'user': int.parse(widget.userId),
      'name': widget.name,
      'phone': _phoneController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'about_me': _aboutMeController.text,
    }
        : {
      'user': int.parse(widget.userId),
      'name': widget.name,
      'age': int.tryParse(_ageController.text) ?? 0,
      'job': _jobController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'about_me': _aboutMeController.text,
    };

    try {
      // Criar o perfil
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final createdProfile = jsonDecode(response.body);
        final int? profileId = createdProfile['id'] as int?;

        if (profileId == null) {
          _showSnackBar('Erro: ID do perfil criado é nulo.', Colors.red);
          return;
        }

        // Fazer upload da imagem, se selecionada
        if (_selectedImage != null) {
          final uploadUrl = widget.isOwner
              ? Uri.parse('https://moovin.onrender.com/api/owners/owner-photo-upload/')
              : Uri.parse('https://moovin.onrender.com/api/tenants/tenant-photo-upload/');

          var request = http.MultipartRequest('POST', uploadUrl);
          // Adicionar o ID do perfil (owner_id ou tenant_id)
          request.fields[widget.isOwner ? 'owner_id' : 'tenant_id'] =
              profileId.toString();

          // Adicionar o arquivo de imagem
          if (kIsWeb) {
            final bytes = await _selectedImage!.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'photos',
                bytes,
                filename: _selectedImage!.name,
                contentType: MediaType('image', _selectedImage!
                    .name
                    .split('.')
                    .last),
              ),
            );
          }
          else {
            request.files.add(
              await http.MultipartFile.fromPath(
                'photos',
                _selectedImage!.path,
              ),
            );
          }

          // Enviar a requisição de upload
          final uploadResponse = await request.send();
          if (uploadResponse.statusCode == 201 ||
              uploadResponse.statusCode == 200) {
            _showSnackBar('Perfil e foto criados com sucesso!', Colors.green);
          }
          else {
            final errorData = await uploadResponse.stream.bytesToString();
            _showSnackBar('Erro ao enviar a foto: $errorData', Colors.red);
            return;
          }
        }
        else {
          _showSnackBar('Perfil criado com sucesso!', Colors.green);
        }

        // Navegar para a tela de login
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar('Erro ao criar perfil: $errorData', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erro na conexão com o servidor: $e', Colors.red);
    }
  }
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _goToLogin() {
    _saveProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 180),
                const SizedBox(height: 20),
                const Text(
                  'Criação de Perfil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F6D3C),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: TextEditingController(text: widget.name),
                  label: 'Nome',
                  validator: (value) => value == null || value.isEmpty ? 'Por favor, insira o nome' : null,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Telefone',
                  validator: (value) => value == null || value.isEmpty ? 'Por favor, insira o telefone' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cityController,
                  label: 'Cidade',
                  validator: (value) => value == null || value.isEmpty ? 'Por favor, insira a cidade' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _stateController,
                  label: 'Estado',
                  validator: (value) => value == null || value.isEmpty ? 'Por favor, insira o estado' : null,
                ),
                const SizedBox(height: 16),
                if (!widget.isOwner) ...[
                  _buildTextField(
                    controller: _ageController,
                    label: 'Idade',
                    validator: (value) {
                      final age = int.tryParse(value ?? '');
                      if (age == null || age <= 0) {
                        return 'Por favor, insira uma idade válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _jobController,
                    label: 'Profissão',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Por favor, insira sua profissão' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTextField(
                  controller: _aboutMeController,
                  label: 'Sobre mim',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Por favor, insira uma descrição sobre você' : null,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Foto do perfil (opcional)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F6D3C)),
                ),
                const SizedBox(height: 10),
                if (_selectedImage != null)
                  if (kIsWeb && _selectedImageBytes != null)
                    Image.memory(
                      _selectedImageBytes!,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  else if (!kIsWeb)
                    Image.file(
                      File(_selectedImage!.path),
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  else
                    const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Selecionar imagem'),
                ),
                const SizedBox(height: 30),
                _buildSubmitButton(
                  text: 'Salvar e Ir para Login',
                  onPressed: _goToLogin,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    required String? Function(String?) validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F6D3C),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: label == 'Idade' ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD7F0D5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
          enabled: enabled,
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required void Function() onPressed,
  }) {
    return SizedBox(
      width: 320,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F6D3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}