import SwiftUI
import PhotosUI

/// 添加装备视图
struct AddEquipmentView: View {
    /// 环境变量，用于关闭当前页面
    @Environment(\.dismiss) private var dismiss
    /// 数据管理器实例
    @StateObject private var dataManager = DataManager.shared
    /// 所属场景
    let playType: PlayType
    
    /// 装备名称
    @State private var name = ""
    /// 品牌
    @State private var brand = ""
    /// 型号
    @State private var model = ""
    /// 描述
    @State private var desc = ""
    /// 价格（元）
    @State private var priceText = ""
    /// 购买日期
    @State private var purchaseDate = Date()
    /// 是否显示日期选择器
    @State private var showDatePicker = false
    /// 验证错误信息
    @State private var validationError: String?
    /// 选中的图片
    @State private var selectedItems: [PhotosPickerItem] = []
    /// 图片路径
    @State private var images: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                // 图片
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(images, id: \.self) { path in
                                if let image = UIImage(contentsOfFile: path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(alignment: .topTrailing) {
                                            Button {
                                                if let index = images.firstIndex(of: path) {
                                                    images.remove(at: index)
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title3)
                                                    .foregroundStyle(.white, .black.opacity(0.7))
                                                    .padding(4)
                                            }
                                        }
                                }
                            }
                            
                            PhotosPicker(selection: $selectedItems,
                                       maxSelectionCount: 10,
                                       matching: .images) {
                                VStack {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 120, height: 120)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .onChange(of: selectedItems) { items in
                                Task {
                                    var paths: [String] = []
                                    for item in items {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            // 保存图片到文档目录
                                            let filename = UUID().uuidString + ".jpg"
                                            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(filename)
                                            if let data = image.jpegData(compressionQuality: 0.8) {
                                                try? data.write(to: URL(fileURLWithPath: path))
                                                paths.append(path)
                                            }
                                        }
                                    }
                                    images.append(contentsOf: paths)
                                    selectedItems.removeAll()
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: 120)
                }
                
                // 基本信息
                Section("基本信息") {
                    // 名称
                    TextField("名称", text: $name)
                    
                    // 品牌
                    TextField("品牌", text: $brand)
                    
                    // 型号
                    TextField("型号", text: $model)
                    
                    // 描述
                    TextField("描述", text: $desc)
                    
                    // 价格
                    TextField("价格", text: $priceText)
                        .keyboardType(.decimalPad)
                    
                    // 购买日期
                    Button {
                        showDatePicker = true
                    } label: {
                        HStack {
                            Text("购买日期")
                            Spacer()
                            Text(purchaseDate.formatted(date: .numeric, time: .omitted))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // 错误信息
                if let error = validationError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("添加装备")
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
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    DatePicker(
                        "购买日期",
                        selection: $purchaseDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .navigationTitle("选择日期")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("确定") {
                                showDatePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    /// 保存装备
    private func save() {
        do {
            // 转换价格文本为分
            let priceInCents: Int
            if let price = Double(priceText) {
                priceInCents = Int(price * 100)
            } else {
                throw ValidationError.invalidPrice
            }
            
            // 创建新装备
            try dataManager.createEquipment(
                name: name,
                brand: brand,
                model: model,
                desc: desc,
                price: priceInCents,
                purchaseDate: purchaseDate,
                images: images,
                playTypeId: playType.id
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
    AddEquipmentView(playType: PlayType(name: "测试场景"))
}
