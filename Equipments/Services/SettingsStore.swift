import Foundation
import SwiftUI

enum AppTab: Hashable {
    case equipments
    case scenes
    case settings
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case simplifiedChinese
    case traditionalChinese
    case english

    var id: String { rawValue }

    var localizationKey: LocalizedStringKey {
        switch self {
        case .system:
            return "settings.language.system"
        case .simplifiedChinese:
            return "settings.language.simplified"
        case .traditionalChinese:
            return "settings.language.traditional"
        case .english:
            return "settings.language.english"
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        case .simplifiedChinese:
            return "zh-Hans"
        case .traditionalChinese:
            return "zh-Hant"
        case .english:
            return "en"
        }
    }
}

final class SettingsStore: ObservableObject {
    enum Constants {
        static let languageKey = "app.language"
        static let iCloudKey = "app.icloud.enabled"
        static let lastSelectedTabKey = "app.tab.selected"
    }

    @Published var selectedTab: AppTab {
        didSet {
            UserDefaults.standard.set(selectedTab.storageValue, forKey: Constants.lastSelectedTabKey)
        }
    }

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Constants.languageKey)
        }
    }

    @Published var iCloudSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(iCloudSyncEnabled, forKey: Constants.iCloudKey)
        }
    }

    var selectedLocale: Locale {
        if let identifier = language.localeIdentifier {
            return Locale(identifier: identifier)
        } else {
            return Locale.current
        }
    }

    init(preview: Bool = false) {
        if preview {
            selectedTab = .equipments
            language = .simplifiedChinese
            iCloudSyncEnabled = true
        } else {
            let storedTabValue = UserDefaults.standard.string(forKey: Constants.lastSelectedTabKey)
            selectedTab = AppTab(storageValue: storedTabValue) ?? .equipments

            let storedLanguage = UserDefaults.standard.string(forKey: Constants.languageKey) ?? AppLanguage.system.rawValue
            language = AppLanguage(rawValue: storedLanguage) ?? .system

            if UserDefaults.standard.object(forKey: Constants.iCloudKey) != nil {
                iCloudSyncEnabled = UserDefaults.standard.bool(forKey: Constants.iCloudKey)
            } else {
                iCloudSyncEnabled = true
            }
        }
    }
}

private extension AppTab {
    var storageValue: String {
        switch self {
        case .equipments:
            return "equipments"
        case .scenes:
            return "scenes"
        case .settings:
            return "settings"
        }
    }

    init?(storageValue: String?) {
        guard let storageValue else { return nil }
        switch storageValue {
        case "equipments":
            self = .equipments
        case "scenes":
            self = .scenes
        case "settings":
            self = .settings
        default:
            return nil
        }
    }
}
