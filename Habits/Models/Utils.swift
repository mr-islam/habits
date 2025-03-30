import Foundation
import UIKit // Import UIKit for UINotificationFeedbackGenerator

extension Date {

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        if component == .quarter {
            switch calendar.component(.month, from: self) {
            case 1,2,3: return 1
            case 4,5,6: return 2
            case 7,8,9: return 3
            default: return 4 // 10,11,12
            }
        }
        return calendar.component(component, from: self)
    }

    var weekdayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }

    var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        return dateFormatter.string(from: self)
    }

    var startOfQuarter: Date {
         let startOfMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month],
            from: Calendar.current.startOfDay(for: self))
         )!

         var components = Calendar.current.dateComponents([.month, .day, .year], from: startOfMonth)

         switch components.month! {
         case 1,2,3: components.month = 1
         case 4,5,6: components.month = 4
         case 7,8,9: components.month = 7
         default: components.month = 10 // 10,11,12
         }
         return Calendar.current.date(from: components)!
     }

    static func past(_ count: Int, _ component: Calendar.Component) -> [Date] {
        let today = Date()
        return (0..<count).compactMap { index in // Use compactMap to automatically handle/discard nil results
            if component == .quarter {
                 // Optional chaining for startOfQuarter calculation
                return Calendar.current.date(byAdding: .month, value: -index * 3, to: today)?.startOfQuarter
            } else {
                return Calendar.current.date(byAdding: component, value: -index, to: today)
            }
        }
    }

    var withoutTime: Date {
        return Calendar.current.startOfDay(for: self)
    }

}

struct Constants {
    struct Settings {
        static let datesAppearReversedKey = "datesAppearReversed" // Key for UserDefaults
    }
}

struct HapticFeedback {
    /**
     Plays a light impact haptic feedback. Best for selection changes or confirming minor actions.
     */
    static func playLightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare() // Prepare the engine (optional but good practice)
        generator.impactOccurred()
    }

    /**
     Plays a success haptic feedback. Use for confirming successful completion of a task.
     */
    static func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

     /**
      Plays a soft impact haptic feedback. Softer than .light.
      */
     static func playSoftImpact() {
         let generator = UIImpactFeedbackGenerator(style: .soft)
         generator.prepare()
         generator.impactOccurred()
     }

    // Add other feedback types like .medium, .heavy, .error, .warning as needed
}
