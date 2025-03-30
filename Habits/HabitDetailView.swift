import SwiftUI

struct HabitDetailView: View {
    @State private var isPresentingEditView = false
    @Binding var habit: Habit
    @Environment(\.dismiss) var dismiss

    var onDeleteHabit: (Habit) -> Void

    var body: some View {
        List {
            Section(header: Text("Overview")) {
                HStack {
                    Label("Score", systemImage: "gamecontroller")
                    Spacer()
                    Text("\(habit.computeScore(), specifier: "%.1f")%")
                }
                .foregroundColor(habit.uiColor)

                HStack {
                    Label("Month", systemImage: "goforward.30")
                    Spacer()
                    Text("\(habit.entryCount(.month))")
                }
                .foregroundColor(habit.uiColor)

                HStack {
                    Label("Year", systemImage: "calendar")
                    Spacer()
                    Text("\(habit.entryCount(.year))")
                }
                .foregroundColor(habit.uiColor)

                HStack {
                    Label("Total", systemImage: "a.circle")
                    Spacer()
                    Text("\(habit.entryCount(nil))")
                }
                .foregroundColor(habit.uiColor)
            }
            Section(header: Text("Score")) {
                ScoreChartView(habit: habit)
                    .frame(minHeight: 200)
                    .foregroundColor(habit.uiColor) // Color should be handled within ScoreChartView ideally
            }
            Section(header: Text("History")) {
                HistoryChartView(habit: habit)
                    .frame(minHeight: 250)
                    .foregroundColor(habit.uiColor) // Color should be handled within HistoryChartView ideally
            }
            Section(header: Text("Calendar")) {
                Text("Calendar Placeholder")
            }
        }
        .navigationTitle(habit.name)
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                // Create a temporary binding for the edit view
                // to allow cancellation without modifying the original 'habit' immediately
                HabitEditView(habit: $habit,
                              onDelete: {
                                  onDeleteHabit(habit)
                                  isPresentingEditView = false
                                  dismiss()
                              })
                    .navigationTitle("Edit Habit")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                                // No need to revert changes if using binding directly
                                // and only saving on "Done"
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                // Changes are already in 'habit' via binding
                                // No need for habit.update(from: updateHabit)
                            }
                            .disabled(habit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable if name is empty
                        }
                    }
            }
        }
    }
}

struct HabitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // Provide a dummy delete function for the preview
            HabitDetailView(habit: .constant(Habit.sampleData[0]), onDeleteHabit: { _ in print("Delete triggered in preview") })
        }
    }
}
