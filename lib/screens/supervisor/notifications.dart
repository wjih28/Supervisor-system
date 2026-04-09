import 'package:flutter/material.dart';
import '../../models/models.dart'
    as app_models;

class Notifications extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;

  const Notifications({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
  });

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<app_models.Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      // جلب الإشعارات من قاعدة البيانات
      // ملاحظة: هذا يفترض وجود جدول notifications في Supabase
      // إذا لم يكن موجوداً، يمكن استخدام بيانات تجريبية مؤقتاً

      // _notifications = await SupabaseService.getNotifications(widget.supervisorId);

      // بيانات تجريبية مؤقتة (للتجربة)
      await Future.delayed(const Duration(milliseconds: 500));
      _notifications = [
        app_models.Notification(
          id: 1,
          title: 'ملاحظة جديدة',
          message:
              'قام الطالب أحمد برفع خطة البحث الخاصة بمشروعه "تأثير التسويق الرقمي"',
          supervisorId: widget.supervisorId,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        app_models.Notification(
          id: 2,
          title: 'موعد تسليم',
          message:
              'باقي 3 أيام على الموعد النهائي لتسليم البحث النهائي لمشروع إدارة الموارد البشرية',
          supervisorId: widget.supervisorId,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        app_models.Notification(
          id: 3,
          title: 'طلب مراجعة',
          message:
              'الطالبة سارة علي تطلب مراجعة الدراسة الميدانية لمشروع الذكاء الاصطناعي',
          supervisorId: widget.supervisorId,
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        app_models.Notification(
          id: 4,
          title: 'تحديث حالة',
          message:
              'تم تغيير حالة مشروع "إدارة الموارد البشرية" إلى "قيد التنفيذ"',
          supervisorId: widget.supervisorId,
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        app_models.Notification(
          id: 5,
          title: 'تذكير',
          message: 'غداً اجتماع مناقشة خطة البحث مع الطلاب',
          supervisorId: widget.supervisorId,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];
    } catch (e) {
      debugPrint('خطأ في تحميل الإشعارات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      // تحديث حالة الإشعار في قاعدة البيانات
      // await SupabaseService.markNotificationAsRead(notificationId);

      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = app_models.Notification(
            id: _notifications[index].id,
            title: _notifications[index].title,
            message: _notifications[index].message,
            supervisorId: _notifications[index].supervisorId,
            isRead: true,
            createdAt: _notifications[index].createdAt,
          );
        }
      });
    } catch (e) {
      debugPrint('خطأ في تحديث حالة الإشعار: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // تحديث جميع الإشعارات في قاعدة البيانات
      // await SupabaseService.markAllNotificationsAsRead(widget.supervisorId);

      setState(() {
        _notifications = _notifications
            .map((n) => app_models.Notification(
                  id: n.id,
                  title: n.title,
                  message: n.message,
                  supervisorId: n.supervisorId,
                  isRead: true,
                  createdAt: n.createdAt,
                ))
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعليم جميع الإشعارات كمقروءة')),
      );
    } catch (e) {
      debugPrint('خطأ في تعليم الإشعارات كمقروءة: $e');
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      // حذف الإشعار من قاعدة البيانات
      // await SupabaseService.deleteNotification(notificationId);

      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الإشعار')),
      );
    } catch (e) {
      debugPrint('خطأ في حذف الإشعار: $e');
    }
  }

  int get _unreadCount {
    return _notifications.where((n) => n.isRead == false).length;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.year}/${date.month}/${date.day}';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'قبل $weeks أسبوع';
    } else if (difference.inDays > 0) {
      return 'قبل ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'قبل ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'قبل ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  IconData _getNotificationIcon(app_models.Notification notification) {
    if (notification.title.contains('ملاحظة') ||
        notification.title.contains('مراجعة')) {
      return Icons.comment;
    } else if (notification.title.contains('موعد') ||
        notification.title.contains('تذكير')) {
      return Icons.alarm;
    } else if (notification.title.contains('تحديث') ||
        notification.title.contains('حالة')) {
      return Icons.update;
    }
    return Icons.notifications;
  }

  Color _getNotificationColor(app_models.Notification notification) {
    if (notification.isRead == false) {
      return const Color(0xFF2D62ED);
    }
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'تعليم الكل كمقروء',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (_unreadCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        color: const Color(0xFF2D62ED).withOpacity(0.1),
                        child: Text(
                          'لديك $_unreadCount إشعار غير مقروء',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF2D62ED),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر لك الإشعارات هنا عند استلامها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(app_models.Notification notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id!);
      },
      child: GestureDetector(
        onTap: () {
          if (notification.isRead == false) {
            _markAsRead(notification.id!);
          }
          // يمكن إضافة تنقل إلى صفحة معينة حسب نوع الإشعار
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead == false
                ? const Color(0xFF2D62ED).withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead == false
                  ? const Color(0xFF2D62ED).withOpacity(0.3)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // غير مقروء نقطة
              if (notification.isRead == false)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D62ED),
                    shape: BoxShape.circle,
                  ),
                ),
              // المحتوى
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getNotificationIcon(notification),
                            size: 20,
                            color: _getNotificationColor(notification),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead == false
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: notification.isRead == false
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead == false
                            ? Colors.grey.shade800
                            : Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // أيقونة
              Icon(
                Icons.notifications_outlined,
                color: notification.isRead == false
                    ? const Color(0xFF2D62ED)
                    : Colors.grey.shade400,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
