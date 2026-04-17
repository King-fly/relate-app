import SwiftUI

struct DatesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) var colorScheme
    @State private var showForm = false
    @State private var editingId: String?
    
    // Form fields
    @State private var formTitle = ""
    @State private var formDate = Date()
    @State private var formType: MilestoneType = .anniversary
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.duoRed)
                                .font(.system(size: 20))
                            Text("重要日期")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.duoText)
                        }
                        Text("那些闪闪发光的日子，我都记得")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.duoTextMuted)
                    }
                    Spacer()
                    if !showForm {
                        Button(action: { openAddForm() }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.duoBlue)
                                .frame(width: 40, height: 40)
                                .background(Color.duoSurface)
                                .cornerRadius(20)
                                .overlay(Circle().stroke(Color.duoBorder, lineWidth: 2))
                        }
                    }
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
                
                // Past Milestones (big cards)
                VStack(spacing: 20) {
                    ForEach(pastDates) { item in
                        pastCard(item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                
                // Upcoming section
                if !upcomingDates.isEmpty {
                    Text("即将到来 🎉")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.duoText)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 16)
                    
                    VStack(spacing: 12) {
                        ForEach(upcomingDates) { item in
                            upcomingRow(item)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                if upcomingDates.isEmpty {
                    Text("目前没有将来的安排")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.duoTextMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                }
                
                Spacer().frame(height: 40)
            }
        }
    }
    
    // MARK: - Date Processing
    
    struct ProcessedDate: Identifiable {
        var id: String
        var title: String
        var dateStr: String
        var type: MilestoneType
        var daysPast: Int?   // for past items
        var daysLeft: Int?   // for upcoming items
    }
    
    private var pastDates: [ProcessedDate] {
        let now = Calendar.current.startOfDay(for: Date())
        var items: [ProcessedDate] = []
        
        for m in store.milestones {
            guard let parsed = dateFormatter.date(from: m.date) else { continue }
            let parsedDay = Calendar.current.startOfDay(for: parsed)
            
            if m.type != .birthday && parsedDay < now {
                let diff = Calendar.current.dateComponents([.day], from: parsedDay, to: now).day ?? 0
                items.append(ProcessedDate(id: "\(m.id)-past", title: m.title, dateStr: m.date, type: m.type, daysPast: diff))
            }
        }
        
        items.sort { ($0.daysPast ?? 0) > ($1.daysPast ?? 0) }
        return items
    }
    
    private var upcomingDates: [ProcessedDate] {
        let now = Calendar.current.startOfDay(for: Date())
        var items: [ProcessedDate] = []
        
        for m in store.milestones {
            guard let parsed = dateFormatter.date(from: m.date) else { continue }
            
            if m.type == .birthday || m.type == .anniversary {
                // Recurring: find next occurrence
                let monthDay = String(m.date.suffix(5)) // "MM-DD"
                let currentYear = Calendar.current.component(.year, from: now)
                
                if let thisYear = dateFormatter.date(from: "\(currentYear)-\(monthDay)") {
                    var target = Calendar.current.startOfDay(for: thisYear)
                    if target < now {
                        target = Calendar.current.date(byAdding: .year, value: 1, to: target) ?? target
                    }
                    let diff = Calendar.current.dateComponents([.day], from: now, to: target).day ?? 0
                    items.append(ProcessedDate(id: "\(m.id)-upcoming", title: m.title, dateStr: m.date, type: m.type, daysLeft: diff))
                }
            } else {
                // Non-recurring milestone
                let parsedDay = Calendar.current.startOfDay(for: parsed)
                if parsedDay >= now {
                    let diff = Calendar.current.dateComponents([.day], from: now, to: parsedDay).day ?? 0
                    items.append(ProcessedDate(id: "\(m.id)-upcoming", title: m.title, dateStr: m.date, type: m.type, daysLeft: diff))
                }
            }
        }
        
        items.sort { ($0.daysLeft ?? 0) < ($1.daysLeft ?? 0) }
        return items
    }
    
    // MARK: - Past Big Card
    
    private func pastCard(_ item: ProcessedDate) -> some View {
        ZStack {
            // BG icon watermark
            Image(systemName: item.type.iconName)
                .font(.system(size: 120))
                .foregroundColor(item.type.textColor.opacity(0.05))
                .offset(x: 60, y: -30)
            
            VStack(spacing: 8) {
                Text(item.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(item.daysPast ?? 0)")
                        .font(.system(size: 56, weight: .black))
                        .foregroundColor(item.type.textColor)
                    Text("天")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(item.type.textColor)
                }
                
                Text("起始于 \(item.dateStr)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.duoBorder.opacity(0.5))
                    .cornerRadius(20)
            }
            .padding(.vertical, 28)
            
            // Edit/Delete
            HStack(spacing: 8) {
                Spacer()
                VStack(spacing: 6) {
                    Button(action: { openEditById(item) }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.duoBorder)
                    }
                    Button(action: { removeById(item) }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.duoBorder)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .frame(maxWidth: .infinity)
        .background(Color.duoSurface)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.duoBorder, lineWidth: 2))
        .shadow(color: Color.duoBorder, radius: 0, x: 0, y: 8)
    }
    
    // MARK: - Upcoming Row
    
    private func upcomingRow(_ item: ProcessedDate) -> some View {
        HStack(spacing: 16) {
            // Icon square
            Image(systemName: item.type.iconName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(item.type.bgColor)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 0, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.duoText)
                Text(item.dateStr)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.duoTextMuted)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.daysLeft == 0 ? "今天！" : "还有")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                Text("\(item.daysLeft ?? 0) 天")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(item.type.textColor)
            }
        }
        .padding(16)
        .background(Color.duoSurface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.duoBorder, lineWidth: 2))
        .shadow(color: Color.duoBorder, radius: 0, x: 0, y: 4)
    }
    
    // MARK: - Form
    
    private var formView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(editingId != nil ? "编辑记录" : "添加记录")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.duoText)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("名称")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                TextField("例如：第一次看电影", text: $formTitle)
                    .font(.system(size: 15, weight: .bold))
                    .padding(12)
                    .background(Color.duoBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("日期")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.duoTextMuted)
                        .textCase(.uppercase)
                    DatePicker("", selection: $formDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(8)
                        .background(Color.duoBg)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("类型")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.duoTextMuted)
                        .textCase(.uppercase)
                    Picker("类型", selection: $formType) {
                        ForEach(MilestoneType.allCases, id: \.self) { t in
                            Text(t.label).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(8)
                    .background(Color.duoBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
                }
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
                
                Button(editingId != nil ? "保存记录" : "添加记录") { saveForm() }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.duoBlue)
                    .cornerRadius(12)
                    .shadow(color: Color.duoBlueDark, radius: 0, x: 0, y: 4)
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
        formDate = Date()
        formType = .anniversary
        editingId = nil
        showForm = true
    }
    
    private func openEditById(_ item: ProcessedDate) {
        // Find original milestone
        let realId = item.id.replacingOccurrences(of: "-past", with: "").replacingOccurrences(of: "-upcoming", with: "")
        guard let m = store.milestones.first(where: { $0.id == realId }) else { return }
        formTitle = m.title
        formDate = dateFormatter.date(from: m.date) ?? Date()
        formType = m.type
        editingId = m.id
        showForm = true
    }
    
    private func removeById(_ item: ProcessedDate) {
        let realId = item.id.replacingOccurrences(of: "-past", with: "").replacingOccurrences(of: "-upcoming", with: "")
        store.removeMilestone(id: realId)
    }
    
    private func cancelForm() {
        showForm = false
        editingId = nil
    }
    
    private func saveForm() {
        guard !formTitle.isEmpty else { return }
        let dateStr = dateFormatter.string(from: formDate)
        if let eid = editingId {
            store.updateMilestone(id: eid, title: formTitle, date: dateStr, type: formType)
        } else {
            store.addMilestone(title: formTitle, date: dateStr, type: formType)
        }
        cancelForm()
    }
}
