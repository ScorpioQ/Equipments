import SwiftUI

/// 统计视图，显示装备相关的统计信息
struct StatisticsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("功能开发中", systemImage: "chart.pie")
            } description: {
                Text("敬请期待")
            }
            .navigationTitle("统计")
        }
    }
}

#Preview {
    StatisticsView()
}
