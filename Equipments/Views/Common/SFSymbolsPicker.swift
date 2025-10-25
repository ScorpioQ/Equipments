import SwiftUI

/// SF Symbols 图标选择器
struct SFSymbolsPicker: View {
    /// 环境变量，用于关闭当前页面
    @Environment(\.dismiss) private var dismiss
    /// 选中的图标名称
    @Binding var selectedIcon: String
    /// 搜索关键词
    @State private var searchText = ""
    
    /// 所有可用的图标名称
    private let allIcons = [
        "tag",
        "backpack.fill",
        "basketball.fill",
        "bicycle",
        "figure.hiking",
        "figure.skiing.downhill",
        "figure.pool.swim",
        "figure.tennis",
        "figure.badminton",
        "figure.volleyball",
        "figure.baseball",
        "figure.bowling",
        "figure.boxing",
        "figure.climbing",
        "figure.dance",
        "figure.disc.sports",
        "figure.fishing",
        "figure.golf",
        "figure.gymnastics",
        "figure.handball",
        "figure.hockey",
        "figure.hunting",
        "figure.indoor.cycle",
        "figure.jumprope",
        "figure.martial.arts",
        "figure.outdoor.cycle",
        "figure.pilates",
        "figure.racquetball",
        "figure.rolling",
        "figure.rugby",
        "figure.run",
        "figure.skating",
        "figure.snowboarding",
        "figure.soccer",
        "figure.softball",
        "figure.squash",
        "figure.surfing",
        "figure.table.tennis",
        "figure.waterpolo",
        "figure.yoga",
        "tent.fill",
        "mountain.2.fill",
        "water.waves",
        "snow",
        "leaf.fill",
        "camera.fill",
        "video.fill",
        "music.note",
        "paintbrush.fill",
        "pencil",
        "book.fill",
        "gamecontroller.fill",
        "dumbbell.fill",
        "heart.fill",
        "star.fill",
        "flag.fill",
        "location.fill",
        "map.fill",
        "car.fill",
        "airplane",
        "bus.fill",
        "tram.fill",
        "ferry.fill",
        "bicycle.circle.fill",
        "scooter",
        "bed.double.fill",
        "house.fill",
        "building.fill",
        "cart.fill",
        "bag.fill",
        "creditcard.fill",
        "gift.fill",
        "pills.fill",
        "cross.case.fill",
        "stethoscope",
        "briefcase.fill",
        "printer.fill",
        "tv.fill",
        "desktopcomputer",
        "laptopcomputer",
        "keyboard",
        "mouse.fill",
        "headphones",
        "speaker.wave.3.fill",
        "mic.fill",
        "phone.fill",
        "envelope.fill",
        "paperplane.fill",
        "bubble.left.fill",
        "calendar",
        "clock.fill",
        "alarm.fill",
        "stopwatch.fill",
        "timer",
        "thermometer",
        "umbrella.fill",
        "cloud.fill",
        "sun.max.fill",
        "moon.fill",
        "bolt.fill",
        "wind",
        "drop.fill",
        "flame.fill",
        "lightbulb.fill",
        "battery.100",
        "wifi",
        "antenna.radiowaves.left.and.right",
        "lock.fill",
        "key.fill",
        "gear",
        "hammer.fill",
        "wrench.fill",
        "scissors",
        "eyedropper.full",
        "ruler.fill",
        "scale.3d",
        "camera.metering.matrix",
        "slider.horizontal.3",
        "square.grid.3x3.fill",
        "rectangle.grid.3x2.fill",
        "circle.grid.3x3.fill",
        "person.fill",
        "person.2.fill",
        "person.3.fill",
        "person.crop.circle.fill",
        "person.crop.square.fill",
        "person.crop.rectangle.fill",
        "person.badge.plus",
        "person.badge.minus",
        "person.fill.checkmark",
        "person.fill.xmark",
        "person.fill.questionmark",
        "person.fill.turn.right",
        "person.fill.turn.down",
        "person.fill.viewfinder",
        "eye.fill",
        "eye.slash.fill",
        "hand.raised.fill",
        "hand.point.up.fill",
        "hand.thumbsup.fill",
        "hand.thumbsdown.fill",
        "hand.wave.fill",
        "hands.clap.fill",
        "hands.sparkles.fill"
    ]
    
    /// 过滤后的图标列表
    private var filteredIcons: [String] {
        if searchText.isEmpty {
            return allIcons
        } else {
            return allIcons.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 60))
                ], spacing: 20) {
                    ForEach(filteredIcons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            VStack {
                                Image(systemName: icon)
                                    .font(.title)
                                    .frame(height: 44)
                                
                                Text(icon)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding()
            }
            .navigationTitle("选择图标")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "搜索图标")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SFSymbolsPicker(selectedIcon: .constant("tag"))
}
