import SwiftUI

/// 设置视图，提供应用的设置选项
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("功能开发中", systemImage: "gearshape")
            } description: {
                Text("敬请期待")
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingsView()
}
