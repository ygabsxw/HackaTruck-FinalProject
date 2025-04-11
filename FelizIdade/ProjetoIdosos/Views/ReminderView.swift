//
//  Reminder.swift
//  ProjetoIdosos
//
//  Created by Turma02-16 on 02/04/25.
//
import SwiftUI
import UserNotifications

extension Date {

    static func today() -> Date {
        return Date()
    }

    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.next,
                   weekday,
                   considerToday: considerToday)
    }

    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous,
                   weekday,
                   considerToday: considerToday)
    }

    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {

        let dayName = weekDay.rawValue

        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

        let calendar = Calendar(identifier: .gregorian)

        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }

        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex

        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)

        return date!
    }

}

// MARK: Helper methods
extension Date {
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }

    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }

    enum SearchDirection {
        case next
        case previous

        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }
}

func scheduleNotification(reminder: Reminders) {
    let content = UNMutableNotificationContent()
    content.title = reminder.title
    content.subtitle = reminder.description
    content.sound = UNNotificationSound.default

    if reminder.isRepeatable {
        for i in 0...6 {
            if reminder.repeatDays[i] {
                let weekday: Date.Weekday
                switch i {
                case 0: weekday = .sunday
                case 1: weekday = .monday
                case 2: weekday = .tuesday
                case 3: weekday = .wednesday
                case 4: weekday = .thursday
                case 5: weekday = .friday
                case 6: weekday = .saturday
                default: continue
                }

                let nextDate = Date.today().next(weekday, considerToday: true)
                let calendar = Calendar.current
                let reminderDate = Date(timeIntervalSince1970: TimeInterval(reminder.datetime))
                var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: reminderDate)
                let nextDateComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)

                dateComponents.year = nextDateComponents.year
                dateComponents.month = nextDateComponents.month
                dateComponents.day = nextDateComponents.day

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger
                )

                UNUserNotificationCenter.current().add(request)
            }
        }
    } else {
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: Date(timeIntervalSince1970: TimeInterval(reminder.datetime))
            ),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: reminder.id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling non-repeating notification: \(error)")
            } else {
                print("Non-repeating notification scheduled for \(trigger) with identifier: \(request.identifier)")
            }
        }
    }
}

struct ReminderView: View {
    @State var add: Bool = false
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    @StateObject var vm = ViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                NavBarView()
                NavigationView {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: ReminderAdd(
                            datetime: Date(),
                            title: "Novo Lembrete",
                            description: "",
                            repeatable: false,
                            hour: Calendar.current.component(.hour, from: Date()),
                            minute: Calendar.current.component(.minute, from: Date()),
                            second: 0,
                            dom: false,
                            seg: false,
                            ter: false,
                            qua: false,
                            qui: false,
                            sex: false,
                            sab: false
                        )) {
                            Text("Adicionar lembrete")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.lightGreen) // Example blue color
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        Text("Últimos Lembretes")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                        Spacer()
                        List {
                            ForEach(vm.reminders) { alarme in
                                HStack(alignment: .center) {
                                    NavigationLink(destination: ReminderAdd(
                                        id: alarme.id,
                                        datetime: Date(timeIntervalSince1970: TimeInterval(alarme.datetime)),
                                        title: alarme.title,
                                        description: alarme.description,
                                        repeatable: alarme.isRepeatable,
                                        hour: Int(Calendar.current.component(
                                            .hour, from: Date(timeIntervalSince1970: TimeInterval(alarme.datetime))
                                        )),
                                        minute: Int(Calendar.current.component(
                                            .minute, from: Date(timeIntervalSince1970: TimeInterval(alarme.datetime))
                                        )),
                                        second: Int(Calendar.current.component(
                                            .second, from: Date(timeIntervalSince1970: TimeInterval(alarme.datetime))
                                        )),
                                        dom: alarme.repeatDays[0],
                                        seg: alarme.repeatDays[1],
                                        ter: alarme.repeatDays[2],
                                        qua: alarme.repeatDays[3],
                                        qui: alarme.repeatDays[4],
                                        sex: alarme.repeatDays[5],
                                        sab: alarme.repeatDays[6]
                                    )) {
                                        VStack(alignment: .leading) {
                                            Text(alarme.title)
                                                .font(.headline)
                                                .padding(.bottom, 1)
                                            Text(timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(alarme.datetime))))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }.frame(height: 60)
                            }
                        }
                        .listStyle(.plain)
                        .navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            Task {
                                vm.fetchReminders()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ReminderView()
}
