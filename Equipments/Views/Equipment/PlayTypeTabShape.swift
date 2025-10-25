import SwiftUI

/// 场景标签的自定义形状，类似Chrome标签页的形状
struct PlayTypeTabShape: Shape {
    /// 创建标签页形状的路径
    /// - Parameter rect: 形状的边界矩形
    /// - Returns: 标签页形状的路径
    func path(in rect: CGRect) -> Path {
        let cornerRadius: CGFloat = 12
        let trapezoidOffset: CGFloat = 8
        
        var path = Path()
        
        // 左上角
        path.move(to: CGPoint(x: trapezoidOffset, y: 0))
        
        // 上边
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        
        // 右上角圆弧
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: Angle(degrees: -90),
                   endAngle: Angle(degrees: 0),
                   clockwise: false)
        
        // 右边
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        
        // 右下角圆弧
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
                   radius: cornerRadius,
                   startAngle: Angle(degrees: 0),
                   endAngle: Angle(degrees: 90),
                   clockwise: false)
        
        // 下边
        path.addLine(to: CGPoint(x: trapezoidOffset + cornerRadius, y: rect.height))
        
        // 左下角圆弧
        path.addArc(center: CGPoint(x: trapezoidOffset + cornerRadius, y: rect.height - cornerRadius),
                   radius: cornerRadius,
                   startAngle: Angle(degrees: 90),
                   endAngle: Angle(degrees: 180),
                   clockwise: false)
        
        // 左边
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // 左上角圆弧
        path.addArc(center: CGPoint(x: trapezoidOffset + cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: Angle(degrees: 180),
                   endAngle: Angle(degrees: 270),
                   clockwise: false)
        
        path.closeSubpath()
        return path
    }
}
