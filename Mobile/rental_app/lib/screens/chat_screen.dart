import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import 'conversation_detail_screen.dart';
import 'search_immobile_screen.dart';
import 'tenant_profile_screen.dart';
import 'owner_profile_screen.dart';
import 'notification_screen.dart';
import 'unauthorized_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _userType;
  bool _isLoadingUserType = true;
  int _selectedIndex = 2;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final userType = await _secureStorage.read(key: 'user_type');
    setState(() {
      _userType = userType;
      _isLoadingUserType = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.fetchConversations().then((_) {
        print(' Conversas carregadas: ${provider.conversations.length}');
      }).catchError((error) {
        print(' Erro ao carregar conversas: $error');
      });
    });
  }

  String _formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('E, HH:mm').format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversas'),
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<ChatProvider>(context, listen: false);
              provider.fetchConversations();
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${provider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => provider.fetchConversations(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma conversa encontrada.', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchConversations(),
            color: Colors.green,
            child: ListView.separated(
              itemCount: provider.conversations.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final conversation = provider.conversations[index];
                final lastMessage = conversation.lastMessage;
                final isUnread = lastMessage != null && !lastMessage.isRead;

                String displayName = _userType == 'Proprietario'
                  ? conversation.tenant.name 
                  : conversation.owner.name; 

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withAlpha(50),
                    child: const Icon(Icons.chat, color: Colors.green),
                  ),
                  title: Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    lastMessage?.content ?? 'Nenhuma mensagem ainda',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lastMessage != null ? _formatDate(lastMessage.sentAt) : '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    if (lastMessage != null && !lastMessage.isRead) {
                      provider.markMessageAsRead(lastMessage.id);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationDetailScreen(
                          conversationId: conversation.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificações',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Conversas',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
            backgroundColor: Colors.green,
          ),
        ],
        backgroundColor: Colors.green[600],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SearchImmobileScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => NotificationProvider(),
                    child: const NotificationScreen(),
                  ),
                ),
              );
              break;
            case 2:
              break;
            case 3:
              if (_userType == 'Proprietario') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerProfileScreen()),
                );
              } else if (_userType == 'Inquilino') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TenantProfileScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const UnauthorizedScreen()),
                );
              }
              break;
          }
        },
      ),
    );
  }
}