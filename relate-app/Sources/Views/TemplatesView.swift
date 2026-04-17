import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) var colorScheme
    @State private var activeCategory = "express"
    @State private var copiedId: String?
    @State private var showForm = false
    @State private var editingId: String?
    
    // Form fields
    @State private var formCategory = "express"
    @State private var formTitle = ""
    @State private var formContent = ""
    @State private var formTags = ""
    
    private let categories: [(id: String, label: String)] = [
        ("express", "表达需求"),
        ("conflict", "化解冲突"),
        ("apology", "真诚道歉")
    ]
    
    private var filteredTemplates: [Template] {
        store.templates.filter { $0.category == activeCategory }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                                .foregroundColor(.duoBlue)
                                .font(.system(size: 22))
                            Text("沟通话术包")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.duoText)
                        }
                        Text("一键复制，让沟通不再内耗")
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
                                .overlay(
                                    Circle().stroke(Color.duoBorder, lineWidth: 2)
                                )
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
                
                // Category Picker
                HStack(spacing: 0) {
                    ForEach(categories, id: \.id) { cat in
                        Button(action: { activeCategory = cat.id }) {
                            Text(cat.label)
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(activeCategory == cat.id ? .duoBlue : .duoTextMuted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(activeCategory == cat.id ? Color.duoSurface : Color.clear)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(4)
                .background(Color.duoBorder)
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                
                // Template Cards
                VStack(spacing: 16) {
                    ForEach(filteredTemplates) { tpl in
                        templateCard(tpl)
                    }
                    
                    if filteredTemplates.isEmpty {
                        Text("该分类下还没有话术哦～")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.duoTextMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Template Card
    
    private func templateCard(_ tpl: Template) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tpl.title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.duoText)
                Spacer()
                
                // Edit & Delete
                HStack(spacing: 4) {
                    Button(action: { openEditForm(tpl) }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.duoTextMuted)
                            .frame(width: 32, height: 32)
                    }
                    Button(action: { store.removeTemplate(id: tpl.id) }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.duoTextMuted)
                            .frame(width: 32, height: 32)
                    }
                }
            }
            
            // Content box
            Text(tpl.content)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.duoText)
                .lineSpacing(4)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#1a2f4c")) : UIColor(Color(hex: "#f0f9ff")) })
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#2e4d75")) : UIColor(Color(hex: "#bae6fd")) }), lineWidth: 2)
                )
            
            // Tags
            HStack(spacing: 8) {
                ForEach(tpl.tags, id: \.self) { tag in
                    Text("# \(tag)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.duoTextMuted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.duoBg)
                        .cornerRadius(6)
                }
            }
            
            // Copy button
            Button(action: { handleCopy(tpl) }) {
                HStack(spacing: 6) {
                    Image(systemName: copiedId == tpl.id ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, weight: .bold))
                    Text(copiedId == tpl.id ? "已复制到剪贴板" : "一键复制")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(copiedId == tpl.id ? Color.duoBorder : Color.duoBlue)
                .cornerRadius(16)
                .shadow(color: copiedId == tpl.id ? .clear : Color.duoBlueDark, radius: 0, x: 0, y: 4)
            }
        }
        .padding(20)
        .background(Color.duoSurface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.duoBorder, lineWidth: 2)
        )
    }
    
    // MARK: - Form
    
    private var formView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(editingId != nil ? "编辑话术" : "添加话术")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.duoText)
            
            // Category picker
            VStack(alignment: .leading, spacing: 4) {
                Text("分类")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                Picker("分类", selection: $formCategory) {
                    ForEach(categories, id: \.id) { cat in
                        Text(cat.label).tag(cat.id)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text("标题")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                TextField("例如：叫停冷战", text: $formTitle)
                    .font(.system(size: 15, weight: .bold))
                    .padding(12)
                    .background(Color.duoBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("话术内容")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                TextEditor(text: $formContent)
                    .font(.system(size: 15, weight: .bold))
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color.duoBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
            }
            
            // Tags
            VStack(alignment: .leading, spacing: 4) {
                Text("标签 (用逗号分隔)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.duoTextMuted)
                    .textCase(.uppercase)
                TextField("例如：真诚, 承担责任", text: $formTags)
                    .font(.system(size: 15, weight: .bold))
                    .padding(12)
                    .background(Color.duoBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.duoBorder, lineWidth: 2))
            }
            
            // Buttons
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
                    .background(Color.duoBlue)
                    .cornerRadius(12)
                    .shadow(color: Color.duoBlueDark, radius: 0, x: 0, y: 4)
            }
        }
        .padding(20)
        .background(Color.duoSurface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.duoBorder, lineWidth: 2)
        )
    }
    
    // MARK: - Actions
    
    private func handleCopy(_ tpl: Template) {
        UIPasteboard.general.string = tpl.content
        copiedId = tpl.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiedId = nil }
    }
    
    private func openAddForm() {
        formCategory = activeCategory
        formTitle = ""
        formContent = ""
        formTags = ""
        editingId = nil
        showForm = true
    }
    
    private func openEditForm(_ tpl: Template) {
        formCategory = tpl.category
        formTitle = tpl.title
        formContent = tpl.content
        formTags = tpl.tags.joined(separator: ", ")
        editingId = tpl.id
        showForm = true
    }
    
    private func cancelForm() {
        showForm = false
        editingId = nil
    }
    
    private func saveForm() {
        guard !formTitle.isEmpty else { return }
        let tags = formTags.components(separatedBy: CharacterSet(charactersIn: ",，")).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if let eid = editingId {
            store.updateTemplate(id: eid, category: formCategory, title: formTitle, content: formContent, tags: tags)
        } else {
            store.addTemplate(category: formCategory, title: formTitle, content: formContent, tags: tags)
        }
        cancelForm()
    }
}
