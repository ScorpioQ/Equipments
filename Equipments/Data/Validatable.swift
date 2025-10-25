import Foundation

/// 可验证协议
/// 实现此协议的类型需要提供数据验证方法
protocol Validatable {
    /// 验证数据是否有效
    /// - Throws: 如果数据无效，抛出ValidationError
    func validate() throws
}

