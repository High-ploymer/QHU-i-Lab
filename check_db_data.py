#!/usr/bin/env python3
"""
检查数据库中的测试数据
"""

import pymssql

# 数据库配置 (与app2.py一致)
DB_CONFIG = {
    'server': '192.168.199.103',
    'port': '3456',
    'user': 'qhulab',
    'password': 'qhulab',
    'database': 'qhu_lab_system',
    'charset': 'utf8'
}

def check_test_data():
    print("=== 检查数据库测试数据 ===")

    try:
        conn = pymssql.connect(**DB_CONFIG, as_dict=True)
        cursor = conn.cursor()

        # 检查用户
        cursor.execute("SELECT user_id, username, real_name, role FROM Users WHERE user_id = 1")
        user = cursor.fetchone()
        if user:
            print(f"✅ 用户存在: ID={user['user_id']}, 用户名={user['username']}, 姓名={user['real_name']}, 角色={user['role']}")
        else:
            print("❌ 用户ID=1不存在，请先创建测试用户")

        # 检查设备
        cursor.execute("SELECT TOP 5 equip_id, equip_name FROM Equipments")
        equips = cursor.fetchall()
        if equips:
            print("✅ 设备列表 (前5个):")
            for equip in equips:
                print(f"  - ID={equip['equip_id']}, 名称={equip['equip_name']}")
            # 使用第一个设备ID作为测试
            test_equip_id = equips[0]['equip_id']
        else:
            print("❌ 没有设备数据，请先插入设备")
            test_equip_id = None

        # 检查报修表结构
        cursor.execute("""
            SELECT COLUMN_NAME, DATA_TYPE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = 'Repairs'
            ORDER BY ORDINAL_POSITION
        """)
        columns = cursor.fetchall()
        print("📋 Repairs表结构:")
        for col in columns:
            print(f"  - {col['COLUMN_NAME']}: {col['DATA_TYPE']}")

        conn.close()

    except Exception as e:
        print(f"❌ 数据库连接错误: {e}")

if __name__ == "__main__":
    check_test_data()