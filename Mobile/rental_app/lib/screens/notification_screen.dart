import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart' as models;
import 'send_notification_screen.dart';
import 'search_immobile_screen.dart';
import 'tenant_profile_screen.dart';
import 'chat_screen.dart'; 
import 'owner_profile_screen.dart';
import 'unauthorized_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _selectedFilter;
  String _searchTitle = '';
  String? _userType;
  bool _isLoadingUserType = true;
  int _selectedIndex = 1;
  final List<String> _filterOptions = ['Todas', 'Não lidas', 'Aluguel', 'Pagamento', 'Avaliação Recebida', 'Geral'];
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
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.fetchNotifications().then((_) {// print removido por segurança
      }).catchError((error) {// print removido por segurança
      });
    });
  }

  String _formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutos atrás';
      }
      return '${difference.inHours} horas atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    }
  }

  List<models.Notification> _getFilteredNotifications(List<models.Notification> notifications) {
    List<models.Notification> filtered = notifications;

    if (_searchTitle.isNotEmpty) {
      filtered = filtered.where((n) => n.title.toLowerCase().contains(_searchTitle.toLowerCase())).toList();
    }

    if (_selectedFilter != null && _selectedFilter != 'Todas') {
      if (_selectedFilter == 'Não lidas') {
        filtered = filtered.where((n) => !n.isRead).toList();
      } else {
        String type = '';
        switch (_selectedFilter) {
          case 'Aluguel':
            type = 'RENTED_CONFIRMATION';
            break;
          case 'Pagamento':
            type = 'PAYMENT_RECEIVED';
            break;
          case 'Avaliação Recebida':
            type = 'REVIEW_RECEIVED';
            break;
          case 'Geral':
            type = 'GENERAL';
            break;
        }
        filtered = filtered.where((n) => n.type == type).toList();
      }
    }

    return filtered;
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'RENTED_CONFIRMATION':
        return Icons.home;
      case 'PAYMENT_RECEIVED':
        return Icons.attach_money;
      case 'REVIEW_RECEIVED':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'RENTED_CONFIRMATION':
        return Colors.blue[700]!;
      case 'PAYMENT_RECEIVED':
        return Colors.green[700]!;
      case 'REVIEW_RECEIVED':
        return Colors.amber[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _getNotificationTypeText(String type) {
    switch (type) {
      case 'RENTED_CONFIRMATION':
        return 'Confirmação de Aluguel';
      case 'PAYMENT_RECEIVED':
        return 'Pagamento Recebido';
      case 'REVIEW_RECEIVED':
        return 'Avaliação Recebida';
      default:
        return 'Notificação Geral';
    }
  }

  void _deleteNotification(int notificationId) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.deleteNotification(notificationId);
  }

  Widget _buildNotificationDetails(models.Notification notification) {
    final notificationColor = _getNotificationColor(notification.type);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: notificationColor.withAlpha(50),
                child: Icon(_getNotificationIcon(notification.type), color: notificationColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 24, color: Colors.grey[300]),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getNotificationTypeText(notification.type),
                    style: TextStyle(
                      fontSize: 14,
                      color: notificationColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<NotificationProvider>(context, listen: false);
              provider.fetchNotifications();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Filtrar por título...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchTitle = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list, size: 20),
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value == 'Todas' ? null : value;
                        });
                      },
                      itemBuilder: (context) {
                        return _filterOptions.map((option) {
                          return PopupMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList();
                      },
                      position: PopupMenuPosition.under,
                      tooltip: '',
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isLoadingUserType && _userType == 'Proprietario')
                  IconButton(
                    icon: const Icon(Icons.send, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SendNotificationScreen(),
                        ),
                      );
                    },
                    tooltip: 'Enviar Notificação',
                  ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<NotificationProvider>(
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
                          onPressed: () => provider.fetchNotifications(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredNotifications = _getFilteredNotifications(provider.notifications);

                if (filteredNotifications.isEmpty) {
                  String message = provider.notifications.isNotEmpty
                      ? 'Nenhuma notificação corresponde ao filtro selecionado.'
                      : 'Nenhuma notificação encontrada.';

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(message, style: const TextStyle(fontSize: 16)),
                        if (provider.notifications.isNotEmpty)
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: Colors.green),
                            onPressed: () {
                              setState(() {
                                _selectedFilter = null;
                                _searchTitle = '';
                              });
                            },
                            child: const Text('Mostrar todas'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchNotifications(),
                  color: Colors.green,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      final notificationIcon = _getNotificationIcon(notification.type);
                      final notificationColor = _getNotificationColor(notification.type);

                      return Dismissible(
                        key: Key(notification.id.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmar Exclusão"),
                                content: const Text("Deseja realmente excluir esta notificação?"),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Excluir"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          _deleteNotification(notification.id);
                        },
                        child: InkWell(
                          onTap: () {
                            if (!notification.isRead) {
                              provider.markAsRead(notification.id);
                            }
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => _buildNotificationDetails(notification),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(50),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: notificationColor.withAlpha(50),
                                  child: Icon(notificationIcon, color: notificationColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: !notification.isRead
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: !notification.isRead
                                                    ? Colors.black87
                                                    : Colors.grey[800],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            notification.isRead ? 'Visto' : 'Não Visto',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            _getNotificationTypeText(notification.type),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: notificationColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDate(notification.createdAt),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notification.message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: !notification.isRead
                                              ? Colors.black87
                                              : Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SearchImmobileScreen()));
              break;
            case 1:
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
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
            default:
              break;
          }
        },
      ),
    );
  }
}