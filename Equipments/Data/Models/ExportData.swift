import Foundation

/// 导入导出错误类型
enum ImportError: LocalizedError {
    case incompatibleVersion
    case invalidData
    case missingReference
    
    var errorDescription: String? {
        switch self {
        case .incompatibleVersion:
            return "数据版本不兼容"
        case .invalidData:
            return "数据格式无效"
        case .missingReference:
            return "数据引用缺失"
        }
    }
}

/// 导出数据结构
struct ExportData: Codable {
    static let currentVersion = "1.0"
    
    let version: String
    let exportDate: Date
    let playTypes: [PlayType]
    let categories: [Category]
    let equipments: [Equipment]
    
    init(playTypes: [PlayType],
         categories: [Category],
         equipments: [Equipment],
         exportDate: Date) {
        self.version = Self.currentVersion
        self.exportDate = exportDate
        self.playTypes = playTypes
        self.categories = categories
        self.equipments = equipments
    }
}

/// 场景导出数据结构
struct PlayTypeExport: Codable {
    let id: String                                    // 唯一标识符
    let name: String                                  // 场景名称
    let desc: String                                  // 场景描述
    let icon: String                                  // 场景图标
    let createdAt: Date                              // 创建时间
    let updatedAt: Date                              // 更新时间
}

/// 分类导出数据结构
struct CategoryExport: Codable {
    let id: String                                    // 唯一标识符
    let name: String                                  // 分类名称
    let icon: String                                  // 分类图标
    let createdAt: Date                              // 创建时间
    let updatedAt: Date                              // 更新时间
}

/// 装备导出数据结构
struct EquipmentExport: Codable {
    let id: String                                    // 唯一标识符
    let name: String                                  // 装备名称
    let brand: String                                 // 品牌
    let model: String                                 // 型号
    let desc: String                                  // 描述
    let price: Decimal                                // 价格
    let purchaseDate: Date?                           // 购买日期
    let images: [String]                              // 图片路径
    let categoryId: String?                           // 分类ID
    let playTypeId: String?                           // 场景ID
    let notes: String                                 // 备注
    let rating: Int                                   // 评分
    let createdAt: Date                              // 创建时间
    let updatedAt: Date                              // 更新时间
}
