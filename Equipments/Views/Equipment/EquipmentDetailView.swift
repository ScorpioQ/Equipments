import SwiftUI
import PhotosUI

/// 装备详情视图
struct EquipmentDetailView: View {
    /// 环境变量，用于关闭页面
    @Environment(\.dismiss) private var dismiss
    /// 数据管理器实例
    @StateObject private var dataManager = DataManager.shared
    /// 装备数据
    let equipment: Equipment
    
    /// 是否处于编辑模式
    @State private var isEditing = false
    /// 选中的图片
    @State private var selectedItems: [PhotosPickerItem] = []
    /// 验证错误信息
    @State private var validationError: String?
    /// 当前查看的图片
    @State private var selectedImage: String?
    /// 是否显示图片浏览器
    @State private var showImageViewer = false
    
    // 编辑状态的临时数据
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var desc: String = ""
    @State private var priceText: String = ""
    @State private var purchaseDate: Date = Date()
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
                                            if isEditing {
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
                                        .onTapGesture {
                                            selectedImage = path
                                            showImageViewer = true
                                        }
                                }
                            }
                            
                            if isEditing {
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
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: 120)
                }
                
                // 基本信息
                Section("基本信息") {
                    if isEditing {
                        // 名称
                        TextField("名称", text: $name)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // 品牌
                        TextField("品牌", text: $brand)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // 型号
                        TextField("型号", text: $model)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // 描述
                        TextField("描述", text: $desc)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // 价格
                        TextField("价格", text: $priceText)
                            .keyboardType(.decimalPad)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        // 购买日期
                        DatePicker("购买日期", selection: $purchaseDate, displayedComponents: .date)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        // 名称
                        LabeledContent("名称", value: equipment.name)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        
                        // 品牌
                        if !equipment.brand.isEmpty {
                            LabeledContent("品牌", value: equipment.brand)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        // 型号
                        if !equipment.model.isEmpty {
                            LabeledContent("型号", value: equipment.model)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        // 描述
                        if !equipment.desc.isEmpty {
                            LabeledContent("描述", value: equipment.desc)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        // 价格
                        if equipment.price > 0 {
                            LabeledContent("价格") {
                                Text("¥\(String(format: "%.2f", Double(equipment.price) / 100.0))")
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        // 购买日期
                        if let purchaseDate = equipment.purchaseDate {
                            LabeledContent("购买日期") {
                                Text(purchaseDate.formatted(date: .numeric, time: .omitted))
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
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
            .navigationTitle("装备详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isEditing {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                startEditing()
                            }
                        } label: {
                            Text("编辑")
                        }
                    }
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            withAnimation(.spring(duration: 0.3)) {
                                isEditing = false
                                loadData()
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") {
                            withAnimation(.spring(duration: 0.3)) {
                                save()
                            }
                        }
                    }
                }
            }
            .onAppear {
                // 加载初始数据
                loadData()
            }
            .sheet(isPresented: $showImageViewer) {
                if let path = selectedImage {
                    NavigationStack {
                        ImageViewer(
                            imagePath: path,
                            isPresented: $showImageViewer
                        )
                    }
                }
            }
        }
    }
    
    /// 加载初始数据
    private func loadData() {
        name = equipment.name
        brand = equipment.brand
        model = equipment.model
        desc = equipment.desc
        priceText = String(format: "%.2f", Double(equipment.price) / 100.0)
        purchaseDate = equipment.purchaseDate ?? Date()
        images = equipment.images
    }
    
    /// 开始编辑
    private func startEditing() {
        // 加载当前数据
        loadData()
        
        // 进入编辑模式
        isEditing = true
    }
    
    /// 保存修改
    private func save() {
        do {
            // 转换价格文本为分
            let priceInCents: Int
            if let price = Double(priceText) {
                priceInCents = Int(price * 100)
            } else {
                throw ValidationError.invalidPrice
            }
            
            // 创建更新后的装备
            var updatedEquipment = equipment
            updatedEquipment.name = name
            updatedEquipment.brand = brand
            updatedEquipment.model = model
            updatedEquipment.desc = desc
            updatedEquipment.price = priceInCents
            updatedEquipment.purchaseDate = purchaseDate
            updatedEquipment.images = images
            
            // 保存更新
            try dataManager.updateEquipment(updatedEquipment)
            
            // 退出编辑模式
            isEditing = false
            validationError = nil
        } catch {
            validationError = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        EquipmentDetailView(equipment: Equipment(
            name: "测试装备",
            brand: "测试品牌",
            model: "测试型号",
            desc: "这是一个测试装备",
            price: 99999,  // 999.99元
            purchaseDate: Date()
        ))
    }
}
