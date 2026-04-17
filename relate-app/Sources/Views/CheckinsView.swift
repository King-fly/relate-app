import SwiftUI

struct CheckinsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) var colorScheme
    @State private var showForm = false
    @State private var editingId: String?
    @State private var formTitle = ""
    @State private var formPoints: Int = 5
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header + Progress
                VStack(spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("每日升温")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.duoText)
                            Text("一点一滴攒积分")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.duoTextMuted)
                        }
                        Spacer()
                        
                        HStack(spacing: 8) {
                            if !showForm {
                                Button(action: { openAddForm() }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.duoGreen)
                                        .frame(width: 40, height: 40)
                                        .background(Color.duoSurface)
                                        .cornerRadius(20)
                                        .overlay(Circle().stroke(Color.duoBorder, lineWidth: 2))
                                }
                            }
                            
                            // Points badge
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.duoYellow)
                                    .font(.system(size: 18))
                                Text("\(store.totalPoints)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.duoYellow)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.duoSurface)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.duoBorder, lineWidth: 2)
                            )
                        }
                    }
                    
                    // Duolingo progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.duoBorder)
                                .frame(height: 16)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.duoGreen)
                                .frame(width: max(geo.size.width * store.progressPercentage, 0), height: 16)
                                .animation(.easeOut(duration: 0.5), value: store.progressPercentage)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 4)
                                        .padding(.horizontal, 8)
                                        .offset(y: -3),
                                    alignment: .top
                                )
                        }
                    }
                    .frame(height: 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Form
                if showForm {
                    formView
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
                
                // Habits list
                VStack(spacing: 12) {
                    ForEach(store.habits) { habit in
                        habitRow(habit)
                    }
                    
                    if store.habits.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 48))
                                .foregroundColor(.duoBorder)
                            Text("还没有任何打卡项，马上添加一个吧！")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.duoTextMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Habit Row
    
    private func habitRow(_ habit: Habit) -> some View {
        let isDone = store.completedHabits.contains(habit.id)
        
        return HStack(spacing: 16) {
            // Checkbox
            Button(action: { store.toggleHabit(habit.id) }) {
                ZStack {
                    Circle()
                        .stroke(isDone ? Color.duoGreen : Color.duoBorder, lineWidth: 2)
                        .frame(width: 32, height: 32)
                    if isDone {
                        Circle()
                            .fill(Color.duoGreen)
                            .frame(width: 32, height: 32)
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isDone ? .duoGreen : .duoText)
                    .strikethrough(isDone, color: .duoGreen.opacity(0.5))
                Text("+\(habit.points) 分")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.duoYellow)
            }
            
            Spacer()
            
            // Edit & Delete
            HStack(spacing: 2) {
                Button(action: { openEditForm(habit) }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.duoTextMuted)
                        .frame(width: 28, height: 28)
                }
                Button(action: { store.removeHabit(id: habit.id) }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.duoTextMuted)
                        .frame(width: 28, height: 28)
                }
            }
        }
        .padding(16)
        .background(isDone ? Color.duoGreen.opacity(0.1) : Color.duoSurface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isDone ? Color.duoGreen.opacity(0.3) : Color.duoBorder, lineWidth: 2)
        )
        .shadow(color: isDone ? .clear : Color.duoBorder, radius: 0, x: 0, y: isDone ? 0 : 4)
    }
    
    // MARK: - Form
    
    private var formView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(editingId != nil ? "编辑互动习惯" : "添加互动习惯")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.duoText)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("内容")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                TextField("例如：一起做一顿饭", text: $formTitle)
                    .font(.system(size: 15, weight: .bold))
                    .padding(12)
                    .background(Color.duoBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("升温积分")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                Stepper("\(formPoints) 分", value: $formPoints, in: 1...100)
                    .font(.system(size: 15, weight: .bold))
                    .padding(12)
                    .background(Color.duoBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
            }
            
            HStack(spacing: 12) {
                Button("取消") { cancelForm() }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.duoText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.duoSurface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
                
                Button("保存") { saveForm() }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.duoGreen)
                    .cornerRadius(12)
                    .shadow(color: Color.duoGreenDark, radius: 0, x: 0, y: 4)
            }
        }
        .padding(20)
        .background(Color.duoSurface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.duoBorder, lineWidth: 2))
    }
    
    // MARK: - Actions
    
    private func openAddForm() {
        formTitle = ""
        formPoints = 5
        editingId = nil
        showForm = true
    }
    
    private func openEditForm(_ h: Habit) {
        formTitle = h.title
        formPoints = h.points
        editingId = h.id
        showForm = true
    }
    
    private func cancelForm() {
        showForm = false
        editingId = nil
    }
    
    private func saveForm() {
        guard !formTitle.isEmpty else { return }
        if let eid = editingId {
            store.updateHabit(id: eid, title: formTitle, points: formPoints)
        } else {
            store.addHabit(title: formTitle, points: formPoints)
        }
        cancelForm()
    }
}
