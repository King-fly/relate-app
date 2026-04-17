import Foundation

// MARK: - Milestone

enum MilestoneType: String, Codable, CaseIterable {
    case anniversary = "anniversary"
    case birthday = "birthday"
    case milestone = "milestone"
    
    var label: String {
        switch self {
        case .anniversary: return "纪念日"
        case .birthday: return "生日"
        case .milestone: return "其他节点"
        }
    }
    
    var iconName: String {
        switch self {
        case .anniversary: return "heart.fill"
        case .birthday: return "gift.fill"
        case .milestone: return "clock.fill"
        }
    }
}

struct Milestone: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var date: String // YYYY-MM-DD
    var type: MilestoneType
}

// MARK: - Habit

struct Habit: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var points: Int
}

// MARK: - Template

enum TemplateCategory: String, Codable, CaseIterable {
    case express = "express"
    case conflict = "conflict"
    case apology = "apology"
    
    var label: String {
        switch self {
        case .express: return "表达需求"
        case .conflict: return "化解冲突"
        case .apology: return "真诚道歉"
        }
    }
}

struct Template: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var category: String
    var title: String
    var content: String
    var tags: [String]
}

// MARK: - App State

struct AppState: Codable {
    var score: Int
    var savedScoreDate: String?
    var completedHabits: [String]
    var lastCheckinDate: String?
    var streak: Int
    var lastActivityDate: String?
    var milestones: [Milestone]
    var habits: [Habit]
    var templates: [Template]
    
    static let defaultState = AppState(
        score: 5,
        savedScoreDate: nil,
        completedHabits: [],
        lastCheckinDate: nil,
        streak: 0,
        lastActivityDate: nil,
        milestones: [
            Milestone(id: "1", title: "相识/在一起", date: "2025-05-20", type: .anniversary),
            Milestone(id: "2", title: "Ta的生日", date: "2026-08-15", type: .birthday)
        ],
        habits: [
            Habit(id: "h1", title: "给了对方一个大大的拥抱", points: 5),
            Habit(id: "h2", title: "好好说了「谢谢」和「早安」", points: 2),
            Habit(id: "h3", title: "今天没有冷暴力，遇到问题直接沟通", points: 10),
            Habit(id: "h4", title: "共同做了一件小事（如做家务/散步）", points: 8)
        ],
        templates: [
            Template(id: "t1", category: "express", title: "非暴力沟通模板",
                     content: "当你[具体行为]时，我感到[具体情绪]，因为我重视[什么需求]。我希望以后我们可以[具体行动]。",
                     tags: ["万能公式", "陈述客观事实"]),
            Template(id: "t2", category: "conflict", title: "叫停冷战",
                     content: "我现在情绪有点激动，可能说不出好听的话。我需要安静30分钟，等我平复下来我们再好好解决，好吗？",
                     tags: ["设立边界", "冷静期"]),
            Template(id: "t3", category: "apology", title: "为情绪失控道歉",
                     content: "对不起，我刚才说话太冲了，我不该那么大声。现在我冷静下来了，我想好好听你说。",
                     tags: ["真诚", "承担责任"]),
            Template(id: "t4", category: "express", title: "表达感谢与爱意",
                     content: "今天看到你[具体做了什么]，我心里觉得特别[感觉]，谢谢你一直这么照顾我。",
                     tags: ["日常升温"])
        ]
    )
}
