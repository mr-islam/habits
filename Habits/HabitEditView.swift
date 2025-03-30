import SwiftUI
import UserNotifications

struct HabitEditView: View {
    @Binding var habit: Habit
    var onDelete: (() -> Void)? // Optional delete action closure
    
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var selectedTime: Date = Date() // Temporary holder for DatePicker
    
    @State private var showingDeleteConfirmation = false
    
    // Computed binding for ColorPicker
    private var colorBinding: Binding<Color> {
        Binding {
            habit.uiColor
        } set: { newColor in
            habit.color = Habit.CodableColor(color: newColor)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Habit Details")) {
                TextField("Name", text: $habit.name)
                ColorPicker("Color", selection: colorBinding, supportsOpacity: false)
            }
            
            // --- Notification Section ---
            Section(header: Text("Reminders")) {
                Toggle("Daily Reminder", isOn: $habit.notificationsEnabled)
                    .onChange(of: habit.notificationsEnabled) { enabled in
                        handleNotificationToggle(enabled: enabled)
                    }
                
                if habit.notificationsEnabled {
                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .onChange(of: selectedTime) { newTime in
                            habit.notificationTime = newTime // Update the binding source
                            // Re-schedule notification with the new time if already enabled
                            if habit.notificationsEnabled {
                                notificationManager.scheduleNotification(for: habit)
                            }
                        }
                    // Optional: Add explanatory text if permissions are denied
                    if notificationManager.authorizationStatus == .denied {
                        Text("Notifications are disabled for this app. You can enable them in Settings.")
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Open Settings") {
                            notificationManager.openAppSettings()
                        }
                        .font(.caption)
                    }
                }
            }
            // --- End Notification Section ---
            
            // Section for Delete Button (only shown if onDelete is provided)
            if let onDelete = onDelete {
                Section {
                    Button("Delete Habit", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this habit? This action cannot be undone.",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            Button("Cancel", role: .cancel) { }
        }
        // --- Alert for Notification Permissions ---
        .alert("Notification Permissions", isPresented: $showingPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                notificationManager.openAppSettings()
            }
        } message: {
            Text(permissionAlertMessage)
        }
        // --- End Alert ---
        .onAppear {
            // Initialize selectedTime when view appears if notifications are enabled
            if habit.notificationsEnabled, let time = habit.notificationTime {
                selectedTime = time
            } else {
                // Set a default time if enabling for the first time or time is nil
                selectedTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            }
            // Check status silently on appear
            Task {
                await notificationManager.checkAuthorizationStatus()
            }
        }
    }
    // --- Helper function to handle toggle logic ---
    private func handleNotificationToggle(enabled: Bool) {
        Task {
            if enabled {
                // Turning ON notifications
                await notificationManager.checkAuthorizationStatus() // Refresh status just in case
                let currentStatus = notificationManager.authorizationStatus
                
                if currentStatus == .authorized {
                    // Permission already granted, ensure time is set and schedule
                    if habit.notificationTime == nil {
                        habit.notificationTime = selectedTime // Use default/current picker time
                    }
                    notificationManager.scheduleNotification(for: habit)
                } else if currentStatus == .notDetermined {
                    // Request permission
                    let granted = await notificationManager.requestAuthorization()
                    if granted {
                        // Permission granted, ensure time is set and schedule
                        if habit.notificationTime == nil {
                            habit.notificationTime = selectedTime
                        }
                        notificationManager.scheduleNotification(for: habit)
                    } else {
                        // Permission denied by user during request
                        permissionAlertMessage = "To enable reminders, please allow notifications for this app in Settings."
                        showingPermissionAlert = true
                        habit.notificationsEnabled = false // <<< Revert toggle state
                    }
                } else { // Status is .denied, .restricted, or .provisional
                    // Permission was previously denied or restricted
                    permissionAlertMessage = "Notification permissions were previously denied or are restricted. Please check the app settings."
                    showingPermissionAlert = true
                    habit.notificationsEnabled = false // <<< Revert toggle state
                }
            } else {
                // Turning OFF notifications
                notificationManager.removeNotification(for: habit)
                // Optionally clear the stored time
                // habit.notificationTime = nil
            }
        }
    }
}

struct HabitEditView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for editing (with delete)
        NavigationView {
            HabitEditView(habit: .constant(Habit.sampleData[0]), onDelete: { print("Delete tapped in preview") })
                .navigationTitle("Preview Edit")
                .navigationBarTitleDisplayMode(.inline)
        }
        .previewDisplayName("Editing Habit")
        
        
        // Preview for creating (no delete)
        NavigationView {
            HabitEditView(habit: .constant(Habit()), onDelete: nil)
                .navigationTitle("Preview New")
                .navigationBarTitleDisplayMode(.inline)
        }
        .previewDisplayName("New Habit")
        
    }
    
}
