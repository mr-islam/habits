import SwiftUI

struct HabitsView: View {
    @State private var isPresentingNewHabitView = false
    @State private var newHabit = Habit()
    @State private var isPresentingSettingsView = false
    @Binding var habits: [Habit]

    @Environment(\.scenePhase) private var scenePhase
    let saveAction: () -> Void

    var body: some View {
        VStack() {
            HStack {
                Text("Habits")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
                Button(action: {
                    isPresentingSettingsView = true
                }) {
                    Image(systemName: "gearshape").imageScale(.large)
                }
                .padding(.trailing, 8)
                Button(action: {
                    isPresentingNewHabitView = true
                }) {
                    Image(systemName: "plus").imageScale(.large)
                }
                .padding(.trailing)
            }
            List {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Text("")
                            .frame(width: 0.5 * geometry.size.width, alignment: .leading)
                            .font(.subheadline)
                        let dates = Date.past(5, .day)
                        ForEach(dates.indices, id: \.self) { i in
                            if i != 0 {
                                Divider()
                            }
                            VStack {
                                Text(dates[i].weekdayName.prefix(3))
                                    .font(.footnote)
                                Text("\(dates[i].get(.day))")
                                    .font(.caption)
                            }
                            .frame(width: 0.1 * geometry.size.width)
                            .multilineTextAlignment(.center)
                        }
                    }
                    .foregroundColor(.gray)
                }
                
                ForEach($habits) { $habit in
                    HabitSummaryView(habit: $habit)
                        // Pass the deleteHabit function here
                        .background(NavigationLink("", destination: HabitDetailView(habit: $habit, onDeleteHabit: deleteHabit)).opacity(0.0))
                }
                .onMove(perform: move)
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $isPresentingNewHabitView) {
            NavigationView {
                HabitEditView(habit: $newHabit, onDelete: nil)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                isPresentingNewHabitView = false
                                newHabit = Habit() // Reset
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                habits.append(newHabit)
                                isPresentingNewHabitView = false
                                newHabit = Habit() // Reset
                            }
                            .disabled(newHabit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable if name is empty
                        }
                    }
                    .navigationTitle("New Habit")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $isPresentingSettingsView) {
             NavigationView {
                 SettingsView2() // Replace with actual settings view
                     .toolbar {
                         ToolbarItem(placement: .confirmationAction) {
                             Button("Done") {
                                 isPresentingSettingsView = false // Corrected state variable
                             }
                         }
                     }
                     .navigationTitle("Settings") // Add title
                     .navigationBarTitleDisplayMode(.inline)
             }
         }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination )
    }

    // Function to delete a habit using its object (passed down)
    private func deleteHabit(habitToDelete: Habit) {
        habits.removeAll { $0.id == habitToDelete.id }
        // No need to call saveAction here explicitly, rely on scenePhase or call if immediate save is desired
        // saveAction()
    }
}

struct HabitsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabitsView(habits: .constant(Habit.sampleData), saveAction: {})
        }
    }
}
