import SwiftUI

struct HabitEditView: View {
    @Binding var habit: Habit
    var onDelete: (() -> Void)? // Optional delete action closure

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
