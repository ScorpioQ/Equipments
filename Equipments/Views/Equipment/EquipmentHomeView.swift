import SwiftUI

/// 装备主页视图，显示场景标签栏和对应的装备列表
struct EquipmentHomeView: View {
    /// 数据管理器实例
    @StateObject private var dataManager = DataManager.shared
    /// 当前选中的场景ID
    @State private var selectedPlayTypeId: UUID?
    /// 是否显示添加场景页面
    @State private var showAddPlayType = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PlayTypeTabBar(
                    selectedPlayTypeId: $selectedPlayTypeId,
                    showAddPlayType: $showAddPlayType
                )
                
                EquipmentContent(selectedPlayTypeId: selectedPlayTypeId)
            }
            .navigationTitle("装备党")
            .sheet(isPresented: $showAddPlayType) {
                AddPlayTypeView()
            }
        }
        .onAppear {
            // 如果有场景但未选中任何场景，默认选中第一个
            if selectedPlayTypeId == nil,
               let firstPlayType = dataManager.getAllPlayTypes().first {
                selectedPlayTypeId = firstPlayType.id
            }
        }
    }
}

/// 场景标签栏
private struct PlayTypeTabBar: View {
    @StateObject private var dataManager = DataManager.shared
    @Binding var selectedPlayTypeId: UUID?
    @Binding var showAddPlayType: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -15) {
                // 场景标签
                ForEach(dataManager.getAllPlayTypes()) { playType in
                    PlayTypeTabButton(
                        playType: playType,
                        isSelected: selectedPlayTypeId == playType.id,
                        equipmentCount: dataManager.getEquipment(forPlayType: playType).count
                    ) {
                        withAnimation {
                            selectedPlayTypeId = playType.id
                        }
                    }
                }
                
                // 添加场景按钮
                Button {
                    showAddPlayType = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(.leading)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

/// 装备内容视图
private struct EquipmentContent: View {
    @StateObject private var dataManager = DataManager.shared
    let selectedPlayTypeId: UUID?
    
    var body: some View {
        if let selectedPlayTypeId,
           let selectedPlayType = dataManager.getPlayType(by: selectedPlayTypeId) {
            EquipmentListView(playType: selectedPlayType)
        } else {
            ContentUnavailableView {
                Label("选择或添加场景", systemImage: "backpack.circle")
            } description: {
                Text("点击右上角的加号按钮添加你的第一个场景")
            }
        }
    }
}

#Preview {
    EquipmentHomeView()
}
