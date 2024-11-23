import Foundation

/// 数据管理器
/// 负责处理所有数据的CRUD操作，以及导入导出功能
@MainActor
class DataManager {
    static let shared = DataManager()
    
    private var playTypes: [PlayType] = []
    private var equipments: [Equipment] = []
    private var categories: [Category] = []
    
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
    
    func createPlayType(name: String, description: String = "", icon: String = "mountain.2") throws -> PlayType {
        let playType = PlayType(name: name, desc: description, icon: icon)
        try playType.validate()
        playTypes.append(playType)
        saveData()
        return playType
    }
    
    func getAllPlayTypes() -> [PlayType] {
        return playTypes
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
    
    func createEquipment(name: String,
                        brand: String = "",
                        model: String = "",
                        description: String = "",
                        price: Decimal = 0,
                        purchaseDate: Date? = nil,
                        images: [String] = [],
                        categoryId: UUID? = nil,
                        playTypeId: UUID? = nil,
                        notes: String = "",
                        rating: Int = 0) throws -> Equipment {
        let equipment = Equipment(name: name,
                                brand: brand,
                                model: model,
                                desc: description,
                                price: price,
                                purchaseDate: purchaseDate,
                                images: images,
                                categoryId: categoryId,
                                playTypeId: playTypeId,
                                notes: notes,
                                rating: rating)
        try equipment.validate()
        equipments.append(equipment)
        saveData()
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
    
    func updateEquipment(_ equipment: Equipment) throws {
        try equipment.validate()
        if let index = equipments.firstIndex(where: { $0.id == equipment.id }) {
            var updatedEquipment = equipment
            updatedEquipment.updatedAt = Date()
            equipments[index] = updatedEquipment
            saveData()
        }
    }
    
    func deleteEquipment(_ equipment: Equipment) {
        equipments.removeAll { $0.id == equipment.id }
        saveData()
    }
    
    // MARK: - Category CRUD Operations
    
    func createCategory(name: String, icon: String = "tag") throws -> Category {
        let category = Category(name: name, icon: icon)
        try category.validate()
        categories.append(category)
        saveData()
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
