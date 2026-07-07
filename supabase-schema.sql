-- ============================================================
--  ระบบเช็คชื่อเข้าเรียน — โครงสร้างฐานข้อมูล Supabase
--  แปลงจากระบบเดิม (Google Sheet + รหัส A1B2) มาเก็บ "ตรงๆ"
--  รันไฟล์นี้ใน Supabase > SQL Editor เมื่อพร้อมเชื่อมจริง
-- ============================================================

-- ---------- ตารางนักเรียน ----------
create table if not exists students (
  id          bigint generated always as identity primary key,
  classroom   int  not null,          -- ระดับชั้น ม. (1-6)
  room        int  not null,          -- ห้อง (1-17)
  number      int  not null,          -- เลขที่
  prefix      text,                   -- คำนำหน้า (เด็กชาย/เด็กหญิง/นาย/นางสาว)
  full_name   text not null,          -- ชื่อ-สกุลเต็ม
  created_at  timestamptz default now(),
  unique (classroom, room, number)    -- กันเลขที่ซ้ำในห้องเดียวกัน
);

-- ---------- ตารางการเช็คชื่อ ----------
-- เก็บ 1 แถว = นักเรียน 1 คน / 1 วัน / 1 คาบ  (ไม่ต้องเข้ารหัสอีกต่อไป)
create table if not exists attendance (
  id              bigint generated always as identity primary key,
  classroom       int  not null,
  room            int  not null,
  student_number  int  not null,      -- เลขที่ (อ้างกับ students.number)
  date            date not null,      -- วันที่เช็ค
  period          int  not null,      -- คาบเรียน (1-9)
  status          text not null       -- present / absent / late / leave / sick
                  check (status in ('present','absent','late','leave','sick')),
  recorded_by     text,               -- ครูผู้บันทึก (อีเมล/ชื่อ)
  recorded_at     timestamptz default now(),
  -- กันบันทึกซ้ำ: 1 คน 1 วัน 1 คาบ มีได้แถวเดียว (อัปเดตทับได้)
  unique (classroom, room, student_number, date, period)
);

-- ---------- ดัชนีช่วยให้ค้นเร็ว ----------
create index if not exists idx_att_lookup on attendance (classroom, room, date, period);
create index if not exists idx_att_student on attendance (classroom, room, student_number, date);

-- ============================================================
--  ตัวอย่างการใช้งาน (ข้อดีของการเก็บตรงๆ — สั่งครั้งเดียวได้เลย)
-- ============================================================

-- 1) ดึงผลเช็คชื่อของห้อง ม.1/6 วันนี้ คาบ 1
-- select student_number, status from attendance
-- where classroom=1 and room=6 and date='2026-07-07' and period=1;

-- 2) นับว่านักเรียนเลขที่ 5 ห้อง ม.1/6 "ขาด" กี่ครั้งในเดือนนี้
-- select count(*) from attendance
-- where classroom=1 and room=6 and student_number=5
--   and status='absent' and date >= '2026-07-01' and date < '2026-08-01';

-- 3) สรุปจำนวนแต่ละสถานะของห้อง ม.1/6 วันนี้ คาบ 1
-- select status, count(*) from attendance
-- where classroom=1 and room=6 and date='2026-07-07' and period=1
-- group by status;

-- ============================================================
--  RLS (ระบบกั้นสิทธิ์ข้อมูล) — เปิดใช้ก่อนขึ้นจริงเสมอ
--  *** ตัวอย่างด้านล่างเปิดให้ทุกคนที่ล็อกอินอ่าน/เขียนได้ ***
--  *** ของจริงควรจำกัดตามบทบาทครู/โรงเรียน ก่อนใช้งานจริง ***
-- ============================================================
-- alter table students   enable row level security;
-- alter table attendance enable row level security;
-- create policy "authenticated read"  on attendance for select using (auth.role() = 'authenticated');
-- create policy "authenticated write" on attendance for insert with check (auth.role() = 'authenticated');
-- create policy "authenticated update" on attendance for update using (auth.role() = 'authenticated');
