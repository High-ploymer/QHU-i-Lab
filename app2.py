from flask import Flask, jsonify, request
from flask_cors import CORS
import pymssql
import datetime

app = Flask(__name__)
CORS(app)

# ---------------------------------------------------------
# 1. 数据库配置 (保持不变)
# ---------------------------------------------------------
DB_CONFIG = {
    'server': '192.168.36.103', # 请确认 IP
    'port': '3456',
    'user': 'qhulab',
    'password': 'qhulab', # 请确认密码
    'database': 'qhu_lab_system',
    'charset': 'utf8'
}

# --- 时间段映射配置 (前端 ID -> 具体时间) ---
SLOT_MAP = {
    '1': {'start': '08:00:00', 'end': '10:00:00'},
    '2': {'start': '10:00:00', 'end': '12:00:00'},
    '3': {'start': '14:00:00', 'end': '16:00:00'},
    '4': {'start': '16:00:00', 'end': '18:00:00'},
    '5': {'start': '19:00:00', 'end': '21:00:00'}
}

def get_db_connection():
    try:
        conn = pymssql.connect(
            server=DB_CONFIG['server'], user=DB_CONFIG['user'],
            password=DB_CONFIG['password'], database=DB_CONFIG['database'],
            port=DB_CONFIG['port'], charset=DB_CONFIG['charset'], as_dict=True
        )
        return conn
    except Exception as e:
        print(f"❌ DB Error: {e}")
        return None

# ---------------------------------------------------------
# 2. 基础接口
# ---------------------------------------------------------

# ---------------------------------------------------------
# 3. 核心业务接口 (对应前端新功能)
# ---------------------------------------------------------

# === [功能 A] 用户注册 ===
@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    # 提取字段
    username = data.get('username')
    password = data.get('password')
    real_name = data.get('real_name')
    dept = data.get('department')
    
    conn = get_db_connection()
    if not conn: return jsonify({"error": "DB Link Error"}), 500

    try:
        with conn.cursor() as cursor:
            # 1. 检查账号是否已存在
            cursor.execute("SELECT user_id FROM Users WHERE username=%s", (username,))
            if cursor.fetchone():
                return jsonify({"error": "该学号/工号已注册"}), 409
            
            # 2. 插入新用户 (默认角色为 Student)
            sql = """
                INSERT INTO Users (username, password, real_name, department, role)
                VALUES (%s, %s, %s, %s, 'Student')
            """
            cursor.execute(sql, (username, password, real_name, dept))
            conn.commit() # 提交事务
            return jsonify({"success": True, "message": "注册成功"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# === [功能 B] 用户登录 (保持原有逻辑) ===
@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    conn = get_db_connection()
    if not conn: return jsonify({"error": "DB Link Error"}), 500
    try:
        with conn.cursor() as cursor:
            # 兼容大小写匹配
            sql = "SELECT * FROM Users WHERE username=%s AND password=%s"
            cursor.execute(sql, (data['username'], data['password']))
            user = cursor.fetchone()
            
            if user:
                # 简单鉴权：检查角色是否匹配
                req_role = data.get('role', '').lower()
                db_role = user['role'].lower()
                if req_role == db_role:
                    return jsonify({"success": True, "user": user})
                else:
                    return jsonify({"error": "角色选择错误 (学生/管理员)"}), 401
            return jsonify({"error": "账号或密码错误"}), 401
    finally:
        conn.close()

# === [功能 C] 获取设备列表 ===
@app.route('/api/equipments', methods=['GET'])
def get_equipments():
    conn = get_db_connection()
    if not conn: return jsonify({"error": "DB Error"}), 500
    try:
        with conn.cursor() as cursor:
            # 获取所有设备，如果是Maintenance状态，这里会直接反映
            sql = """
                SELECT e.equip_id as id, e.equip_name as name, l.lab_name as lab,
                       e.status, e.category, e.detail_info as detail, e.icon_class as icon
                FROM Equipments e JOIN Labs l ON e.lab_id = l.lab_id
            """
            cursor.execute(sql)
            return jsonify(cursor.fetchall())
    finally:
        conn.close()

# === [功能 D] 查询某设备某天的占用情况 (核心难点) ===
@app.route('/api/availability', methods=['GET'])
def check_availability():
    equip_id = request.args.get('equipment_id')
    date_str = request.args.get('date') # 格式 YYYY-MM-DD
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 查询该设备在当天的所有有效预约
            # SQL Server 中用 CAST(start_time AS DATE) 提取日期
            # 增加 app_status 过滤，不包括 'Cancelled'
            sql = """
                SELECT start_time 
                FROM Appointments 
                WHERE equip_id = %s 
                  AND CAST(start_time AS DATE) = %s
                  AND app_status IN ('Pending', 'Approved')
            """
            cursor.execute(sql, (equip_id, date_str))
            rows = cursor.fetchall()
            
            booked_slots = []
            # 将数据库的时间转换回前端的 Slot ID
            for row in rows:
                t_start = row['start_time'].strftime('%H:%M:%S')
                # 遍历映射表反推 ID
                for sid, time_range in SLOT_MAP.items():
                    if time_range['start'] == t_start:
                        booked_slots.append(int(sid))
            
            return jsonify({"booked_slots": booked_slots})
    finally:
        conn.close()

# === [功能 E] 提交预约 ===
@app.route('/api/book', methods=['POST'])
def book_equipment():
    data = request.json
    user_id = data.get('user_id')
    equip_id = data.get('equipment_id')
    date_str = data.get('date')
    slot_id = str(data.get('slot_id')) # 转字符串以匹配字典键
    reason = data.get('reason')

    # 1. 时间转换
    if slot_id not in SLOT_MAP:
        return jsonify({"error": "无效的时间段"}), 400
    
    # 拼接完整的 datetime 字符串: '2025-12-12 08:00:00'
    start_dt = f"{date_str} {SLOT_MAP[slot_id]['start']}"
    end_dt = f"{date_str} {SLOT_MAP[slot_id]['end']}"

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 2. 再次检查冲突 (双重保险)
            # 排除已取消的预约
            check_sql = """
                SELECT COUNT(*) as cnt FROM Appointments 
                WHERE equip_id=%s AND start_time=%s AND app_status != 'Cancelled'
            """
            cursor.execute(check_sql, (equip_id, start_dt))
            if cursor.fetchone()['cnt'] > 0:
                return jsonify({"error": "手慢了！该时段刚刚已被抢占"}), 409

            # 3. 写入数据库
            insert_sql = """
                INSERT INTO Appointments (user_id, equip_id, start_time, end_time, purpose, app_status)
                VALUES (%s, %s, %s, %s, %s, 'Approved')
            """
            # 注：演示系统直接设为 Approved，真实系统可能设为 Pending
            cursor.execute(insert_sql, (user_id, equip_id, start_dt, end_dt, reason))
            
            # 4. 同时更新设备状态为 Booked (仅针对当前时段，这里简化逻辑：只要有预约就变黄)
            # cursor.execute("UPDATE Equipments SET status='Booked' WHERE equip_id=%s", (equip_id,))
            
            conn.commit()
            return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# === [功能 F] 获取我的申请列表 ===
@app.route('/api/my-bookings', methods=['GET'])
def my_bookings():
    user_id = request.args.get('user_id')
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 联表查询：预约表 + 设备表
            sql = """
                SELECT a.app_id, e.equip_name, a.start_time, a.app_status as status
                FROM Appointments a
                JOIN Equipments e ON a.equip_id = e.equip_id
                WHERE a.user_id = %s
                ORDER BY a.create_time DESC
            """
            cursor.execute(sql, (user_id,))
            rows = cursor.fetchall()
            
            # 数据加工：把时间转回前端易读格式
            result = []
            for row in rows:
                dt = row['start_time']
                date_str = dt.strftime('%Y-%m-%d')
                time_str = dt.strftime('%H:%M:%S')
                
                # 反推 Slot ID (用于前端显示文本)
                slot_id = 0
                for sid, r in SLOT_MAP.items():
                    if r['start'] == time_str:
                        slot_id = sid
                        break
                
                result.append({
                    "app_id": row['app_id'], # 必须返回 app_id 以便取消预约
                    "equip_name": row['equip_name'],
                    "booking_date": date_str,
                    "slot_id": slot_id,
                    "status": row['status']
                })
            return jsonify(result)
    finally:
        conn.close()

# === [新增功能 1] 取消预约 ===
@app.route('/api/cancel_booking', methods=['POST'])
def cancel_booking():
    data = request.json
    app_id = data.get('app_id')
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 1. 检查是否可以取消（例如只能取消 Pending 或 Approved 状态的预约）
            sql_check = "SELECT app_status FROM Appointments WHERE app_id=%s"
            cursor.execute(sql_check, (app_id,))
            result = cursor.fetchone()
            if not result:
                return jsonify({"error": "预约不存在"}), 404
            
            if result['app_status'] == 'Cancelled':
                 return jsonify({"error": "预约已取消，无需重复操作"}), 400

            # 2. 更新状态为 Cancelled
            sql_update = "UPDATE Appointments SET app_status='Cancelled' WHERE app_id=%s"
            cursor.execute(sql_update, (app_id,))
            conn.commit()
            return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

# === [新增功能 2] 系统概览数据 ===
@app.route('/api/dashboard_stats', methods=['GET'])
def dashboard_stats():
    conn = get_db_connection()
    if not conn: return jsonify({"error": "DB Error"}), 500
    try:
        with conn.cursor() as cursor:
            # 1. 总设备数
            cursor.execute("SELECT COUNT(*) as total FROM Equipments")
            total_equip = cursor.fetchone()['total']

            # 2. 当前可用 (假设 status='Available')
            cursor.execute("SELECT COUNT(*) as available FROM Equipments WHERE status='Available'")
            available_equip = cursor.fetchone()['available']

            # 3. 今日预约 (假设 create_time 为今天)
            today_str = datetime.date.today().strftime('%Y-%m-%d')
            cursor.execute("SELECT COUNT(*) as today_bookings FROM Appointments WHERE CAST(create_time AS DATE)=%s", (today_str,))
            today_bookings = cursor.fetchone()['today_bookings']

            # 4. 待维修 (假设 status='Maintenance')
            cursor.execute("SELECT COUNT(*) as maintenance FROM Equipments WHERE status='Maintenance'")
            maintenance_equip = cursor.fetchone()['maintenance']

            return jsonify({
                "total_equip": total_equip,
                "available_equip": available_equip,
                "today_bookings": today_bookings,
                "maintenance_equip": maintenance_equip
            })
    finally:
        conn.close()

#  [新增/修改] 提交报修单 (学生端)
@app.route('/api/report_repair', methods=['POST', 'OPTIONS'])
def report_repair():
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'}), 200
    data = request.json
    equip_id = data.get('equip_id')
    user_id = data.get('user_id')
    issue_desc = data.get('issue_desc')
    urgency = data.get('urgency')

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # === [新增功能 4] 检查是否重复报修 ===
            # 检查该设备是否有未处理（Pending）的报修单
            sql_check = "SELECT COUNT(*) as cnt FROM Repairs WHERE equip_id=%s AND status='Pending'"
            cursor.execute(sql_check, (equip_id,))
            if cursor.fetchone()['cnt'] > 0:
                 return jsonify({"error": "该设备已有人提交报修且尚未处理，请勿重复提交"}), 409

            # 1. 插入报修记录
            sql = """
                INSERT INTO Repairs (user_id, equip_id, issue_desc, urgency, status)
                VALUES (%s, %s, %s, %s, 'Pending')
            """
            cursor.execute(sql, (user_id, equip_id, issue_desc, urgency))
            
            # === [新增功能 3] 更新设备状态为 Maintenance ===
            cursor.execute("UPDATE Equipments SET status='Maintenance' WHERE equip_id=%s", (equip_id,))
            
            conn.commit()
            return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

#  [新增] 获取所有报修单 (管理员端)
@app.route('/api/admin/repairs', methods=['GET', 'OPTIONS'])
def get_all_repairs():
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'}), 200
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT r.repair_id, u.real_name as reporter, e.equip_name, 
                       r.issue_desc, r.urgency, r.status, r.report_date
                FROM Repairs r
                JOIN Users u ON r.user_id = u.user_id
                JOIN Equipments e ON r.equip_id = e.equip_id
                ORDER BY r.report_date DESC
            """
            cursor.execute(sql)
            return jsonify(cursor.fetchall())
    finally:
        conn.close()


#  [新增] 处理报修单 (管理员端)
@app.route('/api/admin/fix_repair', methods=['POST', 'OPTIONS'])
def fix_repair():
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'}), 200
    data = request.json
    repair_id = data.get('repair_id')
    reply = data.get('reply')
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 1. 更新报修单状态
            sql = """
                UPDATE Repairs 
                SET status='Fixed', fix_date=GETDATE(), admin_reply=%s 
                WHERE repair_id=%s
            """
            cursor.execute(sql, (reply, repair_id))
            
            # 2. 顺便把设备状态改回 'Available' (修复好了嘛)
            # 先查 equip_id
            cursor.execute("SELECT equip_id FROM Repairs WHERE repair_id=%s", (repair_id,))
            row = cursor.fetchone()
            if row:
                cursor.execute("UPDATE Equipments SET status='Available' WHERE equip_id=%s", (row['equip_id'],))
            
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()


@app.route('/')
def home():
    return f"<h1>后端已启动 (SQL Server版)</h1><p>目标: {DB_CONFIG['server']}</p >"

if __name__ == '__main__':
    print("-------------------------------------------------------")
    print(f"✅ 后端启动成功 | 端口: 5000 | 数据库: SQL Server")
    print("-------------------------------------------------------")
    app.run(debug=True, port=5000)