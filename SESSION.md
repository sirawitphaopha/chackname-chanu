# 🏫 เว็บเช็คชื่อเข้าเรียน ร.ร.ชานุมานวิทยาคม — session 2026-07-07

## ที่มา
- พี่กันเอา Google Sheet + Google Apps Script ของ **ระบบเช็คชื่อเข้าเรียน ร.ร.ชานุมานวิทยาคม** (ของคนอื่น พี่กันเอามาลองรีโครง/ศึกษา) มาให้ดู
- ระบบเดิม: Apps Script + Sheet เป็น DB, เข้ารหัสสถานะ `A1B2` (คาบ=A-I, สถานะ ม=1 ข=2 ส=3 ล=4 ป=5) ยัดหลายคาบในเซลล์เดียว, login รหัส 911 hardcode, แตะการ์ด**วน**เปลี่ยนสถานะ, บั๊กสี "มา"/"สาย"
- พี่กันสั่งรีโครงใหม่ทั้งหมด + เขียนโครง Supabase (ยังไม่เชื่อม) + ทำเป็นเว็บแอป (PWA)

## 🎉 ขึ้น GitHub แล้ว (push สำเร็จ 2026-07-07)
- **Repo: https://github.com/sirawitphaopha/chackname-chanu** (บัญชี sirawitphaopha)
- **commit 08df806** (initial, 8 ไฟล์) — commit message ละเอียดอธิบาย ระบบเดิม(GAS) → ระบบใหม่
- **commit 09a8f48** — เพิ่ม `SESSION.md` ในโฟลเดอร์ repo (สำเนา session นี้ ตัด email ออก) เพื่อ clone ไปทำต่อเครื่องอื่น — พี่กันบอกจะเอาไปทำเครื่องอื่น (⚠️ SESSION.md ในрепо ตอนนี้ยังไม่รวมงานหลัง commit นี้ ถ้าจะ sync เต็มต้องอัปเดต+push ใหม่)
- **commit ac4ac82** — popup ตั้งค่า + บังคับกรอกวิชา + เตือนก่อนรีโหลด + ปรับ UI มือถือ (รายละเอียดใน "ทำเสร็จ รอบ 2")
- เพิ่ม `.gitignore` (กัน .env/.key/server*.js/scratchpad), ปรับปรุง `README.md`, สร้าง `CLAUDE.md` (คู่มือ AI แก้โค้ด)
- push ผ่าน HTTPS + Git Credential Manager (token cache ไว้แล้ว) ได้เลย ไม่ต้องใช้ gh CLI (เครื่องไม่มี gh)
- ☁️ deploy ให้เพื่อนเปิด: **GitHub Pages** (Settings→Pages→branch main, /root) → `sirawitphaopha.github.io/chackname-chanu/` rebuild เองหลัง push ~1-2 นาที (static ไม่มี env/SQL) — พี่กันเปิด Pages แล้ว

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
- **เลย์เอาต์มือถือ (เฉพาะ `@media max-width:640px`)**: ฟอร์มจัด grid 2 คอลัมน์เท่ากัน (ค้นหา span เต็มแถวด้วย `.field.grow:has(#searchBox)`)

## ✅ ทำเสร็จ รอบ 2 (2026-07-07, commit ac4ac82 — เทสผ่านหมด)
**ฟีเจอร์ (ทั้งมือถือ+เดสก์ท็อป — เป็น logic):**
- **popup ตั้งค่าเริ่มต้น** เด้งทุกครั้งที่เข้าเว็บ: กรอก ชั้น/ห้อง/คาบ/วันที่(=วันนี้)/วิชา/รหัส → กด "เริ่มเช็คชื่อ" ส่งค่าไปหน้าหลัก+reload / "ข้าม"+X ปิดไปกรอกเอง | id: setupOverlay, suLevel/suRoom/suPeriod/suDate/suSubject/suCode, ปุ่ม setupStart/setupSkip/setupClose | clone options จาก select หลัก | เรียก openSetup() ท้าย init()
- **บังคับกรอกวิชา+รหัส** ก่อนเช็คชื่อ: ฟังก์ชัน `requireSubject()` → guard ใน openSheet + btnAllPresent + setupStart | ไม่กรอก = กรอบแดง (`.field-required`) + toast + บล็อก
- **เตือนก่อนรีโหลด/ปิด** (`beforeunload`) เฉพาะเมื่อ state.att ไม่ว่าง (เช็คไปแล้ว) — native dialog เทส automation ไม่ได้ พี่กันเทสเอง (เช็ค 1 คนแล้ว F5)
- เปลี่ยนปุ่ม **"มาทั้งห้อง" → "มาเข้าเรียนทั้งห้อง"** (btnAllPresent + toast) เทสมือถือปุ่มไม่เบียด (270<347px)

**UI เฉพาะมือถือ (`@media max-width:640px` — เดสก์ท็อปไม่แตะ):**
- header **2 แถว** (บน=โลโก้+ชื่อเว็บ / ล่าง=วันที่+นาฬิกากึ่งกลาง มีเส้นคั่น border-top)
- **ชื่อเว็บมือถือ 16px = เท่านาฬิกา** (พี่กันขอ) — ⚠️มี `header .title b` 2 ชุดใน 2 media block ต้องแก้ให้ตรงกันทั้งคู่ (ชุดหลังชนะ) | เดสก์ท็อป 24px (พี่กันชอบ ไม่แตะ)
- **ซ่อน legend** (`.legend{display:none}`) — สีอยู่บนการ์ดแล้ว (เปลี่ยนจากรอบแรกที่แค่จัดกึ่งกลาง)
- **ชื่อวิชาแถว 2 ตัวใหญ่** (พิลล์แดง 22px กึ่งกลาง): เติมคลาส `rt-dot-subj` ที่จุดคั่น + mobile `.rt-subj{flex-basis:100%}` ซ่อน dot | เดสก์ท็อปแถวเดียวเหมือนเดิม

## ⚠️ ค้างอยู่ — ทำต่อจากตรงนี้
1. ข้อมูลนักเรียนยัง mock 40 คน (ยังไม่เชื่อม Supabase จริง)
2. (ถ้าพี่กันอยาก sync เครื่องอื่นให้ครบ) `SESSION.md` ในrepoต้องอัปเดต+push ใหม่ทุกครั้งที่ทำงานเพิ่ม

## บทเรียนสำคัญ
- 🔴 (session ก่อน) แคลร์พิมพ์ tool call ผิด format (`count` แทน `antml:invoke`) ซ้ำๆ ตอนล้าง cache จนพี่กันสั่งหยุด → เช็ค format ทุกครั้ง
- 🔴 **ไฟล์ session เก่าเคยเขียนผิด** (บอกงานค้างทั้งที่ทำเสร็จ) เพราะแชทก่อน bug → session นี้พี่กันสั่งให้ไปอ่าน **แชทจริง** (transcript .jsonl) ไม่ใช่ session memory → ยืนยันไฟล์จริงเสมอเมื่อไม่ชัวร์
- พี่กันชอบเห็นผลจริงทันที (screenshot), feedback UI/UX ละเอียดต่อเนื่อง, ทำทีละขั้น
