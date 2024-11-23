import Foundation

/// 统计信息模型
/// 用于存储和计算装备相关的统计数据
struct Statistics {
    let totalValue: Decimal                             // 所有装备的总价值
    let equipmentCount: Int                             // 装备总数量
    let sceneCount: Int                                 // 场景总数量
    let categoryCount: Int                              // 分类总数量
    
    /// 计算每个场景的平均装备数量
    /// - Returns: 如果场景数量大于0，返回平均值；否则返回0
    var averageEquipmentsPerScene: Double {
        guard sceneCount > 0 else { return 0 }
        return Double(equipmentCount) / Double(sceneCount)
    }
    
    /// 计算每个分类的平均装备数量
    /// - Returns: 如果分类数量大于0，返回平均值；否则返回0
    var averageEquipmentsPerCategory: Double {
        guard categoryCount > 0 else { return 0 }
        return Double(equipmentCount) / Double(categoryCount)
    }
    
    /// 计算装备的平均价值
    /// - Returns: 如果装备数量大于0，返回平均值；否则返回0
    var averageEquipmentValue: Decimal {
        guard equipmentCount > 0 else { return 0 }
        return totalValue / Decimal(equipmentCount)
    }
}
