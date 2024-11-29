import SwiftUI

/// 场景标签按钮，显示场景图标、名称和装备数量
struct PlayTypeTabButton: View {
    /// 场景数据
    let playType: PlayType
    /// 是否被选中
    let isSelected: Bool
    /// 场景下的装备数量
    let equipmentCount: Int
    /// 点击事件回调
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    /// 背景颜色
    private var backgroundColor: Color {
        if isPressed {
            return Color(.systemGray4)
        } else if isSelected {
            return .white
        } else {
            return Color(.systemGray5)
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                // 场景图标和名称
                HStack {
                    Image(systemName: playType.icon)
                        .font(.title3)
                    
                    Text(playType.name)
                        .font(.headline)
                }
                
                // 装备数量
                Text("\(equipmentCount)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlayTypeButtonStyle())
    }
}

/// 自定义按钮样式
private struct PlayTypeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        PlayTypeTabButton(
            playType: PlayType(name: "篮球", icon: "basketball.fill"),
            isSelected: true,
            equipmentCount: 5,
            action: {}
        )
        PlayTypeTabButton(
            playType: PlayType(name: "徒步", icon: "figure.hiking"),
            isSelected: false,
            equipmentCount: 3,
            action: {}
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
