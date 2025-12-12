# دليل المطور (Mobile App Developer Guide) - تحديث فلاتر قسم الوظائف

## نظرة عامة
تم تحديث هيكلة بيانات "قسم الوظائف" (`jobs`) لتعتمد على نظام **الأقسام الرئيسية والفرعية (Sections System)** بدلاً من الحقول النصية المنفصلة السابقة (Classification & Specialization).

### الهدف
- **التصنيف (Classification)** أصبح الآن **القسم الرئيسي (Main Section)**.
- **التخصص (Specialization)** أصبح الآن **القسم الفرعي (Sub Section)**.
- عند اختيار المستخدم "تصنيف" معين، يجب أن تظهر فقط "التخصصات" التابعة لهذا التصنيف.

---

## 1. جلب البيانات (API Endpoint)

لجلب قائمة التصنيفات والتخصصات الخاصة بالوظائف، استخدم الـ Endpoint التالي:

**GET** `/api/main-sections?category_slug=jobs`

### نموذج الاستجابة (Response Example):

```json
{
  "category": {
    "id": 15,
    "slug": "jobs",
    "name": "وظائف"
  },
  "main_sections": [
    {
      "id": 101,
      "category_id": 15,
      "name": "إدارة وسكرتارية",  // (هذا هو التصنيف)
      "sort_order": 1,
      "is_active": 1,
      "sub_sections": [
        {
          "id": 1001,
          "category_id": 15,
          "main_section_id": 101,
          "name": "مدير موارد بشرية", // (هذا هو التخصص)
          "sort_order": 1,
          "is_active": 1
        },
        {
          "id": 1002,
          "category_id": 15,
          "main_section_id": 101,
          "name": "سكرتارية",
          "sort_order": 2,
          "is_active": 1
        }
      ]
    },
    {
      "id": 102,
      "category_id": 15,
      "name": "طب وتمريض",
      "sort_order": 2,
      "is_active": 1,
      "sub_sections": [
        {
          "id": 2001,
          "category_id": 15,
          "main_section_id": 102,
          "name": "طبيب عام",
          "sort_order": 1,
          "is_active": 1
        },
        {
          "id": 2002,
          "category_id": 15,
          "main_section_id": 102,
          "name": "ممرض",
          "sort_order": 2,
          "is_active": 1
        }
      ]
    }
  ]
}
```

---

## 2. منطق العرض في التطبيق (UI Implementation)

### في شاشة الفلتر (Filter) أو إضافة إعلان (Create Listing):

1.  **حقل "التصنيف" (Classification):**
    *   قم بعرض `main_sections` كقائمة منسدلة (Dropdown).
    *   القيمة المرسلة للسيرفر: `main_section_id`.
    *   النص الظاهر للمستخدم: `name` (الخاص بالقسم الرئيسي).

2.  **حقل "التخصص" (Specialization):**
    *   يجب أن تكون هذه القائمة **معتمدة (Dependent)** على حقل التصنيف.
    *   عندما يختار المستخدم "تصنيف" (مثلاً: طب وتمريض)، قم بعرض `sub_sections` الموجودة داخل هذا الـ Object فقط.
    *   القيمة المرسلة للسيرفر: `sub_section_id`.
    *   النص الظاهر للمستخدم: `name` (الخاص بالقسم الفرعي).

---

## 3. إرسال البيانات (Submission Attributes)

عند إرسال طلب البحث أو إنشاء إعلان، استخدم المفاتيح التالية بدلاً من `job_category` و `specialization` القديمة:

| الحقل القديم | الحقل الجديد المطلوب | الوصف |
| :--- | :--- | :--- |
| `job_category` | **`main_section_id`** | رقم الـ ID للقسم الرئيسي المختار |
| `specialization` | **`sub_section_id`** | رقم الـ ID للقسم الفرعي المختار |

### مثال للـ Body في حالة إنشاء إعلان (Create):

```json
{
  "category_id": 15,
  "main_section_id": 102,   // طب وتمريض
  "sub_section_id": 2001,   // طبيب عام
  "title": "مطلوب طبيب عام لعيادة خاصة",
  "price": 5000,
  ...
}
```

### مثال للـ Query Params في حالة البحث (Search):

`GET /api/listings?category=jobs&main_section_id=102&sub_section_id=2001`

---

## الخلاصة
يجب إلغاء الاعتماد على `category-fields` (الحقول الديناميكية) الخاصة بـ `job_category` و `specialization` واستبدالها بمنطق الـ `Section` الموضح أعلاه لضمان ترابط البيانات بشكل صحيح.
