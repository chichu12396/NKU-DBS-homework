# 校园大麦（Campus Damai）

一个校园活动信息管理与购票平台，实现活动的发布、浏览、购票、退票、后台管理等核心功能。项目聚焦数据库工程实践，围绕**事务、触发器、存储过程、视图**四类数据库高级特性完成核心业务逻辑。

---

## 项目信息

| 项目 | 内容 |
|---|---|
| 项目名称 | 校园大麦 |
| 前端语言环境 | TypeScript ~6.0.0 |
| 前端构建工具 | Vite v8.0.14 |
| 包管理工具 | npm v11.9.0 |
| 后端核心技术栈 | Java 21 (JDK 21) / Spring Boot v2.7.18 |
| 数据仓库组件 | MySQL 8.0 社区版 |

## 目录结构

```
.
├── backend/                    # Spring Boot 后端源码
├── frontend/                   # Vue + TypeScript 前端源码
├── bighomework.sql             # 建表 / 触发器 / 存储过程 / 视图脚本
├── testunitix.sql
├── unitix.sql
└── 数据库工程作业.pdf           # 工程作业报告
```

## 系统主要功能

- **购票大厅**：浏览学术讲座、文艺演出等活动，查看剩余票数并抢票
- **活动详情页**：展示活动时间、举办场馆、主办方，实时余票展示
- **我的票夹**：管理个人订单（未支付 / 已支付 / 已结束），支持退票
- **活动管理后台**：活动的发布、下架、票务结算等管理操作

## 数据库设计亮点

系统在四个核心业务场景中分别应用了不同的数据库高级特性：

| 场景 | 数据库特性 | 涉及表 |
|---|---|---|
| 用户退票 | **事务** | Ticket, Event |
| 用户购票 | **触发器**（插入前校验余票并联动更新） | Ticket, Event |
| 活动结算 | **存储过程**（校验活动是否结束，批量更新订单状态） | Ticket, Event |
| 活动大厅首页 | **视图**（多表自然连接，隐藏主键，展示可读信息） | Event, Organizers, Venue |

### 数据表创建顺序与关系

| 顺序 | 数据表 | 主键 | 参照属性 | 被参照表 |
|---|---|---|---|---|
| 1 | Organizers | OrganizerId | 无 | 无 |
| 2 | Venue | VenueID | 无 | 无 |
| 3 | User | UserID | 无 | 无 |
| 4 | Event | EventID | (OrganizerId)<br>(VenueID) | Organizers(OrganizerId)<br>Venue(VenueID) |
| 5 | Lecture | EventID | (EventID) | Event(EventID) |
| 6 | Performances | EventID | (EventID) | Event(EventID) |
| 7 | Student | UserID | (UserID) | User(UserID) |
| 8 | Staff | UserID | (UserID) | User(UserID) |
| 9 | Ticket | OrderID | (EventID)<br>(UserID) | Event(EventID)<br>User(UserID) |

---

## 环境要求

| 依赖 | 版本建议 |
|---|---|
| JDK | 21 |
| Maven | 3.6+ |
| Node.js | 18+ |
| MySQL | 8.0 社区版 |
| MySQL Workbench（可选，用于建模/查看关系图） | 最新版 |

---

## 启动说明

### 1. 准备数据库

1. 安装并启动 MySQL 8.0，默认端口 `3306`
2. 创建数据库（示例名称 `unitix`）：

   ```sql
   CREATE DATABASE unitix DEFAULT CHARACTER SET utf8mb4;
   ```

3. 依次导入建表 / 触发器 / 存储过程 / 视图脚本：

   ```bash
   mysql -u root -p unitix < bighomework.sql
   mysql -u root -p unitix < unitix.sql
   mysql -u root -p unitix < testunitix.sql
   ```

   > 具体导入哪些脚本、导入顺序请根据仓库中实际脚本内容确认，避免重复建表报错。

### 2. 配置后端

打开 `backend/src/main/resources/application.yml`，核对数据库连接串：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/unitix?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: 你的密码
    driver-class-name: com.mysql.cj.jdbc.Driver
```

连接串参数说明：

| 参数 | 说明 | 取值 |
|---|---|---|
| useUnicode | 是否使用 Unicode 字符集，防止乱码 | true |
| characterEncoding | 指定字符编码格式 | utf8 |
| useSSL | 本地开发关闭加密传输，提升连接速度 | false |
| serverTimezone | 强制声明时区，与 MySQL 物理机时区对齐，防止购票/结算时间错位 | Asia/Shanghai |

### 3. 启动后端

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

后端默认监听 `http://localhost:8080`。

### 4. 启动前端

```bash
cd frontend
npm install
npm run dev
```

启动成功后访问终端提示的地址（通常为 `http://localhost:5173`）。

---

## 核心接口一览

| 功能 | 方法 | 路径 | 说明 |
|---|---|---|---|
| 获取活动列表 | GET | `/event/list` | 基于视图 `view_event_details` 查询可购票活动 |
| 购票 | POST | `/ticket/buy` | 触发器校验余票，插入订单并扣减余票 |
| 退票 | POST | `/ticket/refund` | 事务处理，删除订单并恢复余票 |
| 活动结算 | POST | `/event/complete` | 存储过程校验活动是否结束，批量更新订单状态为已完成 |

---

## 常见问题排查

- **后端连不上数据库**：确认 MySQL 服务已启动、端口 3306 未被占用，且 `application.yml` 中的用户名密码正确。
- **中文乱码**：确认连接串中 `useUnicode=true&characterEncoding=utf8` 已正确配置，且数据库/表的字符集为 `utf8mb4`。
- **购票/退票报错**：检查触发器、存储过程是否已成功导入数据库（可在 MySQL Workbench 中查看 `Stored Procedures` 与 `Triggers`）。
- **时间错位问题**：确认连接串中 `serverTimezone=Asia/Shanghai` 已配置，且服务器本地时区与之一致。

---

## 备注

- 本项目为数据库工程课程作业，完整设计说明、评分标准对应的功能演示见 `数据库工程作业.pdf`。
- 请勿将真实数据库密码等敏感信息提交到公开仓库中。
