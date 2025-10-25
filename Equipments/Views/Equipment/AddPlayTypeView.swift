import SwiftUI

/// 添加场景视图，用于创建新的场景
struct AddPlayTypeView: View {
    /// 环境变量，用于关闭当前页面
    @Environment(\.dismiss) private var dismiss
    /// 数据管理器实例
    @StateObject private var dataManager = DataManager.shared
    
    /// 场景名称
    @State private var name = ""
    /// 场景描述
    @State private var desc = ""
    /// 选中的图标名称
    @State private var selectedIcon = "tag"
    /// 是否显示图标选择器
    @State private var showIconPicker = false
    /// 验证错误信息
    @State private var validationError: String?
    
    /// 常用图标列表
    private let commonIcons = [
        "basketball.fill",
        "figure.hiking",
        "tent.fill",
        "bicycle",
        "figure.skiing.downhill",
        "camera.fill",
        "laptopcomputer",
        "gamecontroller.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // 基本信息
                Section {
                    // 场景名称
                    TextField("名称", text: $name)
                    
                    // 场景描述
                    TextField("描述", text: $desc)
                    
                    // 图标选择
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("图标")
                            Spacer()
                            Image(systemName: selectedIcon)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // 常用图标
                Section("常用图标") {
                    // 图标列表
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 44))
                    ], spacing: 10) {
                        ForEach(commonIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color.accentColor : Color(.systemGray6))
                                    .foregroundStyle(selectedIcon == icon ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 错误信息
                if let error = validationError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("新增场景")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 取消按钮
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                // 确定按钮
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        save()
                    }
                }
            }
            .sheet(isPresented: $showIconPicker) {
                SFSymbolsPicker(selectedIcon: $selectedIcon)
            }
            .alert("错误", isPresented: .constant(validationError != nil)) {
                Button("确定") {
                    validationError = nil
                }
            } message: {
                if let validationError = validationError {
                    Text(validationError)
                }
            }
        }
    }
    
    /// 保存场景
    private func save() {
        do {
            // 创建新场景
            try dataManager.createPlayType(
                name: name,
                desc: desc,
                icon: selectedIcon
            )
            // 关闭页面
            dismiss()
        } catch {
            // 显示错误信息
            validationError = error.localizedDescription
        }
    }
}

#Preview {
    AddPlayTypeView()
}
