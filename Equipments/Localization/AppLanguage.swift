//
//  AppLanguage.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import Foundation
import SwiftUI

/// 支持的应用内语言，提供与 Locale 的映射及展示文案。
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english = "en"

    var id: String { rawValue }

    /// 匹配 SwiftUI `Locale`，`system` 返回 `nil` 以沿用系统设置。
    var locale: Locale? {
        switch self {
        case .system:
            return nil
        case .simplifiedChinese, .traditionalChinese, .english:
            return Locale(identifier: rawValue)
        }
    }

    /// Picker 使用的本地化标题。
    var localizedTitleKey: LocalizedStringKey {
        switch self {
        case .system:
            return "applanguage.system"
        case .simplifiedChinese:
            return "applanguage.simplifiedChinese"
        case .traditionalChinese:
            return "applanguage.traditionalChinese"
        case .english:
            return "applanguage.english"
        }
    }
}

extension AppLanguage {
    /// 将持久化字符串转换为 `AppLanguage`，默认回退为 `.system`。
    static func fromPersistedValue(_ value: String) -> AppLanguage {
        if value.isEmpty { return .system }
        return AppLanguage(rawValue: value) ?? .system
    }
}
