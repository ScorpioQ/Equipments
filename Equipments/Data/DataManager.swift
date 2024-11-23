import Foundation
import Combine

/// 数据管理器
/// 负责处理所有数据的CRUD操作，以及导入导出功能
@MainActor
class DataManager: ObservableObject {
    /// 单例实例
    static let shared = DataManager()
    
    /// 所有场景数据
    @Published private var playTypes: [PlayType] = []
    /// 所有装备数据
    @Published private var equipments: [Equipment] = []
    /// 所有分类数据
    @Published private var categories: [Category] = []
    
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var playTypesURL: URL {
        documentsDirectory.appendingPathComponent("playTypes.json")
    }
    
    private var equipmentsURL: URL {
        documentsDirectory.appendingPathComponent("equipments.json")
    }
    
    private var categoriesURL: URL {
        documentsDirectory.appendingPathComponent("categories.json")
    }
    
    private init() {
        loadData()
        
        // 如果没有数据，添加一些预设数据
        if playTypes.isEmpty {
            do {
                // 创建预设场景
                let basketball = try createPlayType(name: "篮球", desc: "篮球运动相关装备", icon: "basketball.fill")
                let hiking = try createPlayType(name: "徒步", desc: "户外徒步相关装备", icon: "figure.hiking")
                let camping = try createPlayType(name: "露营", desc: "野营相关装备", icon: "tent.fill")
                
                // 创建预设装备
                _ = try createEquipment(
                    name: "Nike Zoom GT Jump",
                    brand: "Nike",
                    model: "DC9834-400",
                    desc: "实战篮球鞋",
                    price: 139900,  // 1399.00元
                    purchaseDate: Calendar.current.date(byAdding: .day, value: -60, to: Date()),
                    playTypeId: basketball.id
                )
                
                _ = try createEquipment(
                    name: "Wilson 篮球",
                    brand: "Wilson",
                    model: "WTB0118IB07",
                    desc: "室内外通用篮球",
                    price: 39900,   // 399.00元
                    purchaseDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
                    playTypeId: basketball.id
                )
                
                _ = try createEquipment(
                    name: "探路者登山鞋",
                    brand: "TOREAD",
                    model: "TFAI91031",
                    desc: "防水透气登山鞋",
                    price: 59900,   // 599.00元
                    purchaseDate: Calendar.current.date(byAdding: .day, value: -90, to: Date()),
                    playTypeId: hiking.id
                )
                
                _ = try createEquipment(
                    name: "牧高笛帐篷",
                    brand: "MOBI GARDEN",
                    model: "NXZQU61008",
                    desc: "三季帐，2-3人",
                    price: 99900,   // 999.00元
                    purchaseDate: Calendar.current.date(byAdding: .day, value: -120, to: Date()),
                    playTypeId: camping.id
                )
            } catch {
                print("Error creating preset data: \(error)")
            }
        }
    }
    
    // MARK: - Data Loading and Saving
    
    private func loadData() {
        do {
            if let data = try? Data(contentsOf: playTypesURL) {
                playTypes = try decoder.decode([PlayType].self, from: data)
            }
            if let data = try? Data(contentsOf: equipmentsURL) {
                equipments = try decoder.decode([Equipment].self, from: data)
            }
            if let data = try? Data(contentsOf: categoriesURL) {
                categories = try decoder.decode([Category].self, from: data)
            }
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    private func saveData() {
        do {
            let playTypesData = try encoder.encode(playTypes)
            try playTypesData.write(to: playTypesURL)
            
            let equipmentsData = try encoder.encode(equipments)
            try equipmentsData.write(to: equipmentsURL)
            
            let categoriesData = try encoder.encode(categories)
            try categoriesData.write(to: categoriesURL)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    // MARK: - PlayType CRUD Operations
    
    /// 创建新场景
    /// - Parameters:
    ///   - name: 场景名称
    ///   - desc: 场景描述
    ///   - icon: 场景图标
    /// - Returns: 创建的场景
    func createPlayType(name: String, desc: String = "", icon: String = "tag") throws -> PlayType {
        // 验证输入
        if name.isEmpty {
            throw ValidationError.emptyName
        }
        
        // 检查名称是否重复
        if playTypes.contains(where: { $0.name == name }) {
            throw ValidationError.duplicateValue("场景名称已存在")
        }
        
        // 创建新场景
        let playType = PlayType(name: name, desc: desc, icon: icon)
        playTypes.append(playType)
        
        // 保存数据
        try saveData()
        
        return playType
    }
    
    func getAllPlayTypes() -> [PlayType] {
        return playTypes
    }
    
    /// 根据ID获取场景
    /// - Parameter id: 场景ID
    /// - Returns: 场景，如果不存在则返回nil
    func getPlayType(by id: UUID) -> PlayType? {
        return playTypes.first { $0.id == id }
    }
    
    func updatePlayType(_ playType: PlayType) throws {
        try playType.validate()
        if let index = playTypes.firstIndex(where: { $0.id == playType.id }) {
            var updatedPlayType = playType
            updatedPlayType.updatedAt = Date()
            playTypes[index] = updatedPlayType
            saveData()
        }
    }
    
    func deletePlayType(_ playType: PlayType) {
        playTypes.removeAll { $0.id == playType.id }
        // 删除相关的装备引用
        equipments = equipments.map { equipment in
            var updatedEquipment = equipment
            if equipment.playTypeId == playType.id {
                updatedEquipment.playTypeId = nil
            }
            return updatedEquipment
        }
        saveData()
    }
    
    // MARK: - Equipment CRUD Operations
    
    /// 创建新装备
    /// - Parameters:
    ///   - name: 装备名称
    ///   - brand: 品牌
    ///   - model: 型号
    ///   - desc: 描述
    ///   - price: 价格（单位：分）
    ///   - purchaseDate: 购买日期
    ///   - images: 图片
    ///   - categoryId: 所属分类ID
    ///   - playTypeId: 所属场景ID
    ///   - notes: 备注
    ///   - rating: 评分
    /// - Returns: 创建的装备
    func createEquipment(name: String,
                        brand: String = "",
                        model: String = "",
                        desc: String = "",
                        price: Int = 0,
                        purchaseDate: Date? = nil,
                        images: [String] = [],
                        categoryId: UUID? = nil,
                        playTypeId: UUID? = nil,
                        notes: String = "",
                        rating: Int = 0) throws -> Equipment {
        let equipment = Equipment(name: name,
                                brand: brand,
                                model: model,
                                desc: desc,
                                price: price,
                                purchaseDate: purchaseDate,
                                images: images,
                                categoryId: categoryId,
                                playTypeId: playTypeId,
                                notes: notes,
                                rating: rating)
        try equipment.validate()
        equipments.append(equipment)
        
        // 保存数据
        try saveData()
        
        return equipment
    }
    
    func getAllEquipment() -> [Equipment] {
        return equipments
    }
    
    func getEquipment(forPlayType playType: PlayType) -> [Equipment] {
        return equipments.filter { $0.playTypeId == playType.id }
    }
    
    func getEquipment(forCategory category: Category) -> [Equipment] {
        return equipments.filter { $0.categoryId == category.id }
    }
    
    /// 更新装备
    func updateEquipment(_ equipment: Equipment) throws {
        // 验证数据
        try equipment.validate()
        
        // 查找并更新装备
        if let index = equipments.firstIndex(where: { $0.id == equipment.id }) {
            equipments[index] = equipment
            // 保存数据
            try saveData()
        } else {
            throw ValidationError.equipmentNotFound
        }
    }
    
    func deleteEquipment(_ equipment: Equipment) {
        equipments.removeAll { $0.id == equipment.id }
        saveData()
    }
    
    // MARK: - Category CRUD Operations
    
    /// 创建新分类
    /// - Parameters:
    ///   - name: 分类名称
    ///   - desc: 分类描述
    ///   - icon: 分类图标
    /// - Returns: 创建的分类
    func createCategory(name: String, desc: String = "", icon: String = "tag") throws -> Category {
        // 验证输入
        if name.isEmpty {
            throw ValidationError.emptyName
        }
        
        // 检查名称是否重复
        if categories.contains(where: { $0.name == name }) {
            throw ValidationError.duplicateValue("分类名称已存在")
        }
        
        // 创建新分类
        let category = Category(name: name, desc: desc, icon: icon)
        categories.append(category)
        
        // 保存数据
        try saveData()
        
        return category
    }
    
    func getAllCategories() -> [Category] {
        return categories
    }
    
    func updateCategory(_ category: Category) throws {
        try category.validate()
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            var updatedCategory = category
            updatedCategory.updatedAt = Date()
            categories[index] = updatedCategory
            saveData()
        }
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        // 删除相关的装备引用
        equipments = equipments.map { equipment in
            var updatedEquipment = equipment
            if equipment.categoryId == category.id {
                updatedEquipment.categoryId = nil
            }
            return updatedEquipment
        }
        saveData()
    }
    
    // MARK: - Import/Export Operations
    
    func exportAllData() -> ExportData {
        return ExportData(playTypes: playTypes,
                         categories: categories,
                         equipments: equipments,
                         exportDate: Date())
    }
    
    func importData(_ data: ExportData) throws {
        // 检查版本兼容性
        guard data.version == ExportData.currentVersion else {
            throw ImportError.incompatibleVersion
        }
        
        // 直接替换现有数据
        playTypes = data.playTypes
        categories = data.categories
        equipments = data.equipments
        
        // 保存到文件
        saveData()
    }
}
