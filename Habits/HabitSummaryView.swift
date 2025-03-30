// HabitSummaryView.swift
import SwiftUI

struct HabitSummaryView: View {
    private static let positiveIcon = "checkmark"
    private static let negativeIcon = "multiply"

    @Binding var habit: Habit
    let datesAppearReversed: Bool

    private let nameColumnProportion: CGFloat = 0.5
        private let dateColumnProportion: CGFloat = 0.1
        private let dateColumnCount: Int = 5
        private let iconMaxHeight: CGFloat = 14 // resize icons with this

        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {

                    // --- Name Column ---
                    Text(habit.name)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: geometry.size.width * nameColumnProportion, alignment: .leading)

                    // --- Date Icons Columns ---
                    let baseDates = Date.past(dateColumnCount, .day)
                    let displayDates = datesAppearReversed ? baseDates.reversed() : baseDates

                    ForEach(displayDates, id: \.self) { date in
                        Image(systemName: getIconForDate(date))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width * dateColumnProportion,
                                   maxHeight: iconMaxHeight)
                            .frame(width: geometry.size.width * dateColumnProportion)
                            .onTapGesture { toggleEntry(for: date) }
                            .accessibilityLabel(getAccessibilityLabel(for: date))
                    }
                }
                .frame(height: geometry.size.height)

            }
            .frame(height: 44) // Standard interactive row height
            .foregroundColor(habit.uiColor)
            .font(.body)
        }

    private func getIconForDate(_ date: Date) -> String {
        habit.checkEntry(date: date) ? HabitSummaryView.positiveIcon : HabitSummaryView.negativeIcon
    }

    private func toggleEntry(for date: Date) {
        if habit.checkEntry(date: date) {
            habit.deleteEntry(date: date)
        } else {
            habit.addEntry(date: date)
        }
    }

    private func getAccessibilityLabel(for date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateStyle = .medium
         formatter.timeStyle = .none
         let dateString = formatter.string(from: date)
        let status = habit.checkEntry(date: date) ? "completed" : "not completed"
        return "\(habit.name) \(status) on \(dateString)"
    }
}

struct HabitSummaryView_Previews: PreviewProvider {
     static var previews: some View {
         List {
            // Header Simulation (Optional but helpful, broken now)
            HStack(spacing: 0) {
                 Text("Habit Name")
                    .frame(width: 200 * 0.5, alignment: .leading) // Use fixed width for preview proportions
                 ForEach(0..<5) { i in
                    if i != 0 { Divider().frame(height: 20) }
                     VStack { Text("WED"); Text("1\(i)") }
                         .frame(width: 200 * 0.1) // Use fixed width for preview proportions
                 }
             }
             .frame(width: 200)
             .foregroundColor(.gray)
             .font(.caption)


             HabitSummaryView(habit: .constant(Habit.sampleData[0]), datesAppearReversed: false)
                 .listRowInsets(EdgeInsets())
             HabitSummaryView(habit: .constant(Habit.sampleData[1]), datesAppearReversed: true)
                 .listRowInsets(EdgeInsets())
         }
         .listStyle(.plain)
//          .previewLayout(.fixed(width: 400, height: 200)) // Adjust layout size

     }
}
