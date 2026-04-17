import Foundation
import Combine

class AppStore: ObservableObject {
    @Published var score: Int
    @Published var savedScoreDate: String?
    @Published var completedHabits: [String]
    @Published var lastCheckinDate: String?
    @Published var streak: Int
    @Published var lastActivityDate: String?
    @Published var milestones: [Milestone]
    @Published var habits: [Habit]
    @Published var templates: [Template]
    
    private let storageKey = "relate_app_state_v2"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let state = try? JSONDecoder().decode(AppState.self, from: data) {
            self.score = state.score
            self.savedScoreDate = state.savedScoreDate
            self.completedHabits = state.completedHabits
            self.lastCheckinDate = state.lastCheckinDate
            self.streak = state.streak
            self.lastActivityDate = state.lastActivityDate
            self.milestones = state.milestones
            self.habits = state.habits
            self.templates = state.templates
        } else {
            let def = AppState.defaultState
            self.score = def.score
            self.savedScoreDate = def.savedScoreDate
            self.completedHabits = def.completedHabits
            self.lastCheckinDate = def.lastCheckinDate
            self.streak = def.streak
            self.lastActivityDate = def.lastActivityDate
            self.milestones = def.milestones
            self.habits = def.habits
            self.templates = def.templates
        }
        
        // Daily reset check
        let today = Self.todayStr()
        if lastCheckinDate != nil && lastCheckinDate != today {
            completedHabits = []
            lastCheckinDate = today
        }
        
        // Auto-save on any change
        objectWillChange
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Date Helpers
    
    static func todayStr() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    static func yesterdayStr() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
    }
    
    // MARK: - Streak Logic
    
    private func recordActivityForStreak() {
        let today = Self.todayStr()
        guard lastActivityDate != today else { return }
        
        let yesterday = Self.yesterdayStr()
        if lastActivityDate == yesterday {
            streak += 1
        } else {
            streak = 1
        }
        lastActivityDate = today
    }
    
    // MARK: - Score Actions
    
    var isSavedToday: Bool {
        savedScoreDate == Self.todayStr()
    }
    
    func saveTodayScore() {
        guard !isSavedToday else { return }
        savedScoreDate = Self.todayStr()
        recordActivityForStreak()
    }
    
    // MARK: - Habit Actions
    
    func toggleHabit(_ id: String) {
        let today = Self.todayStr()
        let isNewDay = lastCheckinDate != today
        if isNewDay { completedHabits = [] }
        
        if completedHabits.contains(id) {
            completedHabits.removeAll { $0 == id }
        } else {
            completedHabits.append(id)
            recordActivityForStreak()
        }
        lastCheckinDate = today
    }
    
    var totalPoints: Int {
        completedHabits.reduce(0) { sum, id in
            sum + (habits.first(where: { $0.id == id })?.points ?? 0)
        }
    }
    
    var progressPercentage: Double {
        habits.isEmpty ? 0 : min(Double(completedHabits.count) / Double(habits.count), 1.0)
    }
    
    // MARK: - Milestone CRUD
    
    func addMilestone(title: String, date: String, type: MilestoneType) {
        milestones.append(Milestone(title: title, date: date, type: type))
    }
    
    func updateMilestone(id: String, title: String, date: String, type: MilestoneType) {
        if let i = milestones.firstIndex(where: { $0.id == id }) {
            milestones[i].title = title
            milestones[i].date = date
            milestones[i].type = type
        }
    }
    
    func removeMilestone(id: String) {
        milestones.removeAll { $0.id == id }
    }
    
    // MARK: - Habit CRUD
    
    func addHabit(title: String, points: Int) {
        habits.append(Habit(title: title, points: points))
    }
    
    func updateHabit(id: String, title: String, points: Int) {
        if let i = habits.firstIndex(where: { $0.id == id }) {
            habits[i].title = title
            habits[i].points = points
        }
    }
    
    func removeHabit(id: String) {
        habits.removeAll { $0.id == id }
        completedHabits.removeAll { $0 == id }
    }
    
    // MARK: - Template CRUD
    
    func addTemplate(category: String, title: String, content: String, tags: [String]) {
        templates.append(Template(category: category, title: title, content: content, tags: tags))
    }
    
    func updateTemplate(id: String, category: String, title: String, content: String, tags: [String]) {
        if let i = templates.firstIndex(where: { $0.id == id }) {
            templates[i].category = category
            templates[i].title = title
            templates[i].content = content
            templates[i].tags = tags
        }
    }
    
    func removeTemplate(id: String) {
        templates.removeAll { $0.id == id }
    }
    
    // MARK: - Persistence
    
    private func save() {
        let state = AppState(
            score: score,
            savedScoreDate: savedScoreDate,
            completedHabits: completedHabits,
            lastCheckinDate: lastCheckinDate,
            streak: streak,
            lastActivityDate: lastActivityDate,
            milestones: milestones,
            habits: habits,
            templates: templates
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
