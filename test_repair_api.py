#!/usr/bin/env python3
"""
测试脚本：验证学生端报修提交和管理员端报修查看的数据传输
运行前请确保后端服务器 (app2.py) 已启动
"""

import requests
import json
import time

# 后端服务器地址
API_BASE = "http://127.0.0.1:5000"

def check_server():
    """检查后端服务器是否运行"""
    print("=== 检查后端服务器状态 ===")
    try:
        response = requests.get(f"{API_BASE}/", timeout=5)
        if response.status_code == 200:
            print("✅ 后端服务器运行正常")
            return True
        else:
            print(f"❌ 服务器响应异常: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
            print(f"❌ 无法连接到服务器: {e}")
            print("请确保运行: python app2.py")
            return False
    
def test_report_repair():
        """测试学生提交报修"""
        print("=== 测试学生提交报修 ===")
    
        # 模拟学生数据 (假设 user_id=1, equip_id=201)
        repair_data = {
            "user_id": 1,  # 管理员用户
            "equip_id": 201,  # 使用存在的设备ID
            "issue_desc": "测试报修：设备无法开机",
            "urgency": "Normal"
        }
    
        try:
            response = requests.post(f"{API_BASE}/api/report_repair", json=repair_data)
            if response.status_code == 200:
                print("✅ 报修提交成功")
                return True
            else:
                print(f"❌ 报修提交失败: {response.status_code} - {response.text}")
                return False
        except Exception as e:
            print(f"❌ 网络错误: {e}")
            return False

def test_get_repairs():
    """测试管理员获取报修列表"""
    print("\n=== 测试管理员获取报修列表 ===")

    try:
        response = requests.get(f"{API_BASE}/api/admin/repairs")
        if response.status_code == 200:
            repairs = response.json()
            print(f"✅ 获取报修列表成功，共 {len(repairs)} 条记录")

            # 显示最近的报修
            for repair in repairs[:3]:  # 只显示前3条
                print(f"  - ID: {repair['repair_id']}, 报修人: {repair['reporter']}, 设备: {repair['equip_name']}, 状态: {repair['status']}")

            return True
        else:
            print(f"❌ 获取报修列表失败: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ 网络错误: {e}")
        return False

def test_fix_repair():
    """测试管理员处理报修"""
    print("\n=== 测试管理员处理报修 ===")

    # 先获取报修列表，找到一个未处理的
    try:
        response = requests.get(f"{API_BASE}/api/admin/repairs")
        repairs = response.json()
        pending_repairs = [r for r in repairs if r['status'] != 'Fixed']

        if not pending_repairs:
            print("⚠️ 没有待处理的报修单，跳过测试")
            return True

        repair_id = pending_repairs[0]['repair_id']
        fix_data = {
            "repair_id": repair_id,
            "reply": "测试修复完成"
        }

        response = requests.post(f"{API_BASE}/api/admin/fix_repair", json=fix_data)
        if response.status_code == 200:
            print(f"✅ 报修处理成功 (ID: {repair_id})")
            return True
        else:
            print(f"❌ 报修处理失败: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ 网络错误: {e}")
        return False

def main():
    print("开始测试学生端和管理员端报修数据传输...")

    # 检查服务器
    if not check_server():
        return

    print("请确保数据库中有测试数据 (user_id=1, equip_id=1)")

    # 测试提交报修
    submit_success = test_report_repair()

    if submit_success:
        # 等待一下，确保数据写入
        time.sleep(1)

        # 测试获取报修
        get_success = test_get_repairs()

        if get_success:
            # 测试处理报修
            test_fix_repair()

    print("\n=== 测试完成 ===")
    if submit_success:
        print("✅ 数据传输正常")
    else:
        print("❌ 数据传输异常，请检查后端日志")

if __name__ == "__main__":
    main()