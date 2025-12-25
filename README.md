# 青海大学灵犀智约平台

# QHU i-Lab

> **课程设计题目**：《数据库技术及其应用》综合设计
>
> **学院**：计算机技术与应用系
>
> **组号**：High-polymer

## 📖 项目介绍

针对QHU高性能计算中心、智能计算实验室等科研场所面临的**设备预约冲突、机房排课管理复杂、设备维护信息不透明**等痛点，本项目设计并开发了一套**前后端分离**的智慧管理系统。

系统实现了从设备入库、预约使用、冲突检测到故障报修、维修处理的**全生命周期数字化管理**。特别针对计算机系机房（如121、223机房）实施了基于班级优先级的排课逻辑，并为高性能计算资源（GPU节点）提供了精确的时间段预约功能。

## ✨ 主要功能

### 🧑‍🎓 学生/研究员端

1. **可视化仪表盘**：实时查看实验室资源概况、公告及个人活跃度。

2. **科研设备预约**：

   * 支持按日期、时间段（如 08:00-10:00）预约。

   * **智能冲突检测**：自动识别并冻结已被占用的时间段（灰色不可点）。

3. **计算机房预约**：

   * 查看机房（121, 223, 310等）的开放状态。

   * 集成排课规则提示（如“晚间优先大一班级”）。

4. **故障报修**：在线填写报修单，选择紧急程度，追踪维修进度。

5. **我的申请**：查看历史预约记录及审批状态。

### 👨‍🏫 管理员端

1. **报修处理闭环**：

   * 接收学生报修 -> 标记设备为“维修中” (自动阻断新预约) -> 线下维修 -> 点击“完成修复” -> 设备自动恢复“可用”。

2. **设备入库管理**：标准化的资产录入界面（演示版）。

3. **数据看板**：实时监控设备完好率及待处理事项。

---

## 💻 使用技术

| 类型 | 名称 | 说明 |
| :--- | :--- | :--- |
| **前端** | HTML5, CSS3, Bootstrap, JS | 响应式布局，用户交互体验优化 |
| **后端** | Python 3.8+, Flask | 轻量级Web应用框架，业务逻辑处理 |
| **数据库** | MySQL / SQLite | 数据持久化存储（用户信息、设备数据等） |
| **ORM** | SQLAlchemy | 数据库对象关系映射，简化SQL操作 |
| **开发工具** | PyCharm / VS Code | 代码编写与调试环境 |
| **版本控制** | Git / GitHub | 代码版本管理 |

---

## 📂 功能结构

```text
Project_Root/
├── app/
│   ├── __init__.py      # Flask应用初始化
│   ├── models.py        # 数据库模型 (User, Equipment, Reservation)
│   ├── routes/          # 路由与视图函数
│   │   ├── auth.py      # 登录/注册
│   │   ├── main.py      # 主页与公共页面
│   │   ├── equipment.py # 设备管理逻辑
│   │   └── admin.py     # 管理员后台
│   ├── static/          # 静态资源 (css, js, images)
│   └── templates/       # HTML模板 (Jinja2)
│       ├── base.html    # 基础模板
│       ├── login.html   # 登录页
│       └── ...
├── config.py            # 项目配置文件 (数据库URI等)
├── run.py               # 项目启动脚本
├── requirements.txt     # 项目依赖包列表
└── README.md            # 项目说明文档

```
## 🚀 安装与运行指南
1. **环境准备**
    确保您的电脑已安装：

    Python 3.8 或更高版本

    MySQL 数据库（如使用 SQLite 可跳过安装 MySQL）

2. **克隆项目**

```Bash

git clone [https://github.com/your-username/QHU-Lab-System.git](https://github.com/your-username/QHU-Lab-System.git)
cd QHU-Lab-System
```

3. **安装依赖**
建议创建虚拟环境，然后安装依赖：

```Bash
pip install -r requirements.txt
```
4. **配置数据库**
运行test.py检查数据库是否连接成功：

```Python
python test.py
```
5. **连接数据库**
在终端执行以下命令生成数据表：

```Bash
python app.py
```
6. **运行项目**
```Bash
运行 System/front.html
```

项目启动后，即可操作运行

## 📖 使用说明
### 默认管理员：

**账号**：admin

**密码**：123456 (首次登录请务必修改密码)

### 注册用户：

学生/教师可通过注册页面创建账户，默认权限为普通用户。

预约流程：
```text
登录系统 -> 点击“设备列表”。

选择设备 -> 点击“立即预约”。

选择时间段 -> 提交申请。

等待管理员审核（或自动通过，视设置而定）。
```

## ❓ 常见问题解答 (FAQ)

### Q1: 启动报错 "ModuleNotFoundError: No module named 'flask'"?

Fix: 请检查是否已成功激活虚拟环境，并执行了 **pip install -r requirements.txt**。

### Q2: 数据库报错 "sqlalchemy.exc.OperationalError ... Access denied"?

Fix: 请检查 **config.py** 中的数据库用户名和密码是否正确，以及 MySQL 服务是否已启动。

### Q3: 迁移时提示 "Target database is not up to date"?

Fix: 请尝试执行 **flask db stamp head** 然后再次运行 **flask db migrate** 和 **flask db upgrade**。

### Q4: 表格显示 "Invalid column name"?

Fix: 可能是模型定义改变但未迁移数据库。请重新执行数据库迁移命令。

### Q5: 中文显示乱码?

Fix: 请确保 config.py 中数据库 URI 包含 ?charset=utf8mb4，且 Python 文件头部包含 **# -*- coding: utf-8 -*-**。

## 👥 项目分工
组长：统筹项目进度，负责后端核心架构与数据库设计。

组员A：负责前端页面设计与实现 (UI/UX)。

组员B：负责部分业务逻辑开发与文档编写。


---
© 2025 QHU Lab System. All Rights Reserved.