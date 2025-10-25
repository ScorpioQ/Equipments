import SwiftUI

/// 主标签视图，包含装备、统计和设置三个标签页
struct MainTabView: View {
    /// 当前选中的标签页索引
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 装备主页标签
            EquipmentHomeView()
                .tabItem {
                    Label("装备", systemImage: "backpack.fill")
                }
                .tag(0)
            
            // 统计页面标签
            StatisticsView()
                .tabItem {
                    Label("统计", systemImage: "chart.pie.fill")
                }
                .tag(1)
            
            // 设置页面标签
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
}
