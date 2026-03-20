# توثيق نظام المشرف - منصة إدارة ومتابعة بحوث التخرج

## نظرة عامة

تم تطوير نظام المشرف (Supervisor System) كجزء متكامل من منصة إدارة ومتابعة بحوث التخرج. يوفر النظام للمشرفين الأكاديميين أدوات شاملة لإدارة ومراقبة مشاريع التخرج المسندة إليهم.

---

## 1. المميزات الرئيسية

### 1.1 لوحة التحكم الرئيسية (Supervisor Dashboard)

#### المكونات:
- **رسالة الترحيب الشخصية**: تحية المشرف باسمه والترحيب به
- **الإحصائيات الشاملة**:
  - إجمالي عدد المجموعات المسندة
  - عدد المشاريع المكتملة
  - عدد المشاريع قيد التنفيذ
  - عدد المشاريع المتأخرة
  - معدل الإنجاز الكلي
  - متوسط التقدم

#### الميزات:
- **البحث والتصفية**:
  - شريط بحث لإيجاد المجموعات بسرعة
  - تصفية حسب حالة المشروع (الكل، قيد التنفيذ، مكتملة، متأخرة)
  
- **عرض المجموعات**:
  - بطاقات تفصيلية لكل مجموعة
  - عرض اسم المشروع والوصف
  - شريط تقدم مرئي
  - حالة المشروع الحالية
  - تاريخ آخر تحديث
  - زر "عرض التفاصيل" للمزيد من المعلومات

- **التحديث الفوري**:
  - زر تحديث يدوي
  - دعم سحب لأسفل للتحديث
  - تحديث تلقائي للبيانات

### 1.2 تفاصيل المجموعة

عند الضغط على "عرض التفاصيل"، يتم عرض:
- اسم المجموعة الكامل
- الوصف التفصيلي
- الحالة الحالية
- نسبة التقدم
- تاريخ آخر تحديث

---

## 2. النماذج (Models)

### 2.1 ResearchGroup
```dart
class ResearchGroup {
  final int? id;
  final String name;
  final int? supervisorId;
  final int? stateId;
  final int? leaderId;
  final String? description;
  final double? progress;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

**الحقول**:
- `id`: معرف المجموعة الفريد
- `name`: اسم المشروع
- `supervisorId`: معرف المشرف
- `stateId`: معرف حالة المجموعة
- `leaderId`: معرف قائد المجموعة
- `description`: وصف المشروع
- `progress`: نسبة التقدم (0.0 - 1.0)
- `status`: حالة المشروع (pending, in_progress, completed, delayed)
- `createdAt`: تاريخ الإنشاء
- `updatedAt`: تاريخ آخر تحديث

### 2.2 ResearchFile
```dart
class ResearchFile {
  final int? id;
  final int? groupId;
  final String fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final String? description;
  final String? stage;
}
```

**الحقول**:
- `id`: معرف الملف الفريد
- `groupId`: معرف المجموعة المرتبطة
- `fileName`: اسم الملف
- `fileUrl`: رابط الملف
- `fileType`: نوع الملف (pdf, docx, etc.)
- `fileSize`: حجم الملف بالبايت
- `uploadedBy`: من قام برفع الملف
- `uploadedAt`: تاريخ الرفع
- `description`: وصف الملف
- `stage`: المرحلة المتعلقة بالملف

### 2.3 ReviewComment
```dart
class ReviewComment {
  final int? id;
  final int? groupId;
  final int? supervisorId;
  final String comment;
  final String? commentType;
  final int? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isResolved;
}
```

**الحقول**:
- `id`: معرف التعليق الفريد
- `groupId`: معرف المجموعة
- `supervisorId`: معرف المشرف
- `comment`: نص التعليق
- `commentType`: نوع التعليق (note, suggestion, issue)
- `rating`: التقييم (1-5)
- `createdAt`: تاريخ الإنشاء
- `updatedAt`: تاريخ آخر تحديث
- `isResolved`: هل تم حل المشكلة

### 2.4 ProjectStage
```dart
class ProjectStage {
  final int? id;
  final int? groupId;
  final String stageName;
  final String? description;
  final bool? isCompleted;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final double? completionPercentage;
  final String? status;
}
```

### 2.5 Notification
```dart
class Notification {
  final int? id;
  final int? supervisorId;
  final String title;
  final String? message;
  final String? notificationType;
  final int? relatedGroupId;
  final bool? isRead;
  final DateTime? createdAt;
}
```

---

## 3. الخدمات (Services)

### 3.1 SupabaseService

#### وظائف المجموعات:

**جلب المجموعات المسندة للمشرف**
```dart
static Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId)
```

**جلب تفاصيل مجموعة معينة**
```dart
static Future<ResearchGroup?> getGroupDetails(int groupId)
```

**تحديث حالة المجموعة**
```dart
static Future<bool> updateGroupStatus(int groupId, String status, double progress)
```

#### وظائف الملفات:

**جلب الملفات المرفوعة لمجموعة**
```dart
static Future<List<ResearchFile>> getFilesByGroup(int groupId)
```

**جلب الملفات حسب المرحلة**
```dart
static Future<List<ResearchFile>> getFilesByStage(int groupId, String stage)
```

**تحميل ملف جديد**
```dart
static Future<bool> uploadFile(ResearchFile file)
```

#### وظائف الملاحظات:

**جلب الملاحظات**
```dart
static Future<List<ReviewComment>> getCommentsByGroup(int groupId)
```

**إضافة ملاحظة جديدة**
```dart
static Future<bool> addComment(ReviewComment comment)
```

**تحديث ملاحظة**
```dart
static Future<bool> updateComment(int commentId, ReviewComment comment)
```

**حذف ملاحظة**
```dart
static Future<bool> deleteComment(int commentId)
```

#### وظائف المراحل:

**جلب مراحل المشروع**
```dart
static Future<List<ProjectStage>> getProjectStages(int groupId)
```

**تحديث حالة المرحلة**
```dart
static Future<bool> updateStageStatus(int stageId, String status, double completionPercentage)
```

#### وظائف الإشعارات:

**جلب الإشعارات**
```dart
static Future<List<Notification>> getNotifications(int supervisorId, {bool unreadOnly = false})
```

**تحديد الإشعار كمقروء**
```dart
static Future<bool> markNotificationAsRead(int notificationId)
```

**إنشاء إشعار جديد**
```dart
static Future<bool> createNotification(Notification notification)
```

#### وظائف الإحصائيات:

**جلب إحصائيات المشرف**
```dart
static Future<Map<String, dynamic>?> getSupervisorStatistics(int supervisorId)
```

يعيد:
- `totalGroups`: إجمالي المجموعات
- `completedGroups`: المجموعات المكتملة
- `inProgressGroups`: المجموعات قيد التنفيذ
- `delayedGroups`: المجموعات المتأخرة
- `averageProgress`: متوسط التقدم
- `completionRate`: معدل الإنجاز

#### وظائف البحث والتصفية:

**البحث عن مجموعات**
```dart
static Future<List<ResearchGroup>> searchGroups(int supervisorId, String searchTerm)
```

**تصفية المجموعات حسب الحالة**
```dart
static Future<List<ResearchGroup>> filterGroupsByStatus(int supervisorId, String status)
```

---

## 4. جداول قاعدة البيانات (Supabase)

### 4.1 جدول groups
```sql
- group_id (INTEGER, PRIMARY KEY)
- group_name (VARCHAR)
- id_sprvsr (INTEGER, FOREIGN KEY)
- id_group_state (INTEGER)
- group_led_id (INTEGER)
- group_description (TEXT)
- group_progress (FLOAT)
- group_status (VARCHAR)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### 4.2 جدول research_files
```sql
- file_id (INTEGER, PRIMARY KEY)
- id_group (INTEGER, FOREIGN KEY)
- file_name (VARCHAR)
- file_url (VARCHAR)
- file_type (VARCHAR)
- file_size (INTEGER)
- uploaded_by (VARCHAR)
- uploaded_at (TIMESTAMP)
- file_description (TEXT)
- file_stage (VARCHAR)
```

### 4.3 جدول review_comments
```sql
- comment_id (INTEGER, PRIMARY KEY)
- id_group (INTEGER, FOREIGN KEY)
- id_sprvsr (INTEGER, FOREIGN KEY)
- comment_text (TEXT)
- comment_type (VARCHAR)
- comment_rating (INTEGER)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- is_resolved (BOOLEAN)
```

### 4.4 جدول project_stages
```sql
- stage_id (INTEGER, PRIMARY KEY)
- id_group (INTEGER, FOREIGN KEY)
- stage_name (VARCHAR)
- stage_description (TEXT)
- is_completed (BOOLEAN)
- start_date (TIMESTAMP)
- end_date (TIMESTAMP)
- due_date (TIMESTAMP)
- completion_percentage (FLOAT)
- stage_status (VARCHAR)
```

### 4.5 جدول notifications
```sql
- notification_id (INTEGER, PRIMARY KEY)
- id_sprvsr (INTEGER, FOREIGN KEY)
- notification_title (VARCHAR)
- notification_message (TEXT)
- notification_type (VARCHAR)
- id_group (INTEGER, FOREIGN KEY)
- is_read (BOOLEAN)
- created_at (TIMESTAMP)
```

---

## 5. تدفق العمل

### 5.1 تسجيل الدخول
1. يدخل المشرف بيانات تسجيل الدخول
2. يتم التحقق من البيانات عبر `SupabaseService.login()`
3. إذا كان الدور "supervisor"، يتم الانتقال إلى `SupervisorDashboard`
4. يتم تمرير كائن `Supervisor` إلى الواجهة

### 5.2 عرض المجموعات
1. عند فتح لوحة التحكم، يتم استدعاء `getGroupsBySupervisor()`
2. يتم عرض الإحصائيات عبر `getSupervisorStatistics()`
3. يتم عرض المجموعات في قائمة قابلة للتمرير
4. يمكن البحث والتصفية من خلال الواجهة

### 5.3 عرض تفاصيل المجموعة
1. عند الضغط على مجموعة، يتم عرض نافذة منبثقة
2. يتم عرض المعلومات الأساسية للمجموعة
3. يمكن الضغط على "عرض التفاصيل" للمزيد

### 5.4 إضافة ملاحظة
1. المشرف يكتب ملاحظة على المجموعة
2. يتم استدعاء `addComment()`
3. يتم حفظ الملاحظة في قاعدة البيانات
4. يتم تحديث الواجهة

---

## 6. حالات المشروع

| الحالة | الوصف |
|--------|-------|
| `pending` | قيد الانتظار - لم يبدأ المشروع بعد |
| `in_progress` | قيد التنفيذ - المشروع جاري |
| `completed` | مكتملة - تم إنهاء المشروع بنجاح |
| `delayed` | متأخرة - تجاوز الموعد النهائي |

---

## 7. أنواع الملاحظات

| النوع | الوصف |
|--------|-------|
| `note` | ملاحظة عامة |
| `suggestion` | اقتراح أو توصية |
| `issue` | مشكلة تحتاج إلى حل |

---

## 8. أنواع الإشعارات

| النوع | الوصف |
|--------|-------|
| `file_upload` | تم رفع ملف جديد |
| `comment` | تم إضافة تعليق جديد |
| `deadline` | تنبيه بقرب الموعد النهائي |
| `status_change` | تم تغيير حالة المشروع |

---

## 9. التعديلات والتحسينات المستقبلية

### المخطط:
- [ ] إضافة صفحة تفاصيل شاملة للمجموعة
- [ ] تطوير نظام الملاحظات المتقدم
- [ ] إضافة نظام التقييم والدرجات
- [ ] تطوير نظام الإشعارات الفورية
- [ ] إضافة تقارير وإحصائيات متقدمة
- [ ] دعم تحميل وتنزيل الملفات
- [ ] إضافة جدولة المقابلات والاجتماعات
- [ ] تطوير نظام الرسائل المباشرة
- [ ] إضافة نسخ احتياطية تلقائية
- [ ] تحسين الأداء والسرعة

---

## 10. متطلبات التشغيل

### المكتبات المطلوبة:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  flutter_dotenv: ^5.1.0
```

### متغيرات البيئة (.env):
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

---

## 11. الدعم والمساعدة

للإبلاغ عن مشاكل أو طلب ميزات جديدة، يرجى التواصل مع فريق التطوير.

---

**آخر تحديث**: 18 مارس 2026
**الإصدار**: 1.0.0
