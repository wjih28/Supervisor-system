-- جدول إعدادات المشرف
CREATE TABLE IF NOT EXISTS supervisor_settings (
    settings_id SERIAL PRIMARY KEY,
    id_sprvsr INTEGER REFERENCES supervisor(sprvsr_id) ON DELETE CASCADE,
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    weekly_reports BOOLEAN DEFAULT FALSE,
    language TEXT DEFAULT 'العربية',
    timezone TEXT DEFAULT 'توقيت عدن (GMT+3)',
    profile_image_url TEXT,
    phone_number TEXT,
    employee_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الدردشات (إذا لم يكن موجوداً)
CREATE TABLE IF NOT EXISTS chats (
    chat_id SERIAL PRIMARY KEY,
    id_group INTEGER REFERENCES groups(group_id) ON DELETE CASCADE,
    id_sprvsr INTEGER REFERENCES supervisor(sprvsr_id) ON DELETE CASCADE,
    last_message TEXT,
    last_message_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الرسائل
CREATE TABLE IF NOT EXISTS messages (
    message_id SERIAL PRIMARY KEY,
    id_chat INTEGER REFERENCES chats(chat_id) ON DELETE CASCADE,
    sender_id INTEGER, -- يمكن أن يكون معرف طالب أو مشرف
    sender_role TEXT, -- 'student' or 'supervisor'
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إضافة حقول مفقودة لجدول المجموعات (إذا لزم الأمر)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='groups' AND column_name='group_progress') THEN
        ALTER TABLE groups ADD COLUMN group_progress FLOAT DEFAULT 0.0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='groups' AND column_name='group_status') THEN
        ALTER TABLE groups ADD COLUMN group_status TEXT DEFAULT 'نشط';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='groups' AND column_name='current_stage') THEN
        ALTER TABLE groups ADD COLUMN current_stage TEXT DEFAULT 'المقترح';
    END IF;
END $$;
