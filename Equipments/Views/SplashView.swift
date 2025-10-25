import SwiftUI

/// 启动页视图，显示应用图标和名称
struct SplashView: View {
    var body: some View {
        VStack(spacing: 16) {
            // 应用图标
            Image(systemName: "backpack.circle.fill")
                .font(.system(size: 80))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
            
            // 应用名称
            Text("装备党")
                .font(.largeTitle.bold())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SplashView()
}
