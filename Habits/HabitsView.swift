import SwiftUI

struct HabitsView: View {
    @State private var isPresentingNewHabitView = false
    @State private var newHabit = Habit()
    @State private var isPresentingSettingsView = false
    @Binding var habits: [Habit]

    @Environment(\.scenePhase) private var scenePhase
    let saveAction: () -> Void
    
    @AppStorage(Constants.Settings.datesAppearReversedKey) private var datesAppearReversed: Bool = false

    // Proportions
        private let nameColumnProportion: CGFloat = 0.5
        private let dateColumnProportion: CGFloat = 0.1
        private let dateColumnCount: Int = 5
        private let horizontalListPadding: CGFloat = 18

        var body: some View {
            VStack(spacing: 0) {
                // --- Top Header (Title, Buttons) ---
                HStack {
                    Text("Habits").font(.title).fontWeight(.bold)
                    Spacer()
                    Button(action: { isPresentingSettingsView = true }) { Image(systemName: "gearshape").imageScale(.large) }
                    Button(action: { isPresentingNewHabitView = true }) { Image(systemName: "plus").imageScale(.large) }
                }
                .padding(.horizontal, horizontalListPadding) // Apply consistent horizontal padding
                .padding(.bottom, 5)

                // --- List Area ---
                List {
                    // --- Section for the Date Header ---
                    Section {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Color.clear // Use Clear Color to take up space reliably
                                    .frame(width: geometry.size.width * nameColumnProportion)

                                // Date Columns
                                let baseDates = Date.past(dateColumnCount, .day)
                                let displayDates = datesAppearReversed ? baseDates.reversed() : baseDates

                                ForEach(displayDates.indices, id: \.self) { i in
                                    if i != 0 { Divider().frame(maxHeight: 25).padding(.vertical, 4) } // Slightly shorter divider
                                    VStack {
                                        Text(displayDates[i].weekdayName.prefix(3)).font(.footnote)
                                        Text("\(displayDates[i].get(.day))").font(.caption)
                                    }
                                    .frame(width: geometry.size.width * dateColumnProportion) // Use proportion
                                    .multilineTextAlignment(.center)
                                }
                            }
                            .foregroundColor(.gray)
                            .frame(height: geometry.size.height)
                        }
                        .frame(height: 35)
                        .padding(.horizontal, horizontalListPadding) // <<< Apply padding HERE
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 5)


                    }

                    // --- Section for Habits ---
                    Section {
                        ForEach($habits) { $habit in
                             HabitSummaryView(habit: $habit, datesAppearReversed: datesAppearReversed)
                                 .padding(.horizontal, horizontalListPadding) 
                                 .background(
                                     NavigationLink("", destination: HabitDetailView(habit: $habit, onDeleteHabit: deleteHabit))
                                         .opacity(0.0) // Keep NavLink hidden
                                 )
                                 .listRowInsets(EdgeInsets()) // <<< Remove default list insets
                        }
                        .onMove(perform: move)
                    } // End Section for Habits
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
                 SettingsView2()
                     .toolbar {
                         ToolbarItem(placement: .confirmationAction) {
                             Button("Done") {
                                 isPresentingSettingsView = false 
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
