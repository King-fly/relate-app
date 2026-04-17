import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Relate")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.duoGreen)
                    .tracking(-0.5)
                
                Spacer()
                
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(store.streak > 0 ? .duoYellow : .duoTextMuted)
                        .font(.system(size: 16))
                    Text("连续 \(store.streak) 天")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.duoYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.duoSurface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.duoBorder, lineWidth: 2)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.duoBg.opacity(0.8))
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.duoBorder),
                alignment: .bottom
            )
            
            // Content
            ZStack {
                Color.duoSurfaceSecondary.ignoresSafeArea()
                
                switch selectedTab {
                case 0: ThermometerView()
                case 1: TemplatesView()
                case 2: CheckinsView()
                case 3: DatesView()
                default: ThermometerView()
                }
            }
            
            // Bottom nav
            HStack(spacing: 0) {
                navItem(icon: "heart", activeIcon: "heart.fill", label: "温度计", index: 0)
                navItem(icon: "message", activeIcon: "message.fill", label: "沟通", index: 1)
                navItem(icon: "checkmark.circle", activeIcon: "checkmark.circle.fill", label: "打卡", index: 2)
                navItem(icon: "calendar.circle", activeIcon: "calendar.circle.fill", label: "重要日", index: 3)
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color.duoBg)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.duoBorder),
                alignment: .top
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func navItem(icon: String, activeIcon: String, label: String, index: Int) -> some View {
        let isActive = selectedTab == index
        return Button(action: { withAnimation(.easeInOut(duration: 0.15)) { selectedTab = index } }) {
            VStack(spacing: 4) {
                Image(systemName: isActive ? activeIcon : icon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .scaleEffect(isActive ? 1.1 : 1.0)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(isActive ? .duoBlue : .duoTextMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isActive ? Color.duoBlue.opacity(0.1) : Color.clear)
            .cornerRadius(16)
            .padding(.horizontal, 4)
        }
    }
}
