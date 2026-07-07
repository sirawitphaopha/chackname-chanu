# 🏫 เว็บเช็คชื่อเข้าเรียน ร.ร.ชานุมานวิทยาคม — session 2026-07-07

## ที่มา
- พี่กันเอา Google Sheet + Google Apps Script ของ **ระบบเช็คชื่อเข้าเรียน ร.ร.ชานุมานวิทยาคม** (ของคนอื่น พี่กันเอามาลองรีโครง/ศึกษา) มาให้ดู
- ระบบเดิม: Apps Script + Sheet เป็น DB, เข้ารหัสสถานะ `A1B2` (คาบ=A-I, สถานะ ม=1 ข=2 ส=3 ล=4 ป=5) ยัดหลายคาบในเซลล์เดียว, login รหัส 911 hardcode, แตะการ์ด**วน**เปลี่ยนสถานะ, บั๊กสี "มา"/"สาย"
- พี่กันสั่งรีโครงใหม่ทั้งหมด + เขียนโครง Supabase (ยังไม่เชื่อม) + ทำเป็นเว็บแอป (PWA)

## 🎉 ขึ้น GitHub แล้ว (push สำเร็จ 2026-07-07)
- **Repo: https://github.com/sirawitphaopha/chackname-chanu** (บัญชี sirawitphaopha)
- **commit 08df806** (initial, 8 ไฟล์) — commit message ละเอียดอธิบาย ระบบเดิม(GAS) → ระบบใหม่
- เพิ่ม `.gitignore` (กัน .env/.key/server*.js/scratchpad), ปรับปรุง `README.md`, สร้าง `CLAUDE.md` (คู่มือ AI แก้โค้ด)
- push ผ่าน HTTPS + Git Credential Manager (token cache ไว้แล้ว) ได้เลย ไม่ต้องใช้ gh CLI (เครื่องไม่มี gh)

## โฟลเดอร์และไฟล์
- **เว็บใหม่: `C:\Users\PKH\school-checkin-app\`** (เป็น git repo แล้ว)
  - `index.html` — เว็บทั้งหมด single file (787 บรรทัด: <style> + HTML + <script> vanilla JS)
  - `supabase-schema.sql` — ตาราง students, attendance (เก็บสถานะตรงๆ ไม่เข้ารหัส A1B2) + RLS template
  - `manifest.webmanifest`, `sw.js` (CACHE='checkin-v2'), `icon.svg` — PWA
  - `README.md`, `CLAUDE.md`
- ของเดิม (demo จำลอง GS): `C:\Users\PKH\school-checkin-demo\index.html`

## วิธีรันดูผล
- Node static server: scratchpad `server2.js` ชี้ school-checkin-app port **8790** (session ใหม่ต้อง start ใหม่ + server เก่าอาจค้าง port — curl เช็คก่อน) — Python ไม่มีในเครื่อง
- ⚠️ browser tool บล็อก file:// ต้องผ่าน localhost
- ⚠️ **Service Worker แคชหน้าเก่า** — แก้แล้วหน้าไม่เปลี่ยน ต้อง unregister SW + clear caches ผ่าน javascript_tool แล้ว navigate ใหม่ (หรือ bump sw.js CACHE version)
- ⚠️ **จอ browser นี้ dpr 0.75** (ปรับไม่ได้ เป็นค่าจอ ctrl+0 ไม่ช่วย) screenshot ปกติ ~1360px = เท่าจอ 768p พอดี
- 📱 **ดูมือถือจำลอง**: inject iframe width=390 src=/index.html ใน body (iframe viewport 390 = trigger @media มือถือจริง) แล้ว screenshot — resize_window ย่อ viewport ไม่ได้ (Chrome min width ~500)

## โครงระบบ (logic เว็บใหม่)
- สถานะ: `unmarked`(เทา=default), `present`, `absent`, `late`, `leave`, `sick` — เซ็ตผ่าน `data-status` บน `.scard`
- `DataService` 3 เมธอด getStudents/getAttendance/saveAttendance — ใช้ localStorage มี comment `===== SUPABASE (ยังไม่เปิดใช้) =====` เขียนโค้ดจริงพร้อมสลับ
- `persist()` = บันทึกอัตโนมัติ เรียกทุกครั้งที่เปลี่ยนสถานะ
- `buildMockStudents()` = นักเรียนจำลอง 40 คน/ห้อง, วิชาเก็บ key `subj_L_R_P`

## ☁️ Cloudflare deploy (ถ้าจะขึ้น) — ใช้ **Pages** ไม่ใช่ Worker
- เว็บนี้ static ไฟล์เดียว (ไม่มีโค้ดฝั่งเซิร์ฟเวอร์) → เบราว์เซอร์คุย Supabase ตรงๆ ด้วย anon key + RLS → **Cloudflare Pages** (preset None, build เว้นว่าง, output `/`) เหมือน Snake Game
- ต่างจาก TB Dashboard ที่ใช้ **Worker** เพราะเป็น Next.js มีโค้ดเซิร์ฟเวอร์ (service_role key ลับ, ส่งอีเมล Resend, admin) → เก็บ Supabase เหมือนกันแต่มีงานลับฝั่งเซิร์ฟเวอร์เลยต้อง Worker
- 🔑 ตัวตัดสิน Pages vs Worker = "เว็บมีโค้ดต้องรันฝั่งเซิร์ฟเวอร์ไหม" ไม่ใช่ "เก็บข้อมูลที่ไหน" — พี่กันบอกงานนี้แค่เทสเล่นๆ ให้เพื่อนเปิด

## ✅ ทำเสร็จ (ยืนยันเห็นผลจริงในเบราว์เซอร์แล้ว)
- ธีม teal, ฟอนต์ **Sarabun** อย่างเดียว (เลิกใช้ Prompt)
- การ์ดเทา "ยังไม่เช็ค" default, แตะการ์ด → bottom sheet เลือก 5 สถานะ
- ปุ่ม "มาทั้งห้อง" toggle (กด=ติ๊กทั้งห้อง/กดซ้ำ=ล้าง) ✅เทสแล้วทำงาน
- **บันทึกอัตโนมัติ (persist)** ✅เทสแล้ว: ติ๊ก→รีเฟรช→ค่ายังอยู่ (เอาปุ่มบันทึกออก แทนด้วยป้าย "💾 บันทึกอัตโนมัติ")
- ไอคอนแว่นขยาย 🔍, หัวข้อห้อง sticky, แบนเนอร์ + วันที่ไทย + นาฬิกาเรียลไทม์
- **การ์ด grid = `repeat(auto-fill, minmax(160px, 1fr))`** (เลิกใช้จำนวนคอลัมน์ตายตัว!) → มือถือ 2 / จอ 768p 7 / จอใหญ่ 8 คอลัมน์ ไม่บีบทุกจอ
  - เหตุ: เดิม repeat(8)@min-width:900 → จอช่วงกลาง 641-899px (จอ 768p พี่กัน) หลุดไปใช้ minmax(120) เลยบีบ
- ชื่อไม่ตัดกลางคำ (`overflow-wrap:break-word; word-break:normal`), badge "ยังไม่เช็ค" `white-space:nowrap` บรรทัดเดียว
- **เลย์เอาต์มือถือ (เฉพาะ `@media max-width:640px`)**: ฟอร์มจัด grid 2 คอลัมน์เท่ากัน (ค้นหา span เต็มแถวด้วย `.field.grow:has(#searchBox)`), แถบสถานะ legend จัดกึ่งกลาง + คำอธิบาย "แตะการ์ด..." ลงบรรทัดเดียวไม่มีกรอบ

## ⚠️ ค้างอยู่ — ทำต่อจากตรงนี้
1. **header มือถืออึดอัด** — ชื่อเว็บ "ระบบเช็คชื่อเข้าเรียน" ตก 2 บรรทัด + ชื่อโรงเรียนตก 3 บรรทัด เพราะวันที่+นาฬิกาขวา (white-space:nowrap) กินพื้นที่ครึ่งนึง — เสนอพี่กันแล้วว่าจะจัด header มือถือให้ชื่อได้เต็มบรรทัด ย้ายวันที่/นาฬิกาลงล่างหรือย่อ **รอพี่กันตอบว่าเอาไหม**
2. ข้อมูลนักเรียนยัง mock 40 คน (ยังไม่เชื่อม Supabase จริง)

## บทเรียนสำคัญ
- 🔴 (session ก่อน) แคลร์พิมพ์ tool call ผิด format (`count` แทน `antml:invoke`) ซ้ำๆ ตอนล้าง cache จนพี่กันสั่งหยุด → เช็ค format ทุกครั้ง
- 🔴 **ไฟล์ session เก่าเคยเขียนผิด** (บอกงานค้างทั้งที่ทำเสร็จ) เพราะแชทก่อน bug → session นี้พี่กันสั่งให้ไปอ่าน **แชทจริง** (transcript .jsonl) ไม่ใช่ session memory → ยืนยันไฟล์จริงเสมอเมื่อไม่ชัวร์
- พี่กันชอบเห็นผลจริงทันที (screenshot), feedback UI/UX ละเอียดต่อเนื่อง, ทำทีละขั้น
