import Foundation

/// 场景模型
struct PlayType: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String                // 场景名称
    var desc: String                // 场景详细描述
    var icon: String                // 场景图标名称（SF Symbols名称）
    var createdAt: Date             // 记录创建时间
    var updatedAt: Date             // 记录最后更新时间
    
    init(id: UUID = UUID(), name: String, desc: String = "", icon: String = "mountain.2") {
        self.id = id
        self.name = name
        self.desc = desc
        self.icon = icon
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// 装备模型
struct Equipment: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String                // 装备名称
    var brand: String               // 品牌名称
    var model: String               // 型号
    var desc: String                // 装备描述
    var price: Int                  // 购买价格（单位：分）
    var purchaseDate: Date?         // 购买日期（可选）
    var images: [String]            // 装备图片路径数组
    var categoryId: UUID?           // 所属分类ID（可选）
    var playTypeId: UUID?           // 所属场景ID（可选）
    var notes: String               // 使用备注
    var rating: Int                 // 评分（0-5）
    var createdAt: Date             // 记录创建时间
    var updatedAt: Date             // 记录最后更新时间
    
    init(id: UUID = UUID(),
         name: String,
         brand: String = "",
         model: String = "",
         desc: String = "",
         price: Int = 0,            // 价格，单位：分
         purchaseDate: Date? = nil,
         images: [String] = [],
         categoryId: UUID? = nil,
         playTypeId: UUID? = nil,
         notes: String = "",
         rating: Int = 0) {
        self.id = id
        self.name = name
        self.brand = brand
        self.model = model
        self.desc = desc
        self.price = price
        self.purchaseDate = purchaseDate
        self.images = images
        self.categoryId = categoryId
        self.playTypeId = playTypeId
        self.notes = notes
        self.rating = rating
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// 分类模型
struct Category: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String                // 分类名称
    var desc: String                // 分类描述
    var icon: String                // 分类图标名称（SF Symbols名称）
    var createdAt: Date             // 记录创建时间
    var updatedAt: Date             // 记录最后更新时间
    
    init(id: UUID = UUID(), name: String, desc: String = "", icon: String = "tag") {
        self.id = id
        self.name = name
        self.desc = desc
        self.icon = icon
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension PlayType: Validatable {
    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyName
        }
    }
}

extension Equipment: Validatable {
    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyName
        }
        guard price >= 0 else {
            throw ValidationError.invalidPrice
        }
        guard rating >= 0 && rating <= 5 else {
            throw ValidationError.invalidRating
        }
        for path in images {
            guard !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ValidationError.invalidImagePath
            }
        }
        // 验证名称
        if name.isEmpty {
            throw ValidationError.emptyName
        }
        
        // 验证价格
        if price < 0 {
            throw ValidationError.invalidPrice
        }
        
        // 验证评分
        if rating < 0 || rating > 5 {
            throw ValidationError.invalidRating
        }
        
        // 验证图片路径
        for path in images {
            if !FileManager.default.fileExists(atPath: path) {
                throw ValidationError.invalidImagePath
            }
        }
    }
}

extension Category: Validatable {
    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyName
        }
    }
}
