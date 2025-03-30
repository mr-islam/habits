import UserNotifications
import UIKit // For UIApplication.openSettingsURLString

@MainActor // Ensure callbacks affecting UI state run on main actor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager() // Singleton pattern
    private let notificationCenter = UNUserNotificationCenter.current()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        Task { // Check status on initialization
            await checkAuthorizationStatus()
        }
    }

    // Check current authorization status
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // Request authorization from the user
    func requestAuthorization() async -> Bool {
        do {
            // Request alert, sound, and badge permissions
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus() // Update status after request
            print("Notification permission granted: \(granted)")
            return granted
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            await checkAuthorizationStatus() // Update status even on error
            return false
        }
    }

    // Schedule a daily repeating notification for a habit
    func scheduleNotification(for habit: Habit) {
        guard habit.notificationsEnabled, let time = habit.notificationTime else {
            print("Attempted to schedule notification for '\(habit.name)', but notifications are disabled or time is not set.")
            removeNotification(for: habit) // Ensure any old notification is removed
            return
        }

        // 1. Create Content
        let content = UNMutableNotificationContent()
        content.title = "\(habit.name)"
        content.body = "Habit Reminder"
        content.sound = UNNotificationSound.default

        // 2. Create Trigger (Daily at specific time)
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // 3. Create Request (Use habit ID for uniqueness)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)

        // 4. Add Request to Notification Center
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(habit.name) (\(habit.id)): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for \(habit.name) at \(dateComponents.hour ?? 0):\(String(format: "%02d", dateComponents.minute ?? 0))")
                Task { await self.printPendingNotifications() } // Optional: Log pending notifs
            }
        }
    }

    // Remove a pending notification for a specific habit
    func removeNotification(for habit: Habit) {
        let identifier = habit.id.uuidString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Removed pending notification request for identifier: \(identifier)")
        Task { await self.printPendingNotifications() } // Optional: Log pending notifs
    }

    // Helper to open app's notification settings
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            print("Cannot open settings URL")
            return
        }
        UIApplication.shared.open(settingsUrl)
    }

    // Optional: Debug helper to print currently scheduled notifications
    func printPendingNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        if requests.isEmpty {
             print("[Notifications] No pending requests.")
        } else {
            print("[Notifications] Pending requests (\(requests.count)):")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger, let nextDate = trigger.nextTriggerDate() {
                     let formatter = DateFormatter()
                     formatter.dateStyle = .short
                     formatter.timeStyle = .long
                     print("- ID: \(request.identifier), Body: \(request.content.body), Next Trigger: \(formatter.string(from: nextDate))")
                } else {
                     print("- ID: \(request.identifier), Body: \(request.content.body), Trigger: (Non-Calendar or Expired?)")
                }
            }
        }
    }
}
