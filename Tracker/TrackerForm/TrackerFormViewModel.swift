import UIKit

final class TrackerFormViewModel {
    // MARK: - Properties
    
    private let config: TrackerFormConfiguration
    
    var name: String = "" {
        didSet { validateForm() }
    }
    var selectedEmoji: String? {
        didSet { validateForm() }
    }
    var selectedColor: UIColor? {
        didSet { validateForm() }
    }
    var selectedCategory: String? {
        didSet { onCategoryUpdated?(selectedCategory ?? "") ; validateForm() }
    }
    var selectedSchedule: Set<WeekDay> = [] {
        didSet { onScheduleUpdated?(formattedSchedule(selectedSchedule)); validateForm() }
    }
    
    // MARK: - Callbacks
    
    var onFormValidityChanged: ((Bool) -> Void)?
    var onErrorMessageChanged: ((String?) -> Void)?
    var onCategoryUpdated: ((String) -> Void)?
    var onScheduleUpdated: ((String) -> Void)?
    var onFormSubmitted: ((Tracker) -> Void)?
    var onPrefill: ((String, String?, UIColor?, String?, Set<WeekDay>) -> Void)?
    
    // MARK: - Init
    
    init(config: TrackerFormConfiguration) {
        self.config = config
    }
    
    // MARK: - Public Methods
    
    func updateName(_ text: String) {
        name = text.trimmingCharacters(in: .whitespaces)
        
        if name.count > 38 {
            name = String(name.prefix(38))
            onErrorMessageChanged?(NSLocalizedString("onErrorTitle", comment: "Ограничение 38 символов"))
        } else {
            onErrorMessageChanged?(nil)
        }
    }
    
    func selectEmoji(_ emoji: String) {
        selectedEmoji = emoji
    }
    
    func selectColor(_ color: UIColor) {
        selectedColor = color
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    func selectSchedule(_ days: Set<WeekDay>) {
        selectedSchedule = days
    }
    
    func submitForm() {
        guard let emoji = selectedEmoji,
              let color = selectedColor,
              let category = selectedCategory else { return }
        
        let tracker = Tracker(
            id: config.existingTracker?.id ?? UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: config.showSchedule ? selectedSchedule : [],
            category: category,
            type: config.type,
            isPinned: config.existingTracker?.isPinned ?? false
        )
        
        onFormSubmitted?(tracker)
    }
    
    func prefillFields() {
        guard let tracker = config.existingTracker else { return }
        
        name = tracker.name
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        selectedCategory = tracker.category
        selectedSchedule = tracker.schedule
        
        onPrefill?(name, selectedEmoji, selectedColor, selectedCategory, selectedSchedule)
        onCategoryUpdated?(tracker.category)
        onScheduleUpdated?(formattedSchedule(tracker.schedule))
        validateForm()
    }
    
    var title: String {
        config.title
    }
    
    var showSchedule: Bool {
        config.showSchedule
    }
    
    // MARK: - Helpers
    
    private func validateForm() {
        let isValid = !name.isEmpty &&
        selectedEmoji != nil &&
        selectedColor != nil &&
        selectedCategory != nil &&
        (config.showSchedule ? !selectedSchedule.isEmpty : true)
        
        onFormValidityChanged?(isValid)
    }
    
    func formattedSchedule(_ days: Set<WeekDay>) -> String {
        if days.count == 7 {
            return NSLocalizedString("everyDayTitle", comment: "Каждый день")
        } else {
            return days.sorted(by: { $0.rawValue < $1.rawValue })
                .map { $0.shortTitle }
                .joined(separator: ", ")
        }
    }
}
