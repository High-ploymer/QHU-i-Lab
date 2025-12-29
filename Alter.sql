-- 1. 创建预约表（Bookings）
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Bookings' AND xtype='U')
BEGIN
    CREATE TABLE Bookings (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- 关联用户表
    equip_id INT NOT NULL, -- 关联设备表（注意字段名需与您现有的Equipments表一致）
    booking_date DATE NOT NULL, -- 预约日期
    slot_id INT NOT NULL, -- 时间段ID (1-5)
    reason NVARCHAR(500), -- 申请理由
    status NVARCHAR(20) DEFAULT 'Approved', -- 状态: Approved, Cancelled
    created_at DATETIME DEFAULT GETDATE(), -- 创建时间

    -- 外键约束（假设您的用户表主键是 `user_id`, 设备表主键是 `equip_id`）
    CONSTRAINT FK_Bookings_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Bookings_Equip FOREIGN KEY (equip_id) REFERENCES Equipments(equip_id),

    -- 【核心】联合唯一约束：防止时间段冲突
    -- 同一台设备(equip_id) 在同一天(booking_date) 的同一个时段(slot_id) 只能有一条
    -- 注意：如果涉及"取消"逻辑，实际业务中可能需要过滤状态，这里简化为数据库层面的强约束
    CONSTRAINT UK_Booking_Slot UNIQUE (equip_id, booking_date, slot_id)
    )
END
GO

ALTER TABLE Appointments ADD purpose NVARCHAR(500) NULL;

EXEC sp_rename 'Appointments.created_at', 'create_time', 'COLUMN';

CREATE TABLE TimeSlots (
    slot_id INT PRIMARY KEY,
    slot_name NVARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BIT DEFAULT 1
);

INSERT INTO TimeSlots (slot_id, slot_name, start_time, end_time) VALUES
(1, '第一节', '08:00:00', '10:00:00'),
(2, '第二节', '10:00:00', '12:00:00'),
(3, '第三节', '14:00:00', '16:00:00'),
(4, '第四节', '16:00:00', '18:00:00'),
(5, '第五节', '19:00:00', '21:00:00');

CREATE TABLE EquipmentCategories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(255)
);

INSERT INTO EquipmentCategories (category_name, description) VALUES
('Device', '通用设备'),
('ComputerRoom', '计算机机房'),
('Instrument', '实验仪器'),
('Server', '服务器设备'),
('Network', '网络设备');

CREATE TABLE ApprovalLogs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    app_id INT NOT NULL,
    approver_id INT NOT NULL,
    action NVARCHAR(20) NOT NULL,
    remarks NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (app_id) REFERENCES Appointments(app_id),
    FOREIGN KEY (approver_id) REFERENCES Users(user_id)
);

-- 添加一个视图来兼容 create_time 查询
CREATE VIEW View_Appointments_With_CreateTime AS
SELECT 
    app_id, user_id, equip_id, start_time, end_time, 
    app_status, approved_by, approval_time, create_time
FROM Appointments;

-- 创建索引，提高时间段查询效率
CREATE INDEX IX_Appointments_Equip_Time 
ON Appointments(equip_id, start_time);

CREATE INDEX IX_Appointments_User 
ON Appointments(user_id, created_time DESC);

USE QHU_Lab_System;
GO

-- 1. [新增] 报修记录表
CREATE TABLE Repairs (
    repair_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,              -- 报修学生ID
    equip_id INT NOT NULL,             -- 故障设备ID
    issue_desc NVARCHAR(500),          -- 故障描述
    urgency NVARCHAR(20) DEFAULT 'Normal', -- 紧急程度
    status NVARCHAR(20) DEFAULT 'Pending', -- 状态: Pending(待处理), Fixed(已修复)
    report_date DATETIME DEFAULT GETDATE(),-- 报修时间
    fix_date DATETIME,                 -- 修复时间
    admin_reply NVARCHAR(200),         -- 管理员回复
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (equip_id) REFERENCES Equipments(equip_id)
);
GO

-- 2. [说明] 关于设备状态
-- 这里的 Equipments 表不需要改结构，但后续后端代码会联动：
-- 当学生提交报修 -> 对应 Equipment 的 status 变为 'Maintenance'
-- 当管理员点击修复 -> 对应 Equipment 的 status 变回 'Available'