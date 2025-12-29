USE qhu_lab_system;
GO

PRINT '青海大学实验室管理系统数据库创建完成！';
PRINT '数据库名称：qhu_lab_system';
PRINT '字符集：支持中文存储';
GO

/* ========================================================================== */
/* 1. 基础表结构                                */
/* ========================================================================== */

-- 1.1 实验室表 (Labs)
CREATE TABLE Labs (
    lab_id          INT IDENTITY(1,1) PRIMARY KEY,
    lab_name        NVARCHAR(100) NOT NULL,
    location        NVARCHAR(100) NOT NULL,
    manager_name    NVARCHAR(50)
);
GO

-- 1.2 用户表 (Users)
CREATE TABLE Users (
    user_id         INT IDENTITY(1,1) PRIMARY KEY,
    username        NVARCHAR(50) UNIQUE NOT NULL,
    password        NVARCHAR(100) NOT NULL,
    real_name       NVARCHAR(50) NOT NULL,
    department      NVARCHAR(100),
    role            NVARCHAR(20) NOT NULL DEFAULT 'Student'
);
GO

-- 用户角色约束
ALTER TABLE Users ADD CONSTRAINT CHK_Users_Role 
CHECK (role IN ('Student', 'Teacher', 'Admin'));
GO

-- 1.3 设备表 (Equipments)
CREATE TABLE Equipments (
    equip_id        INT IDENTITY(1,1) PRIMARY KEY,
    equip_name      NVARCHAR(150) NOT NULL,
    lab_id          INT NOT NULL,
    icon_class      VARCHAR(50) DEFAULT 'fa-cube',
    model           NVARCHAR(50),
    category        NVARCHAR(50) DEFAULT 'Device',
    status          NVARCHAR(20) NOT NULL DEFAULT 'Available',
    price           DECIMAL(12,2),
    purchase_date   DATE,
    detail_info     NVARCHAR(255),
    created_at      DATETIME DEFAULT GETDATE()
);
GO

-- 设备状态约束
ALTER TABLE Equipments ADD CONSTRAINT CHK_Equipments_Status
CHECK (status IN ('Available', 'Booked', 'Maintenance', 'Scrapped'));
GO

-- 1.4 预约表 (Appointments)
CREATE TABLE Appointments (
    app_id          INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT NOT NULL,
    equip_id        INT NOT NULL,
    start_time      DATETIME NOT NULL,
    end_time        DATETIME NOT NULL,
    app_status      NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    approved_by     INT,
    approval_time   DATETIME,
    created_at      DATETIME DEFAULT GETDATE()
);
GO

-- 预约状态约束
ALTER TABLE Appointments ADD CONSTRAINT CHK_Appointments_Status
CHECK (app_status IN ('Pending', 'Approved', 'Rejected', 'Cancelled', 'Completed'));
GO

-- 1.5 维修表 (Maintenance)
CREATE TABLE Maintenance (
    maint_id        INT IDENTITY(1,1) PRIMARY KEY,
    equip_id        INT NOT NULL,
    reporter_id     INT NOT NULL,
    issue_desc      NVARCHAR(MAX) NOT NULL,
    report_date     DATETIME DEFAULT GETDATE(),
    resolve_status  NVARCHAR(20) DEFAULT 'Pending',
    created_at      DATETIME DEFAULT GETDATE()
);
GO

-- 维修状态约束
ALTER TABLE Maintenance ADD CONSTRAINT CHK_Maintenance_Status
CHECK (resolve_status IN ('Pending', 'InProgress', 'Completed', 'Delayed'));
GO

/* ========================================================================== */
/* 2. 外键约束                                  */
/* ========================================================================== */

-- 设备 -> 实验室
ALTER TABLE Equipments ADD CONSTRAINT FK_Equipments_Labs
FOREIGN KEY (lab_id) REFERENCES Labs(lab_id);
GO

-- 预约 -> 用户
ALTER TABLE Appointments ADD CONSTRAINT FK_Appointments_Users
FOREIGN KEY (user_id) REFERENCES Users(user_id);
GO

-- 预约 -> 设备
ALTER TABLE Appointments ADD CONSTRAINT FK_Appointments_Equipments
FOREIGN KEY (equip_id) REFERENCES Equipments(equip_id);
GO

-- 预约 -> 审批人 (用户)
ALTER TABLE Appointments ADD CONSTRAINT FK_Appointments_Approver
FOREIGN KEY (approved_by) REFERENCES Users(user_id);
GO

-- 维修 -> 设备
ALTER TABLE Maintenance ADD CONSTRAINT FK_Maintenance_Equipments
FOREIGN KEY (equip_id) REFERENCES Equipments(equip_id);
GO

-- 维修 -> 报告人 (用户)
ALTER TABLE Maintenance ADD CONSTRAINT FK_Maintenance_Reporter
FOREIGN KEY (reporter_id) REFERENCES Users(user_id);
GO

/* ========================================================================== */
/* 3. 视图定义                                  */
/* ========================================================================== */

-- 学生设备视图
CREATE VIEW View_Student_Equip AS
SELECT 
    e.equip_name, 
    e.status, 
    l.lab_name, 
    e.detail_info
FROM Equipments e 
JOIN Labs l ON e.lab_id = l.lab_id;
GO

-- 用户设备通用视图
CREATE VIEW View_User_Equipments AS
SELECT 
    equip_id, 
    equip_name, 
    lab_id, 
    model, 
    status, 
    detail_info
FROM Equipments;
GO

-- 用户预约视图
CREATE VIEW View_User_Appointments AS
SELECT 
    app_id, 
    user_id, 
    equip_id, 
    start_time, 
    end_time, 
    app_status
FROM Appointments;
GO

/* ========================================================================== */
/* 4. 存储过程                                  */
/* ========================================================================== */

-- 冲突检测
CREATE PROCEDURE sp_CheckBookingConflict
    @p_equip_id INT,
    @p_start_time DATETIME,
    @p_end_time DATETIME
AS
BEGIN
    SELECT COUNT(*) AS conflict_count
    FROM Appointments
    WHERE equip_id = @p_equip_id
      AND app_status != 'Cancelled'
      AND (
          (start_time <= @p_start_time AND end_time > @p_start_time) OR
          (start_time < @p_end_time AND end_time >= @p_end_time)
      );
END;
GO

/* ========================================================================== */
/* 5. 触发器                                    */
/* ========================================================================== */

-- 自动取消预约触发器 (当设备变为维修状态时)
CREATE TRIGGER Trigger_Auto_Cancel
ON Equipments
AFTER UPDATE
AS
BEGIN
    IF UPDATE(status)
    BEGIN
        UPDATE Appointments
        SET app_status = 'Cancelled'
        WHERE equip_id IN (SELECT equip_id FROM inserted WHERE status = 'Maintenance')
          AND app_status IN ('Pending', 'Approved')
          AND start_time > GETDATE();
    END
END;
GO

/* ========================================================================== */
/* 6. 权限分配                                  */
/* ========================================================================== */

-- 创建角色
CREATE ROLE StudentRole;
CREATE ROLE AdminRole;
GO

-- 普通用户权限 (StudentRole)
GRANT SELECT, INSERT, UPDATE, DELETE ON View_User_Equipments TO StudentRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON View_User_Appointments TO StudentRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Maintenance TO StudentRole;
GRANT EXECUTE ON sp_CheckBookingConflict TO StudentRole;
GO

-- 管理员权限 (AdminRole)
GRANT SELECT, INSERT, UPDATE, DELETE ON Labs TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Users TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Equipments TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Appointments TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Maintenance TO AdminRole;
GRANT SELECT ON View_Student_Equip TO AdminRole;
GO

/* ========================================================================== */
/* 7. 结束输出                                  */
/* ========================================================================== */

PRINT '';
PRINT '==============================================';
PRINT '青海大学实验室科研设备管理系统数据库初始化完成！';
PRINT '==============================================';
PRINT '   - Labs (实验室表)';
PRINT '   - Users (用户表)';
PRINT '   - Equipments (设备表)';
PRINT '   - Appointments (预约表)';
PRINT '   - Maintenance (维修表)';
GO