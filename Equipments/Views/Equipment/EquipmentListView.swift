import SwiftUI

/// 装备列表视图，显示指定场景下的所有装备
struct EquipmentListView: View {
    /// 当前场景
    let playType: PlayType
    
    /// 数据管理器实例
    @StateObject private var dataManager = DataManager.shared
    
    /// 当前选中的装备
    @State private var selectedEquipment: Equipment?
    
    /// 是否显示添加装备页面
    @State private var showAddEquipment = false
    
    /// 获取指定场景下的所有装备
    private var equipments: [Equipment] {
        dataManager.getEquipment(forPlayType: playType)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // 装备列表
                ForEach(equipments.indices, id: \.self) { index in
                    EquipmentRow(equipment: equipments[index])
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedEquipment = equipments[index]
                        }
                }
                .onDelete { indexSet in
                    // 删除装备
                    for index in indexSet {
                        dataManager.deleteEquipment(equipments[index])
                    }
                }
            }
            .navigationTitle(playType.name)
            .toolbar {
                // 编辑按钮
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                // 添加装备按钮
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddEquipment = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedEquipment) { equipment in
                EquipmentDetailView(equipment: equipment)
            }
            .sheet(isPresented: $showAddEquipment) {
                AddEquipmentView(playType: playType)
            }
            .overlay {
                // 如果没有装备，显示提示信息
                if equipments.isEmpty {
                    ContentUnavailableView {
                        Label("暂无装备", systemImage: "backpack")
                    } description: {
                        Text("点击右上角的加号添加装备")
                    }
                }
            }
        }
    }
}

/// 装备列表项视图
struct EquipmentRow: View {
    /// 装备数据
    let equipment: Equipment
    
    /// 计算服役时间
    private var serviceDays: Double {
        guard let purchaseDate = equipment.purchaseDate else { return 0 }
        return Double(Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 装备图片
            if let firstImage = equipment.images.first,
               let image = UIImage(contentsOfFile: firstImage) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // 装备信息
            VStack(alignment: .leading, spacing: 4) {
                // 装备名称
                Text(equipment.name)
                    .font(.headline)
                
                // 服役时间
                if equipment.purchaseDate != nil {
                    Text("服役时间：\(String(format: "%.1f", serviceDays))天")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EquipmentListView(playType: PlayType(name: "篮球", icon: "basketball.fill"))
}
