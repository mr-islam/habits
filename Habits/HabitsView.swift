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
                        .background(NavigationLink("", destination: HabitDetailView(habit: $habit)).opacity(0.0))
                }
                .onMove(perform: move)
            }
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $isPresentingNewHabitView) {
            NavigationView {
                HabitEditView(habit: $newHabit)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                isPresentingNewHabitView = false
                                newHabit = Habit()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                habits.append(newHabit)
                                isPresentingNewHabitView = false
                                newHabit = Habit()
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresentingSettingsView) {
            NavigationView {
                            SettingsView2() // Replace with actual settings view
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingNewHabitView = false
                            }
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination )
    }
}

struct HabitsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HabitsView(habits: .constant(Habit.sampleData), saveAction: {})
        }
    }
}

