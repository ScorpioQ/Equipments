//
//  EquipmentsApp.swift
//  Equipments
//
//  Created by 米樵 on 2024/11/22.
//

import SwiftUI

/// 装备管理应用的主入口
@main
struct EquipmentsApp: App {
    /// 数据管理器实例
    @StateObject private var dataManager = DataManager.shared
    
    /// 控制是否显示启动页
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                // 2秒后隐藏启动页
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSplash = false
                }
            }
        }
    }
}
