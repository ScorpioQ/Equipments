import Foundation

/// 数据验证错误
enum ValidationError: LocalizedError {
    case emptyName                                      // 名称为空
    case invalidPrice                                   // 价格无效（小于0）
    case invalidRating                                  // 评分无效（不在0-5范围内）
    case invalidImagePath                               // 图片路径无效
    case duplicateValue(String)                         // 重复值
    case invalidValue(String)                           // 无效值
    case equipmentNotFound                              // 装备未找到
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "名称不能为空"
        case .invalidPrice:
            return "价格不能为负数"
        case .invalidRating:
            return "评分必须在0到5之间"
        case .invalidImagePath:
            return "图片路径无效"
        case .duplicateValue(let message):
            return message
        case .invalidValue(let message):
            return message
        case .equipmentNotFound:
            return "装备未找到"
        }
    }
}
