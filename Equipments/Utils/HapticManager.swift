import UIKit

/// 震动反馈管理器，提供不同类型的震动效果
final class HapticManager {
    /// 单例实例
    static let shared = HapticManager()
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 轻触反馈
    
    /// 轻触反馈生成器
    private lazy var lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    /// 中等强度反馈生成器
    private lazy var mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    /// 重触反馈生成器
    private lazy var heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    /// 软触反馈生成器
    private lazy var softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)
    /// 硬触反馈生成器
    private lazy var rigidImpactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
    /// 选择反馈生成器
    private lazy var selectionGenerator = UISelectionFeedbackGenerator()
    /// 通知反馈生成器
    private lazy var notificationGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - 公共方法
    
    /// 触发轻触反馈，类似物理按键的感觉
    func lightImpact() {
        lightImpactGenerator.impactOccurred()
    }
    
    /// 触发中等强度反馈
    func mediumImpact() {
        mediumImpactGenerator.impactOccurred()
    }
    
    /// 触发重触反馈
    func heavyImpact() {
        heavyImpactGenerator.impactOccurred()
    }
    
    /// 触发软触反馈
    func softImpact() {
        softImpactGenerator.impactOccurred()
    }
    
    /// 触发硬触反馈
    func rigidImpact() {
        rigidImpactGenerator.impactOccurred()
    }
    
    /// 触发选择反馈，用于选择发生变化时
    func selection() {
        selectionGenerator.selectionChanged()
    }
    
    /// 触发成功通知反馈
    func notifySuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// 触发警告通知反馈
    func notifyWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    /// 触发错误通知反馈
    func notifyError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - 准备方法
    
    /// 准备所有反馈生成器
    /// - Note: 在预期可能需要触发反馈的操作之前调用，可以减少首次触发的延迟
    func prepareAll() {
        lightImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
        heavyImpactGenerator.prepare()
        softImpactGenerator.prepare()
        rigidImpactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
}
