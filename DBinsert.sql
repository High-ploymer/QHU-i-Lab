USE qhu_lab_system;
GO

PRINT '开始插入青海大学实验室管理系统初始数据...';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* ========================================================================== */
    /* 1. 插入实验室数据                            */
    /* ========================================================================== */
    PRINT '插入实验室数据...';

    MERGE INTO Labs AS target
    USING (VALUES
        ('高性能轻金属合金及深加工国家地方联合工程研究中心', '机械学院',        NULL),
        ('青海省智能计算与应用实验室',                       '科技楼 A-301',  NULL),
        ('水工结构工程科研平台',                             '土木水利学院',  NULL),
        ('青海省先进材料与应用技术重点实验室',               '能电学院',      NULL),
        ('高性能计算中心',                                   '信息中心大楼',  NULL),
        ('计算机系实验教学中心',                             '计算机学院',    NULL),
        ('水文水资源科研平台',                               '土木水利学院',  NULL),
        ('嵌入式与移动互联网实验室',                         '计算机学院402', NULL),
        ('机械工程学院实验室',                               '机械学院',      NULL),
        ('电子电路实验室',                                   '能电学院 B-105',NULL),
        ('网络工程实验室',                                   '信工楼',        NULL),
        ('工程创新中心',                                     'D-101',         NULL)
    ) AS source(lab_name, location, manager_name)
    ON target.lab_name = source.lab_name
    WHEN NOT MATCHED THEN
        INSERT (lab_name, location, manager_name)
        VALUES (source.lab_name, source.location, source.manager_name);

    PRINT '实验室数据插入完成！';

    /* ========================================================================== */
    /* 2. 插入用户数据                              */
    /* ========================================================================== */
    PRINT '插入用户数据...';

    MERGE INTO Users AS target
    USING (VALUES
        ('admin',     '123456', '高国振', '信息技术中心',       'Admin'),
        ('student01', '123456', '乔可傲', '24绿算班',           'Student'),
        ('student02', '123456', '李相烨', '24绿算班',           'Student'),
        ('student03', '123456', '史鸿魁', '24绿算班',           'Student'),
        ('student04', '123456', '李同学', '计算机技术与应用系', 'Student'),
        ('teacher01', '123456', '王老师', '机械工程学院',       'Admin')
    ) AS source(username, password, real_name, department, role)
    ON target.username = source.username
    WHEN NOT MATCHED THEN
        INSERT (username, password, real_name, department, role)
        VALUES (source.username, source.password, source.real_name, source.department, source.role);

    PRINT '用户数据插入完成！';

    /* ========================================================================== */
    /* 3. 插入设备数据                              */
    /* ========================================================================== */
    PRINT '插入设备数据...';

    -- 3.0 准备：获取实验室ID
    DECLARE @labId1 INT, @labId2 INT, @labId3 INT, @labId4 INT, 
            @labId5 INT, @labId6 INT, @labId7 INT, @labId8 INT,
            @labId9 INT, @labId10 INT, @labId11 INT, @labId12 INT;

    SELECT @labId1  = lab_id FROM Labs WHERE lab_name = '高性能轻金属合金及深加工国家地方联合工程研究中心';
    SELECT @labId2  = lab_id FROM Labs WHERE lab_name = '青海省智能计算与应用实验室';
    SELECT @labId3  = lab_id FROM Labs WHERE lab_name = '水工结构工程科研平台';
    SELECT @labId4  = lab_id FROM Labs WHERE lab_name = '青海省先进材料与应用技术重点实验室';
    SELECT @labId5  = lab_id FROM Labs WHERE lab_name = '高性能计算中心';
    SELECT @labId6  = lab_id FROM Labs WHERE lab_name = '计算机系实验教学中心';
    SELECT @labId7  = lab_id FROM Labs WHERE lab_name = '水文水资源科研平台';
    SELECT @labId8  = lab_id FROM Labs WHERE lab_name = '嵌入式与移动互联网实验室';
    SELECT @labId9  = lab_id FROM Labs WHERE lab_name = '机械工程学院实验室';
    SELECT @labId10 = lab_id FROM Labs WHERE lab_name = '电子电路实验室';
    SELECT @labId11 = lab_id FROM Labs WHERE lab_name = '网络工程实验室';
    SELECT @labId12 = lab_id FROM Labs WHERE lab_name = '工程创新中心';

    -- 3.1 插入重点设备（ID 201-209）
    SET IDENTITY_INSERT Equipments ON;

    MERGE INTO Equipments AS target
    USING (VALUES
        (201, '透射电子显微镜系统 (JEM-2100F)', @labId1, 'fa-microscope',         NULL, 'Device', 'Booked',      NULL, NULL, NULL, GETDATE()),
        (202, '高性能计算中心 GPU 节点',        @labId2, 'fa-server',             NULL, 'Device', 'Available',   NULL, NULL, NULL, GETDATE()),
        (203, '隧道地质超前预报系统 (TGP206A)', @labId3, 'fa-hill-rockslide',     NULL, 'Device', 'Available',   NULL, NULL, NULL, GETDATE()),
        (204, '荧光分光光度计',                 @labId4, 'fa-flask',              NULL, 'Device', 'Available',   NULL, NULL, NULL, GETDATE()),
        (205, '超算竞赛显微卡/加速卡',          @labId5, 'fa-microchip',          NULL, 'Device', 'Maintenance', NULL, NULL, NULL, GETDATE()),
        (206, '水下地形测量无人机系统',         @labId7, 'fa-plane',              NULL, 'Device', 'Available',   NULL, NULL, NULL, GETDATE()),
        (207, '嵌入式 ARM 教学开发平台',        @labId8, 'fa-wifi',               NULL, 'Device', 'Available',   NULL, NULL, NULL, GETDATE()),
        (208, '场发射扫描电子显微镜',           @labId1, 'fa-eye',                NULL, 'Device', 'Available',   NULL, NULL, NULL, GETDATE()),
        (209, 'X射线衍射仪 (Bruker D8)',        @labId9, 'fa-circle-radiation',   NULL, 'Device', 'Available',   NULL, NULL, NULL, GETDATE())
    ) AS source(equip_id, equip_name, lab_id, icon_class, model, category, status, price, purchase_date, detail_info, created_at)
    ON target.equip_id = source.equip_id
    WHEN NOT MATCHED THEN
        INSERT (equip_id, equip_name, lab_id, icon_class, model, category, status, price, purchase_date, detail_info, created_at)
        VALUES (source.equip_id, source.equip_name, source.lab_id, source.icon_class, source.model, 
                source.category, source.status, source.price, source.purchase_date, source.detail_info, source.created_at);

    -- 3.2 插入计算机机房设备（ID 301-306）
    MERGE INTO Equipments AS target
    USING (VALUES
        (301, '125机房 (44座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Available',   NULL, NULL, '周一至周五 19:00-21:00 | 优先: 241班',              GETDATE()),
        (302, '225机房 (44座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Available',   NULL, NULL, '周一至周五 19:00-21:00 | 优先: 25绿算班',           GETDATE()),
        (303, '227机房 (85座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Available',   NULL, NULL, '周一至周五 19:00-21:00 | 优先: 243、251班',         GETDATE()),
        (304, '316机房 (95座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Booked',      NULL, NULL, '周一至周五 19:00-21:00 | 优先: 244、252班',         GETDATE()),
        (305, '325机房 (44座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Available',   NULL, NULL, '周一至周五 19:00-21:00 | 优先: 253班',              GETDATE()),
        (306, '327机房 (80座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Available',   NULL, NULL, '周一至周五 19:00-21:00 | 优先: 24绿算班',           GETDATE()),
        (307, '416机房 (95座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Available',   NULL, NULL, '周一至周五 19:00-21:00 | 优先: 245、254班',         GETDATE()),
        (308, '425机房 (开放实验室)',   @labId6, 'fa-laptop-code', NULL, 'ComputerRoom', 'Available', NULL, NULL, '周六至周日 8:00-17:30 | 面向全体学生',           GETDATE()),
        (309, '427机房 (90座)',         @labId6, 'fa-desktop', NULL, 'ComputerRoom', 'Maintenance', NULL, NULL, '周一至周五 19:00-21:00 | 优先: 242、255班',         GETDATE())
    ) AS source(equip_id, equip_name, lab_id, icon_class, model, category, status, price, purchase_date, detail_info, created_at)
    ON target.equip_id = source.equip_id
    WHEN NOT MATCHED THEN
        INSERT (equip_id, equip_name, lab_id, icon_class, model, category, status, price, purchase_date, detail_info, created_at)
        VALUES (source.equip_id, source.equip_name, source.lab_id, source.icon_class, source.model, 
                source.category, source.status, source.price, source.purchase_date, source.detail_info, source.created_at);

    SET IDENTITY_INSERT Equipments OFF;

    -- 3.3 插入剩余的通用科研设备（ID 自增）
    INSERT INTO Equipments (equip_name, lab_id, icon_class, model, category, status, price, purchase_date, detail_info, created_at)
    SELECT equip_name, lab_id, icon_class, model, category, status, price, purchase_date, detail_info, created_at
    FROM (VALUES
        ('高性能 GPU 服务器 (NVIDIA A100)', @labId5,  'fa-server',         NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('机架式服务器 (双路 CPU)',         @labId5,  'fa-server',         NULL, 'Device',       'Booked',      NULL, NULL, NULL,               GETDATE()),
        ('刀片式服务器集群',                @labId2,  'fa-server',         NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('便携式笔记本电脑（科研专用）',    @labId6,  'fa-laptop',         NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('台式工作站（图形处理型）',        @labId2,  'fa-desktop',        NULL, 'Device',       'Booked',      NULL, NULL, NULL,               GETDATE()),
        ('工业控制计算机（IPC）',           @labId9,  'fa-industry',       NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('数据存储服务器（NAS）',           @labId5,  'fa-database',       NULL, 'Device',       'Maintenance', NULL, NULL, NULL,               GETDATE()),
        ('网络交换机（48 口万兆）',         @labId11, 'fa-network-wired',  NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('无线路由器（企业级）',            @labId11, 'fa-wifi',           NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('防火墙设备（硬件）',              @labId11, 'fa-shield-halved',  NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('网络分析仪',                      @labId11, 'fa-chart-line',     NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('示波器（4 通道，100MHz）',        @labId10, 'fa-wave-square',    NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('数字万用表（高精度）',            @labId10, 'fa-bolt',           NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('函数信号发生器',                  @labId10, 'fa-wave-square',    NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('直流稳压电源（多路输出）',        @labId10, 'fa-plug',           NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('LCR 测量仪',                      @labId10, 'fa-ruler-horizontal',NULL,'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('激光干涉仪',                      @labId1,  'fa-rainbow',        NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('分光光度计（紫外可见）',          @labId4,  'fa-prism',          NULL, 'Device',       'Booked',      NULL, NULL, NULL,               GETDATE()),
        ('核磁共振波谱仪（小型）',          @labId4,  'fa-magnet',         NULL, 'Device',       'Maintenance', NULL, NULL, NULL,               GETDATE()),
        ('3D 打印机（SLA 技术）',           @labId12, 'fa-print',          NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('工业机器人（6 轴）',              @labId12, 'fa-robot',          NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE()),
        ('无人机测试台',                    @labId7,  'fa-plane',          NULL, 'Device',       'Available',   NULL, NULL, NULL,               GETDATE())
    ) AS new_equip(equip_name, lab_id, icon_class, model, category, status, price, purchase_date, detail_info, created_at)
    WHERE NOT EXISTS (
        SELECT 1 FROM Equipments e 
        WHERE e.equip_name = new_equip.equip_name 
        AND e.lab_id = new_equip.lab_id
    );

    PRINT '设备数据插入完成！';

    /* ========================================================================== */
    /* 4. 插入预约数据                              */
    /* ========================================================================== */
    PRINT '插入预约数据...';

    -- 4.0 准备：获取用户ID和设备ID
    DECLARE @adminId INT, @student01Id INT, @student02Id INT;
    DECLARE @equipGPU INT, @equipServer INT;
    
    SELECT @adminId     = user_id FROM Users WHERE username = 'admin';
    SELECT @student01Id = user_id FROM Users WHERE username = 'student01';
    SELECT @student02Id = user_id FROM Users WHERE username = 'student02';
    
    SELECT @equipGPU    = equip_id FROM Equipments WHERE equip_name = '高性能 GPU 服务器 (NVIDIA A100)';
    SELECT @equipServer = equip_id FROM Equipments WHERE equip_name = '机架式服务器 (双路 CPU)';

    SET IDENTITY_INSERT Appointments ON;

    MERGE INTO Appointments AS target
    USING (VALUES
        (1, @student01Id, @equipGPU,    '2024-12-20 09:00:00', '2024-12-20 12:00:00', 'Approved', @adminId, '2024-12-19 10:30:00', GETDATE()),
        (2, @student02Id, @equipServer, '2024-12-21 14:00:00', '2024-12-21 17:00:00', 'Pending',  NULL,     NULL,                  GETDATE())
    ) AS source(app_id, user_id, equip_id, start_time, end_time, app_status, approved_by, approval_time, created_at)
    ON target.app_id = source.app_id
    WHEN NOT MATCHED THEN
        INSERT (app_id, user_id, equip_id, start_time, end_time, app_status, approved_by, approval_time, created_at)
        VALUES (source.app_id, source.user_id, source.equip_id, source.start_time, source.end_time, 
                source.app_status, source.approved_by, source.approval_time, source.created_at);

    SET IDENTITY_INSERT Appointments OFF;

    PRINT '预约数据插入完成！';

    /* ========================================================================== */
    /* 5. 插入维修数据                              */
    /* ========================================================================== */
    PRINT '插入维修数据...';

    -- 修正：使用存在的设备ID
    DECLARE @equip125 INT;
    SELECT @equip125 = equip_id FROM Equipments WHERE equip_name = '125机房 (44座)';  -- equip_id = 301

    SET IDENTITY_INSERT Maintenance ON;

    MERGE INTO Maintenance AS target
    USING (VALUES
        (1, @equipGPU, @student01Id, 'GPU计算节点不稳定，需要调试',   GETDATE(), 'Pending',    GETDATE()),
        (2, @equip125, @student02Id, '投影仪无法显示，需要更换灯泡', GETDATE(), 'InProgress', GETDATE())
    ) AS source(maint_id, equip_id, reporter_id, issue_desc, report_date, resolve_status, created_at)
    ON target.maint_id = source.maint_id
    WHEN NOT MATCHED THEN
        INSERT (maint_id, equip_id, reporter_id, issue_desc, report_date, resolve_status, created_at)
        VALUES (source.maint_id, source.equip_id, source.reporter_id, source.issue_desc, 
                source.report_date, source.resolve_status, source.created_at);

    SET IDENTITY_INSERT Maintenance OFF;

    PRINT '维修数据插入完成！';

    COMMIT TRANSACTION;

    /* ========================================================================== */
    /* 6. 验证数据插入情况                          */
    /* ========================================================================== */
    PRINT '';
    PRINT '==============================================';
    PRINT '数据插入完成！验证结果：';
    PRINT '==============================================';

    DECLARE @labCount INT, @userCount INT, @equipCount INT, @appCount INT, @maintCount INT;
    SELECT @labCount   = COUNT(*) FROM Labs;
    SELECT @userCount  = COUNT(*) FROM Users;
    SELECT @equipCount = COUNT(*) FROM Equipments;
    SELECT @appCount   = COUNT(*) FROM Appointments;
    SELECT @maintCount = COUNT(*) FROM Maintenance;

    PRINT '实验室数量：' + CAST(@labCount   AS VARCHAR) + ' 个';
    PRINT '用户数量：'   + CAST(@userCount  AS VARCHAR) + ' 个';
    PRINT '设备数量：'   + CAST(@equipCount AS VARCHAR) + ' 个';
    PRINT '预约数量：'   + CAST(@appCount   AS VARCHAR) + ' 条';
    PRINT '维修记录：'   + CAST(@maintCount AS VARCHAR) + ' 条';
    PRINT '';

    PRINT '实验室列表：';
    SELECT lab_id, lab_name, location FROM Labs ORDER BY lab_id;
    PRINT '';

    PRINT '用户列表：';
    SELECT user_id, username, real_name, department, role FROM Users ORDER BY user_id;
    PRINT '';

    PRINT '设备数量统计（前10个）：';
    SELECT TOP 10 equip_id, equip_name, lab_id, category, status FROM Equipments ORDER BY equip_id;
    PRINT '';

    PRINT '==============================================';
    PRINT '所有数据已成功插入到青海大学实验室管理系统！';
    PRINT '数据库已完全初始化，可正常运行。';
    PRINT '==============================================';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    
    PRINT '错误发生：' + ERROR_MESSAGE();
    PRINT '数据插入失败，已回滚事务！';
    
    THROW;
END CATCH
GO