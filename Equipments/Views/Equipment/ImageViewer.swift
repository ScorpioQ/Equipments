import SwiftUI

struct ImageViewer: View {
    let imagePath: String
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var showDeleteConfirm = false
    var onDelete: (() -> Void)?
    
    // 用于存储图片尺寸和容器尺寸
    @State private var imageSize: CGSize = .zero
    @State private var containerSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            if let image = UIImage(contentsOfFile: imagePath) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(limitOffset(offset, scale: scale))
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / scale
                                        scale = min(max(scale * delta, 1), 4)
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = value.translation
                                    }
                                    .onEnded { value in
                                        offset = limitOffset(value.translation, scale: scale)
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation {
                                scale = scale > 1 ? 1 : 2
                                offset = .zero
                            }
                        }
                        .onAppear {
                            // 获取图片尺寸
                            imageSize = CGSize(width: image.size.width, height: image.size.height)
                            containerSize = geometry.size
                        }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    if onDelete != nil {
                        showDeleteConfirm = true
                    }
                }
        )
        .alert("确认删除", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive) {
                onDelete?()
                isPresented = false
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要删除这张图片吗？")
        }
    }
    
    // 限制图片移动范围
    private func limitOffset(_ offset: CGSize, scale: CGFloat) -> CGSize {
        let scaledImageSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        
        let maxOffsetX = max((scaledImageSize.width - containerSize.width) / 2, 0)
        let maxOffsetY = max((scaledImageSize.height - containerSize.height) / 2, 0)
        
        return CGSize(
            width: max(min(offset.width, maxOffsetX), -maxOffsetX),
            height: max(min(offset.height, maxOffsetY), -maxOffsetY)
        )
    }
}

#Preview {
    NavigationStack {
        ImageViewer(
            imagePath: "",
            isPresented: .constant(true)
        )
    }
}
