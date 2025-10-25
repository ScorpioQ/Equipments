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
            HStack {
                // 场景图标
                Image(systemName: playType.icon)
                    .font(.title3)
                
                // 场景名称
                Text(playType.name)
                    .font(.headline)
                
                Spacer()
                
                // 装备数量
                Text("\(equipmentCount)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            .frame(width: 160, height: 44)
            .background(backgroundColor)
            .clipShape(PlayTypeTabShape())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
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
