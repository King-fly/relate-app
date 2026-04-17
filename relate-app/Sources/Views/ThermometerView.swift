import SwiftUI

struct ThermometerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) var colorScheme
    @State private var justSaved = false
    
    private var scoreColor: Color {
        if store.score >= 8 { return .duoGreen }
        if store.score <= 3 { return .duoRed }
        return .duoYellow
    }
    
    private var message: String {
        if store.score >= 8 { return "太棒啦！保持这个热度吧！" }
        if store.score <= 3 { return "亮红灯了，需要坐下来好好聊聊。" }
        return "有点平淡，试着制造小惊喜？"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Title
                VStack(spacing: 6) {
                    Text("今天感觉如何？")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.duoText)
                    Text("为今天的关系状态打个分吧")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.duoTextMuted)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // Face Circle
                ZStack {
                    Circle()
                        .stroke(Color.duoBorder, lineWidth: 4)
                        .frame(width: 160, height: 160)
                    
                    // Fill from bottom
                    Circle()
                        .trim(from: 0, to: CGFloat(store.score) / 10.0)
                        .fill(scoreColor.opacity(0.2))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(180))
                        .animation(.easeInOut(duration: 0.5), value: store.score)
                    
                    // Face
                    Canvas { ctx, size in
                        let cx = size.width / 2
                        let cy = size.height / 2
                        let eyeColor = colorScheme == .dark ? Color(hex: "#dceaea") : Color(hex: "#4b4b4b")
                        
                        // Left eye
                        let leftEye = Path(ellipseIn: CGRect(x: cx - 24, y: cy - 12, width: 10, height: 10))
                        ctx.fill(leftEye, with: .color(eyeColor))
                        
                        // Right eye
                        let rightEye = Path(ellipseIn: CGRect(x: cx + 14, y: cy - 12, width: 10, height: 10))
                        ctx.fill(rightEye, with: .color(eyeColor))
                        
                        // Mouth
                        var mouth = Path()
                        if store.score >= 8 {
                            mouth.move(to: CGPoint(x: cx - 20, y: cy + 10))
                            mouth.addQuadCurve(to: CGPoint(x: cx + 20, y: cy + 10), control: CGPoint(x: cx, y: cy + 30))
                        } else if store.score <= 3 {
                            mouth.move(to: CGPoint(x: cx - 20, y: cy + 20))
                            mouth.addQuadCurve(to: CGPoint(x: cx + 20, y: cy + 20), control: CGPoint(x: cx, y: cy + 5))
                        } else {
                            mouth.move(to: CGPoint(x: cx - 20, y: cy + 14))
                            mouth.addQuadCurve(to: CGPoint(x: cx + 20, y: cy + 14), control: CGPoint(x: cx, y: cy + 20))
                        }
                        ctx.stroke(mouth, with: .color(eyeColor), lineWidth: 4)
                    }
                    .frame(width: 100, height: 100)
                    
                    // Score badge
                    Text("\(store.score)")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.duoText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.duoBg)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.duoBorder, lineWidth: 2))
                        .offset(x: 50, y: -55)
                }
                .padding(.bottom, 40)
                
                // Slider
                VStack(spacing: 12) {
                    Slider(value: Binding(
                        get: { Double(store.score) },
                        set: { store.score = Int($0) }
                    ), in: 1...10, step: 1)
                    .tint(scoreColor)
                    .disabled(store.isSavedToday && !justSaved)
                    .opacity(store.isSavedToday && !justSaved ? 0.5 : 1)
                    .padding(.horizontal, 8)
                    
                    HStack {
                        Text("😡 冰点 (1)")
                        Spacer()
                        Text("😍 完美 (10)")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Message card
                Text(message)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.duoText)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color.duoSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.duoBorder, lineWidth: 2)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // Save button
                Button(action: {
                    if store.isSavedToday { return }
                    store.saveTodayScore()
                    justSaved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { justSaved = false }
                }) {
                    HStack(spacing: 8) {
                        if store.isSavedToday {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .black))
                            Text("今日已记录")
                        } else {
                            Text("保存今日温度")
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(store.isSavedToday ? Color.duoBorder : Color.duoGreen)
                    .cornerRadius(16)
                    .shadow(color: store.isSavedToday ? .clear : Color.duoGreenDark, radius: 0, x: 0, y: 4)
                }
                .disabled(store.isSavedToday && !justSaved)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
