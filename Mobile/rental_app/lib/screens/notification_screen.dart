import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart' as models;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _selectedFilter;
  final List<String> _filterOptions = ['Todas', 'Não lidas', 'Aluguel', 'Pagamento', 'Revisão', 'Geral'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.fetchNotifications().then((_) {
        print('🔍 Notificações carregadas: ${provider.notifications.length}');
      }).catchError((error) {
        print('❌ Erro ao carregar notificações: $error');
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
    if (_selectedFilter == null || _selectedFilter == 'Todas') {
      return notifications;
    } else if (_selectedFilter == 'Não lidas') {
      return notifications.where((n) => !n.isRead).toList();
    } else {
      String type = '';
      switch (_selectedFilter) {
        case 'Aluguel':
          type = 'RENTAL_REQUEST';
          break;
        case 'Pagamento':
          type = 'PAYMENT_RECEIVED';
          break;
        case 'Revisão':
          type = 'REVIEW_PENDING';
          break;
        case 'Geral':
          type = 'GENERAL';
          break;
      }
      return notifications.where((n) => n.type == type).toList();
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'RENTAL_REQUEST':
        return Icons.home;
      case 'PAYMENT_RECEIVED':
        return Icons.attach_money;
      case 'REVIEW_PENDING':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'RENTAL_REQUEST':
        return Colors.blue[700]!;
      case 'PAYMENT_RECEIVED':
        return Colors.green[700]!;
      case 'REVIEW_PENDING':
        return Colors.amber[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _getNotificationTypeText(String type) {
    switch (type) {
      case 'RENTAL_REQUEST':
        return 'Solicitação de Aluguel';
      case 'PAYMENT_RECEIVED':
        return 'Pagamento Recebido';
      case 'REVIEW_PENDING':
        return 'Revisão Pendente';
      default:
        return 'Notificação Geral';
    }
  }

  void _deleteNotification(int notificationId) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.deleteNotification(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<NotificationProvider>(context, listen: false);
              provider.fetchNotifications();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
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
            offset: Offset(0, 0),
            tooltip: '',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erro: ${provider.error}', textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => provider.fetchNotifications(),
                    child: Text('Tentar novamente'),
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
                  Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(message, style: TextStyle(fontSize: 16)),
                  if (provider.notifications.isNotEmpty)
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.green),
                      onPressed: () {
                        setState(() {
                          _selectedFilter = null;
                        });
                      },
                      child: Text('Mostrar todas'),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            color: Colors.green,
            child: ListView.separated(
              physics: AlwaysScrollableScrollPhysics(),
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
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirmar Exclusão"),
                          content: Text("Deseja realmente excluir esta notificação?"),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.grey),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("Cancelar"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text("Excluir"),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(50),
                            blurRadius: 4,
                            offset: Offset(0, 2),
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
                          SizedBox(width: 12),
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
                                    SizedBox(width: 8),
                                    Text(
                                      notification.isRead ? 'Visto' : 'Não Visto',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: notification.isRead
                                            ? Colors.grey[600]
                                            : Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      _getNotificationTypeText(notification.type),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: notificationColor,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _formatDate(notification.createdAt),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
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
    );
  }

  Widget _buildNotificationDetails(models.Notification notification) {
    final notificationColor = _getNotificationColor(notification.type);
    return Container(
      padding: EdgeInsets.all(16),
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
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
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
                  SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () => Navigator.pop(context),
              child: Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}