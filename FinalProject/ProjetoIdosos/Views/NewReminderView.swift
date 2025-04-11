import SwiftUI
import UserNotifications

struct ReminderAdd: View {
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        return formatter
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    @State var id: String?
    @State var datetime: Date
    @State var title: String
    @State var description: String
    @State var repeatable: Bool
    @State var hour: Int
    @State var minute: Int
    @State var second: Int

    @State var dom: Bool
    @State var seg: Bool
    @State var ter: Bool
    @State var qua: Bool
    @State var qui: Bool
    @State var sex: Bool
    @State var sab: Bool

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                NavBarView()
                NavigationView {
                    ScrollView {
                        VStack {
                            Text("Que título pode ajudar o entendimento do lembrete?")
                                .font(.headline)
                                .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)))
                                .padding(.top)
                            TextField("Adicionar título", text: $title)
                                .font(.title3) // Larger font for input
                                .padding()
                                .background(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1))) // Light background for better contrast
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .border(Color(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.5)), width: 1) // Subtle border
                            
                            HStack {
                                VStack {
                                    Button("", systemImage: "arrowshape.up.circle.fill") {
                                        hour = (hour + 1) % 24
                                    }.frame(width: 50).font(.title)
                                        .foregroundColor(Color.lightGreen)
                                    Text(String(format: "%02d", hour))
                                        .font(.system(size: 50)).bold()
                                        .frame(width: 65)
                                    Button("", systemImage: "arrowshape.down.circle.fill") {
                                        hour = (hour + (24 - 1)) % 24
                                    }.frame(width: 50).font(.title)
                                        .foregroundColor(Color.lightGreen)
                                }
                                Text(":").font(.system(size: 32))
                                VStack {
                                    Button("", systemImage: "arrowshape.up.circle.fill") {
                                        minute = (minute + 1) % 60
                                    }.frame(width: 50).font(.title)
                                        .foregroundColor(Color.lightGreen)
                                    Text(String(format: "%02d", minute))
                                        .font(.system(size: 50)).bold()
                                        .frame(width: 65)
                                    Button("", systemImage: "arrowshape.down.circle.fill") {
                                        minute = (minute + (60 - 1)) % 60
                                    }.frame(width: 50).font(.title)
                                        .foregroundColor(Color.lightGreen)
                                }
                                Text(":").font(.largeTitle)
                                VStack {
                                    Button("", systemImage: "arrowshape.up.circle.fill") {
                                        second = (second + 1) % 60
                                    }.frame(width: 50).font(.title)
                                        .foregroundColor(Color.lightGreen)
                                    Text(String(format: "%02d", second))
                                        .font(.system(size: 50)).bold()
                                        .frame(width: 65)
                                    Button("", systemImage: "arrowshape.down.circle.fill") {
                                        second = (second + (60 - 1)) % 60
                                    }.frame(width: 50).font(.title)
                                        .foregroundColor(Color.lightGreen)
                                }
                            }
                            .padding(.top, 10)
                            
                            TextEditor(text: $description)
                                .frame(height: 150)
                                .font(.body) // Use body font, will be adjusted for size
                                .padding(8)
                                .background(Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1))) // Light background
                                .cornerRadius(8)
                                .border(Color(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.5)), width: 1)
                                .padding()
                            
                            Toggle("Repetir lembrete", isOn: $repeatable)
                            
                            if repeatable {
                                HStack {
                                    DayButton(day: "D", isSelected: $dom)
                                    DayButton(day: "S", isSelected: $seg)
                                    DayButton(day: "T", isSelected: $ter)
                                    DayButton(day: "Q", isSelected: $qua)
                                    DayButton(day: "Q", isSelected: $qui)
                                    DayButton(day: "S", isSelected: $sex)
                                    DayButton(day: "S", isSelected: $sab)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        if id == nil {
                            Button("Salvar") {
                                let reminder = Reminders(
                                    id: id ?? dateFormatter.string(from: Date()) + " " + timeFormatter.string(from: Date()),
                                    title: title,
                                    description: description,
                                    datetime: Int(Calendar.current.date(from: DateComponents(
                                        year: Calendar.current.component(.year, from: Date()),
                                        month: Calendar.current.component(.month, from: Date()),
                                        day: Calendar.current.component(.day, from: Date()),
                                        hour: hour,
                                        minute: minute,
                                        second: second
                                    ))!.timeIntervalSince1970),
                                    isRepeatable: repeatable,
                                    repeatDays: [dom, seg, ter, qua, qui, sex, sab]
                                )
                                scheduleNotification(reminder: reminder)
                                ViewModel().uploadReminder(reminder: reminder) // Assuming you have this method
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.lightGreen) // Example blue color
                            .cornerRadius(10)
                        }
                    }
                    .listStyle(.plain)
                    .padding()
                    .navigationTitle(id == nil ? "Novo Lembrete" : "Editar Lembrete")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

struct DayButton: View {
    let day: String
    @Binding var isSelected: Bool

    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(day)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.lightGreen : Color.gray.opacity(0.5))
                .foregroundColor(.black)
                .clipShape(Circle())
        }
    }
}


#Preview {
    ReminderAdd(datetime: Date(), title: "Test Reminder", description: "This is a test reminder.", repeatable: false, hour: 9, minute: 0, second: 0, dom: false, seg: false, ter: false, qua: false, qui: false, sex: false, sab: false)
}
