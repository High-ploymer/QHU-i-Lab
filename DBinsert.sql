USE qhu_lab_system;
GO

PRINT '开始插入青海大学实验室管理系统数据...';
GO

-- ============================================
-- 1. 插入实验室数据 (注意：Labs表有自增主键，不指定lab_id)
-- ============================================
PRINT '插入实验室数据...';

-- 首先检查并插入实验室数据（避免重复）
DECLARE @existingLabs TABLE (lab_name NVARCHAR(100));

INSERT INTO @existingLabs (lab_name)
SELECT lab_name FROM Labs;

-- 插入不存在的实验室
INSERT INTO Labs (lab_name, location)
SELECT src.lab_name, src.location
FROM (VALUES
    ('高性能轻金属合金及深加工国家地方联合工程研究中心', '机械楼'),
    ('青海省智能计算与应用实验室', '科技楼 A-301'),
    ('水工结构工程科研平台', '水利水电学院'),
    ('青海省先进材料与应用技术重点实验室', '能源学院'),
    ('高性能计算中心', '信息中心大楼'),
    ('计算机系实验教学中心', '计算机楼'),
    ('水文水资源科研平台', '水利楼'),
    ('嵌入式与移动互联网实验室', '计算机楼 402'),
    ('机械工程学院实验室', '机械楼'),
    ('电子电路实验室', '电子楼 B-105'),
    ('网络工程实验室', '信工楼'),
    ('工程创新中心', 'D-101')
) AS src(lab_name, location)
WHERE NOT EXISTS (
    SELECT 1 FROM @existingLabs WHERE lab_name = src.lab_name
);
GO

-- ============================================
-- 2. 插入用户数据 (避免用户名重复)
-- ============================================
PRINT '插入用户数据...';

-- 检查用户名是否存在
IF NOT EXISTS (SELECT 1 FROM Users WHERE username = 'student01')
BEGIN
    INSERT INTO Users (username, real_name, department, role)
    VALUES ('student01', '李同学', '计算机技术与应用系', 'Student');
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE username = 'teacher01')
BEGIN
    INSERT INTO Users (username, real_name, department, role)
    VALUES ('teacher01', '王老师', '机械工程学院', 'Admin');
END
GO

-- ============================================
-- 3. 插入设备数据
-- ============================================
PRINT '插入设备数据...';

-- 先获取实验室ID映射
DECLARE @labId1 INT, @labId2 INT, @labId3 INT, @labId4 INT, 
        @labId5 INT, @labId6 INT, @labId7 INT, @labId8 INT,
        @labId9 INT, @labId10 INT, @labId11 INT, @labId12 INT;

SELECT @labId1 = lab_id FROM Labs WHERE lab_name = '高性能轻金属合金及深加工国家地方联合工程研究中心';
SELECT @labId2 = lab_id FROM Labs WHERE lab_name = '青海省智能计算与应用实验室';
SELECT @labId3 = lab_id FROM Labs WHERE lab_name = '水工结构工程科研平台';
SELECT @labId4 = lab_id FROM Labs WHERE lab_name = '青海省先进材料与应用技术重点实验室';
SELECT @labId5 = lab_id FROM Labs WHERE lab_name = '高性能计算中心';
SELECT @labId6 = lab_id FROM Labs WHERE lab_name = '计算机系实验教学中心';
SELECT @labId7 = lab_id FROM Labs WHERE lab_name = '水文水资源科研平台';
SELECT @labId8 = lab_id FROM Labs WHERE lab_name = '嵌入式与移动互联网实验室';
SELECT @labId9 = lab_id FROM Labs WHERE lab_name = '机械工程学院实验室';
SELECT @labId10 = lab_id FROM Labs WHERE lab_name = '电子电路实验室';
SELECT @labId11 = lab_id FROM Labs WHERE lab_name = '网络工程实验室';
SELECT @labId12 = lab_id FROM Labs WHERE lab_name = '工程创新中心';

-- 3.1 插入重点设备 (使用SET IDENTITY_INSERT插入指定ID的设备)
SET IDENTITY_INSERT Equipments ON;

-- 检查设备ID是否已存在，避免冲突
IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 201)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (201, '透射电子显微镜系统 (JEM-2100F)', @labId1, 'Booked', 'fa-microscope');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 202)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (202, '高性能计算中心 GPU 节点', @labId2, 'Available', 'fa-server');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 203)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (203, '隧道地质超前预报系统 (TGP206A)', @labId3, 'Available', 'fa-hill-rockslide');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 204)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (204, '荧光分光光度计', @labId4, 'Available', 'fa-flask');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 205)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (205, '超算竞赛显微卡/加速卡', @labId5, 'Maintenance', 'fa-microchip');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 206)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (206, '水下地形测量无人机系统', @labId7, 'Available', 'fa-plane');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 207)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (207, '嵌入式 ARM 教学开发平台', @labId8, 'Available', 'fa-wifi');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 208)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (208, '场发射扫描电子显微镜', @labId1, 'Available', 'fa-eye');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 209)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, icon_class)
    VALUES (209, 'X射线衍射仪 (Bruker D8)', @labId9, 'Available', 'fa-circle-radiation');
END

-- 3.2 插入计算机机房设备
IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 301)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, category, detail_info, icon_class)
    VALUES (301, '121机房 (50座)', @labId6, 'Available', 'ComputerRoom', '周一至周五 18:00-21:00 | 优先: 大一一班', 'fa-desktop');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 302)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, category, detail_info, icon_class)
    VALUES (302, '223机房 (60座)', @labId6, 'Available', 'ComputerRoom', '周一至周五 18:00-21:00 | 优先: 大一三班', 'fa-desktop');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 303)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, category, detail_info, icon_class)
    VALUES (303, '316机房 (45座)', @labId6, 'Booked', 'ComputerRoom', '周一至周五 18:00-21:00 | 优先: 大一四班', 'fa-desktop');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 304)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, category, detail_info, icon_class)
    VALUES (304, '321机房 (综合)', @labId6, 'Available', 'ComputerRoom', '周一至周五 18:00-21:00 | 需申请 (班会/活动)', 'fa-network-wired');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 305)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, category, detail_info, icon_class)
    VALUES (305, '310机房 (开放实验室)', @labId6, 'Available', 'ComputerRoom', '周六至周日 8:00-17:30 | 面向全体学生', 'fa-laptop-code');
END

IF NOT EXISTS (SELECT 1 FROM Equipments WHERE equip_id = 306)
BEGIN
    INSERT INTO Equipments (equip_id, equip_name, lab_id, status, category, detail_info, icon_class)
    VALUES (306, '319机房 (开放实验室)', @labId6, 'Maintenance', 'ComputerRoom', '周六至周日 8:00-17:30 | 面向全体学生', 'fa-laptop-code');
END

SET IDENTITY_INSERT Equipments OFF;

-- 3.3 插入剩余的通用科研设备 (不指定equip_id，让系统自增)
INSERT INTO Equipments (equip_name, lab_id, status, icon_class)
SELECT equip_name, lab_id, status, icon_class
FROM (VALUES
    ('高性能 GPU 服务器', @labId5, 'Available', 'fa-server'),
    ('机架式服务器（双路 CPU）', @labId5, 'Booked', 'fa-server'),
    ('刀片式服务器集群', @labId2, 'Available', 'fa-server'),
    ('便携式笔记本电脑（科研专用）', @labId6, 'Available', 'fa-laptop'),
    ('台式工作站（图形处理型）', @labId2, 'Booked', 'fa-desktop'),
    ('工业控制计算机（IPC）', @labId9, 'Available', 'fa-industry'),
    ('数据存储服务器（NAS）', @labId5, 'Maintenance', 'fa-database'),
    ('网络交换机（48 口万兆）', @labId11, 'Available', 'fa-network-wired'),
    ('无线路由器（企业级）', @labId11, 'Available', 'fa-wifi'),
    ('防火墙设备（硬件）', @labId11, 'Available', 'fa-shield-halved'),
    ('网络分析仪', @labId11, 'Available', 'fa-chart-line'),
    ('示波器（4 通道，100MHz）', @labId10, 'Available', 'fa-wave-square'),
    ('数字万用表（高精度）', @labId10, 'Available', 'fa-bolt'),
    ('函数信号发生器', @labId10, 'Available', 'fa-wave-square'),
    ('直流稳压电源（多路输出）', @labId10, 'Available', 'fa-plug'),
    ('LCR 测量仪', @labId10, 'Available', 'fa-ruler-horizontal'),
    ('激光干涉仪', @labId1, 'Available', 'fa-rainbow'),
    ('分光光度计（紫外可见）', @labId4, 'Booked', 'fa-prism'),
    ('核磁共振波谱仪（小型）', @labId4, 'Maintenance', 'fa-magnet'),
    ('3D 打印机（SLA 技术）', @labId12, 'Available', 'fa-print'),
    ('工业机器人（6 轴）', @labId12, 'Available', 'fa-robot'),
    ('无人机测试台', @labId7, 'Available', 'fa-plane')
) AS new_equip(equip_name, lab_id, status, icon_class)
WHERE NOT EXISTS (
    SELECT 1 FROM Equipments e 
    WHERE e.equip_name = new_equip.equip_name 
    AND e.lab_id = new_equip.lab_id
);
GO

-- ============================================
-- 4. 验证数据插入情况
-- ============================================
PRINT '';
PRINT '数据插入完成！验证结果：';
PRINT '==============================================';

DECLARE @labCount INT, @userCount INT, @equipCount INT;
SELECT @labCount = COUNT(*) FROM Labs;
SELECT @userCount = COUNT(*) FROM Users;
SELECT @equipCount = COUNT(*) FROM Equipments;

PRINT '实验室数量：' + CAST(@labCount AS VARCHAR) + ' 个';
PRINT '用户数量：' + CAST(@userCount AS VARCHAR) + ' 个';
PRINT '设备数量：' + CAST(@equipCount AS VARCHAR) + ' 个';
PRINT '';

PRINT '实验室列表：';
SELECT lab_id, lab_name, location FROM Labs ORDER BY lab_id;
PRINT '';

PRINT '设备分类统计：';
SELECT 
    category,
    status,
    COUNT(*) as count
FROM Equipments 
GROUP BY category, status 
ORDER BY category, status;
PRINT '';

PRINT '各实验室设备数量：';
SELECT 
    l.lab_name,
    COUNT(e.equip_id) as equipment_count
FROM Labs l
LEFT JOIN Equipments e ON l.lab_id = e.lab_id
GROUP BY l.lab_name
ORDER BY equipment_count DESC;
GO

PRINT '==============================================';
PRINT '所有数据已成功插入到青海大学实验室管理系统！';
PRINT '数据库已完全初始化，可正常运行。';
PRINT '==============================================';
GO