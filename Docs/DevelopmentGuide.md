# 装备党开发文档

## 一、产品概述
- **产品名称**：装备党（Equipments）
- **目标用户**：需要记录并管理个人装备投入的用户。
- **核心价值**：通过“日均投入”视角帮助用户理解装备的长期投入成本，并按照不同场景集中展示已有装备。
- **平台/技术栈**：iOS 17+，SwiftUI + Core Data + CloudKit。
- **多语言**：简体中文、繁体中文、英文，可在设置页手动切换（优先级高于系统语言）。

## 二、功能模块
| 模块 | 功能要点 |
| ---- | ---- |
| 装备管理 | - 列表浏览、搜索（待实现）<br>- 记录名称、价格、货币、购买日期、场景、备注<br>- 自动计算日均投入<br>- 详情页展示字段，支持编辑、删除 |
| 场景管理 | - 自定义场景名称与标识颜色<br>- 统计场景内装备数、总投入、平均日均投入<br>- 支持场景详情页内直接新增装备 |
| 设置 | - 手动切换应用语言（系统/简体/繁体/英文）<br>- iCloud 同步开关（切换后需重启 App）<br>- 版本信息、开发团队 |
| 数据层 | - Core Data + NSPersistentCloudKitContainer<br>- 运行时动态生成数据模型，避免依赖 .xcdatamodeld 文件<br>- UserDefaults 存储语言、iCloud 开关、最近使用 Tab |

## 三、代码结构
```
Equipments/
├── App/
│   ├── EquipmentsApp.swift        // App 入口，注入环境对象
│   └── RootView.swift             // Tab 总入口
├── Models/
│   ├── Equipment.swift            // 装备实体（NSManagedObject）
│   └── Scene.swift                // 场景实体（NSManagedObject）
├── Services/
│   ├── Color+Hex.swift            // Color ↔ Hex 工具
│   ├── Formatters.swift           // 货币、天数格式化
│   ├── PersistenceController.swift// Core Data & CloudKit 管理
│   └── SettingsStore.swift        // 用户偏好、语言、Tab 状态
├── Views/
│   ├── Equipment/                 // 装备相关界面
│   ├── Scene/                     // 场景相关界面
│   └── Settings/                  // 设置界面
├── en.lproj/Localizable.strings   // 英文文案
├── zh-Hans.lproj/Localizable.strings
└── zh-Hant.lproj/Localizable.strings
```

### 关键类型说明
- **PersistenceController**
  - 统一管理 `NSPersistentCloudKitContainer`，支持内存/SQLite 两种模式。
  - 根据 `SettingsStore.Constants.iCloudKey` 决定是否附加 CloudKit 配置。
  - `preview` 静态实例提供 SwiftUI 预览数据。
- **SettingsStore**
  - `ObservableObject`，存储当前 Tab、语言、iCloud 开关。
  - 提供 `selectedLocale` 给 SwiftUI `Environment`，实现界面语言切换。
- **Equipment / Scene**
  - 手工定义的 `NSManagedObject` 子类，包含计算属性用于业务逻辑（如 `dailyCost`、`totalInvestment`）。

## 四、数据模型
### 实体：Equipment
| 字段 | 类型 | 说明 |
| ---- | ---- | ---- |
| id | UUID | 主键 |
| name | String | 装备名称 |
| price | Double | 总价（统一用货币单位） |
| currencyCode | String? | ISO 4217 货币代码，默认使用当前 Locale |
| purchaseDate | Date | 购买日期 |
| createdAt / updatedAt | Date | 创建/更新时间 |
| notes | String? | 备注 |
| scene | Scene? | 所属场景（可选） |
| dailyCost | Double | 计算属性，价格 / 天数 |

### 实体：Scene
| 字段 | 类型 | 说明 |
| ---- | ---- | ---- |
| id | UUID | 主键 |
| name | String | 场景名称 |
| createdAt | Date | 创建时间 |
| colorHex | String? | 颜色十六进制表示，用于后续个性化（未在 UI 中展示） |
| equipmentSet | Set<Equipment> | 关联装备集合（通过关系实现） |
| totalInvestment | Double | 计算属性，求和所有装备价格 |
| averageDailyCost | Double | 平均日均投入 |

## 五、同步策略（CloudKit）
- 默认启用 CloudKit，同步容器 ID `iCloud.com.example.Equipments`，后后续可根据真实账号调整。
- 切换开关只更新 UserDefaults，实际容器需下次冷启动重新初始化。
- 已开启 `NSPersistentHistoryTracking` 与 `NSPersistentStoreRemoteChangeNotificationPostOptionKey`，方便后续做增量合并。

## 六、多语言策略
- 使用 `LocalizedStringKey` + `.environment(\.locale, settingsStore.selectedLocale)` 实现即时语言切换。
- 所有文案归档在 `Localizable.strings`，三种语言对齐。
- 建议新增文案时同时补齐三份翻译。

## 七、快速上手
1. 打开 `Equipments.xcodeproj`，目标 iOS 17。
2. 如需使用 CloudKit，请在 Apple Developer 中创建对应容器，并修改 `PersistenceController` 中的 `containerIdentifier`。
3. 首次运行可在「场景」页创建场景，再从详情页/装备 Tab 中新增装备数据。

## 八、开发进度与计划

### 8.1 已完成内容（2025-10-24）
- **基础架构**：重建 SwiftUI + Core Data + CloudKit 持久层，提供预览数据与运行环境注入。
- **界面结构**：实现基于 `RootView` 的 Tab 入口，包含装备、场景与设置三大入口。
- **装备功能**：支持装备列表、详情、编辑表单，自动计算日均投入，并可关联场景。
- **场景功能**：提供场景列表、详情页，展示场景内装备统计并支持新增/编辑场景。
- **设置功能**：实现语言切换、iCloud 同步开关提示以及基础的关于信息展示。
- **多语言**：提供简体中文、繁体中文、英文三份 `Localizable.strings`，覆盖现有界面。

> 注：如需回溯具体实现，可参考 `App/RootView.swift`、`Views/Equipment/*`、`Views/Scene/*` 与 `Views/Settings/SettingsView.swift` 等文件。

### 8.2 下一阶段计划
1. **数据体验优化**
   - 装备列表搜索与多维筛选（场景、价格区间、日均投入）。
   - 支持数据导出（CSV/JSON）与导入，便于迁移。
2. **视觉呈现加强**
   - 在列表与详情中应用场景颜色标识。
   - 探索装备详情的数据可视化（折线/柱状图）。
3. **同步与备份增强**
   - 设置页增加同步状态展示与手动刷新入口。
   - 调研本地备份/恢复能力。
4. **质量保证**
   - 编写单元测试覆盖核心计算与 ViewModel。
   - 规划 CI（Xcode Cloud 或 GitHub Actions）。

### 8.3 进度记录
| 日期 | 里程碑 | 说明 |
| ---- | ---- | ---- |
| 2025-10-24 | v0.1 基础搭建 | 完成核心数据模型、Tab 结构、主要页面与多语言配置。 |
| 2025-10-24 | v0.1.1 列表修正 | 修复场景列表的 Core Data 依赖及导航绑定，统一使用 `objectID` 作为标识。 |
| （待更新） | 下一迭代 | 完成后将补充具体内容与日期。 |

---
如需补充新的功能需求或迭代计划，可继续在本文件记录，保持文档作为项目对话的入口。欢迎在 PR 中更新此文档，以便其他协作者快速了解当前上下文。
