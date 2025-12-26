import pymssql
import sys

# ---------------------------------------------------------
# 数据库配置 (请填入与 app.py 一致的信息)
# ---------------------------------------------------------
DB_CONFIG = {
    # ⚠️ 关键修改 1: 这里填您同学电脑的 IP 地址 (例如 192.168.1.5)
    'server': '192.168.28.103',
    # ⚠️ 关键修改 2: SQL Server 的端口，默认通常是 1433
    'port': '3456',            
    # ⚠️ 关键修改 3: 数据库用户名 (SQL Server 默认管理员是 sa)
    'user': 'qhulab ',              
    # ⚠️ 关键修改 4: 您同学设置的数据库密码
    'password': 'qhulab', 
    # 数据库名称 (确保和他电脑上建立的一致)
    'database': 'qhu_lab_system', 
    
    'charset': 'utf8'
}

def test_connection():
    print("="*50)
    print(f"正在尝试连接数据库服务器: {DB_CONFIG['server']} ...")
    print("="*50)

    try:
        # 1. 尝试建立连接
        conn = pymssql.connect(
            server=DB_CONFIG['server'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password'],
            database=DB_CONFIG['database'],
            port=DB_CONFIG['port'],
            charset=DB_CONFIG['charset'],
            login_timeout=5  # 设置5秒超时，避免死等
        )
        print("✅ [成功] 数据库连接已建立！")

        # 2. 尝试执行一条简单的查询验证
        cursor = conn.cursor()
        print("🔄 正在执行测试查询 (SELECT @@VERSION)...")
        cursor.execute("SELECT @@VERSION")
        row = cursor.fetchone()
        
        print(f"✅ [成功] 查询返回正常！")
        print(f"ℹ️  服务器版本信息: {row[0][:50]}...") # 只打印前50个字符

        # 3. 关闭连接
        conn.close()
        print("="*50)
        print("🎉 恭喜！后端连接数据库环境配置完全正确！")
        print("现在你可以放心地运行 python app.py 了。")
        print("="*50)

    except pymssql.OperationalError as e:
        print("\n❌ [连接失败] 无法连接到服务器。")
        print("可能是以下原因：")
        print("1. IP 地址填错了 (请确认对方电脑的 IPv4 地址)。")
        print("2. 账号或密码错误 (注意 SQL Server 账号默认是 sa)。")
        print("3. 对方电脑的防火墙拦截了 1433 端口。")
        print("4. 对方 SQL Server 没开启 TCP/IP 协议。")
        print(f"\n详细错误信息: {e}")

    except pymssql.InterfaceError as e:
        print("\n❌ [接口错误] 连接参数可能有误。")
        print(f"详细错误信息: {e}")

    except Exception as e:
        print(f"\n❌ [未知错误] {e}")

if __name__ == "__main__":
    test_connection()