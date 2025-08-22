import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class ConversationDetailScreen extends StatefulWidget {
  final int conversationId;

  const ConversationDetailScreen({super.key, required this.conversationId});

  @override
  _ConversationDetailScreenState createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _userType;
  int? _userId;
  bool _isLoadingUserType = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userType = await _secureStorage.read(key: 'user_type');
    final userId = await _secureStorage.read(key: 'user_id');
    setState(() {
      _userType = userType;
      _userId = int.tryParse(userId ?? '') ?? 0;
      _isLoadingUserType = false;
    });
    if (_userId == 0 || userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não autenticado.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isLoadingUserType
                ? const Text('Carregando...')
                : Consumer<ChatProvider>(
                  builder: (context, provider, child) {
                    try {
                      final conversation = provider.conversations.firstWhere(
                        (c) => c.id == widget.conversationId,
                      );
                      String displayName =
                          _userType == 'Proprietario'
                              ? (conversation.tenant.name ??
                                  'Inquilino desconhecido')
                              : (conversation.owner.name ??
                                  'Proprietário desconhecido');
                      return Text(displayName);
                    } catch (e) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conversa não encontrada.'),
                          ),
                        );
                        Navigator.pop(context);
                      });
                      return const Text('Conversa');
                    }
                  },
                ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          // Find the conversation
          try {
            final conversation = provider.conversations.firstWhere(
              (c) => c.id == widget.conversationId,
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) {
                      final message = conversation.messages[index];
                      final isMe =
                          _userId != null && message.sender.id == _userId;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: ConstrainedBox( 
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.70,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.green[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'HH:mm',
                                  ).format(DateTime.parse(message.sentAt)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (isMe && message.isRead)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Digite sua mensagem...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.green),
                            onPressed: () {
                              if (_messageController.text.isNotEmpty) {
                                provider.sendMessage(
                                  widget.conversationId,
                                  _messageController.text,
                                );
                                _messageController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (_userType == 'Proprietario') ...[
                            ElevatedButton(
                              onPressed: () async {
                                final int? immobileId = conversation.immobile?.idImmobile;
                                if (immobileId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Imóvel não encontrado na conversa.'),
                                    ),
                                  );
                                  return;
                                }
                                final String rentalUrl = 'http://127.0.0.1:8000/api/rentals/rental-register/$immobileId/';
                                final Uri uri = Uri.parse(rentalUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Não foi possível abrir a página de registro de aluguel.'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green,
                                side: BorderSide(
                                  color: Colors.green.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                              child: const Text('Alugar'),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                          if (_userType == 'Proprietario') ...[
                            ElevatedButton(
                              onPressed: () async {
                                const String visitUrl = 'http://127.0.0.1:8000/api/visits/create-form/';
                                final Uri uri = Uri.parse(visitUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Não foi possível abrir a página de agendamento.'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green,
                                side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1.0),
                              ),
                              child: const Text('Marcar Visita'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } catch (e) {
            // If conversation not found, show error and pop
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversa não encontrada.')),
              );
              Navigator.pop(context);
            });
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
        },
      ),
    );
  }
}
