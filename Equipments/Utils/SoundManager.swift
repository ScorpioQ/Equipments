import AVFoundation
import UIKit

/// 音效管理器，提供系统音效播放功能
final class SoundManager {
    /// 单例实例
    static let shared = SoundManager()
    
    /// 音效播放器
    private var audioPlayer: AVAudioPlayer?
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 系统音效
    
    /// 播放系统音效
    /// - Parameter soundID: 系统音效ID
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    /// 播放轻触音效（键盘点击音）
    func playTick() {
        playSystemSound(1104) // 使用系统键盘点击音
    }
    
    /// 播放选择音效
    func playSelect() {
        playSystemSound(1519) // 使用系统选择音效
    }
    
    /// 播放删除音效
    func playDelete() {
        playSystemSound(1155) // 使用系统删除音效
    }
    
    /// 播放成功音效
    func playSuccess() {
        playSystemSound(1520) // 使用系统成功音效
    }
    
    /// 播放错误音效
    func playError() {
        playSystemSound(1521) // 使用系统错误音效
    }
    
    // MARK: - 自定义音效
    
    /// 加载并播放自定义音效
    /// - Parameter name: 音效文件名（不包含扩展名）
    /// - Parameter ext: 音效文件扩展名
    func playSound(name: String, ext: String = "wav") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("找不到音效文件：\(name).\(ext)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("播放音效失败：\(error.localizedDescription)")
        }
    }
}
