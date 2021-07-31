//
//  EditRecordSheet.swift
//  EditRecordSheet
//
//  Created by Nikita Pekin on 2021-07-30.
//

import SwiftUI
import WidgetKit

struct EditRecordSheet: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var record: Record
    @State var activity: String
    @State var endTime: Date
    var latest: Bool
    
    init(record: Record, latest: Bool) {
        self.record = record
        self.latest = latest
        self._activity = State(initialValue: record.activity)
        self._endTime = State(initialValue: record.endTime)
    }
    
    var body: some View {
        //NavigationView {
            Form {
                Section(header: Text("Activity")) {
                    TextField("Activity Name", text: $activity)
                }
                Section(header: Text("Time Period")) {
                    HStack {
                        Text("Start")
                        Spacer()
                        Text(record.startTime, style: .date)
                        Text(record.startTime, style: .time)
                    }
                    if latest {
                        DatePicker("End", selection: $endTime, in: endTime...Date())
                    } else {
                        HStack {
                            Text("End")
                            Spacer()
                            Text(record.endTime, style: .date)
                            Text(record.endTime, style: .time)
                        }
                    }
                }
            }
            .navigationTitle("Edit Record")
            .navigationBarItems(trailing: Button("Save") {
                record.activity = activity;
                if latest {
                    record.endTime = endTime;
                }
                viewContext.performAndWait {
                    try? viewContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                    print("Record edited.")
                }
                presentationMode.wrappedValue.dismiss()
            })
        //}
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EditRecordSheet_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    static var previews: some View {
        let record = Record(context: viewContext)
        record.id = UUID()
        record.activity = "Rave"
        record.endTime = Date()
        record.startTime = record.endTime.addingTimeInterval(-600)
        return EditRecordSheet(record: record, latest: true)
    }
}

// https://stackoverflow.com/a/61002589
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
