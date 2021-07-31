//
//  AddRecordSheet.swift
//  AddRecordSheet
//
//  Created by Nikita Pekin on 2021-07-30.
//

import WidgetKit
import SwiftUI

// TODO: handle time skips
struct AddRecordSheet: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var activity: String
    @State var startTime: Date = Date()
    // The end time of a new task can not be in the future.
    // NOTE: it is critical that this field is initialized after `startDate`.
    @State private var endTime: Date = Date()
    var first: Bool
    
    init(transientActivity: String, previous: Record?) {
        self.first = previous == nil
        
        // If we're explicitly specifying the "activity" field at
        // the start, then we're creating a record from the
        // widget.
        if transientActivity != "" {
            self._activity = State(initialValue: transientActivity)
            print("Custom activity \(self.activity)")
        // If we're not explicitly specifying the "activity"
        // field, then try to default to the previous activity.
        } else if !first {
            self._activity = State(initialValue: previous!.activity)
            print("Template activity \(self.activity)")
        // If this is the first activity, then default to "".
        } else {
            print("First activity")
            self._activity = State(initialValue: "")
            print("First activity \(self.activity)")
        }

        // If there is a previous activity, use its end time as
        // the start time for this task.
        if !first {
            // Every task must start at least one second
            // after the last task ended to ensure that they
            // can be sorted correctly.
            self._startTime = State(initialValue: previous!.endTime.addingTimeInterval(1))
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Activity")) {
                TextField("Activity Name", text: $activity)
            }
            
            Section(header: Text("Time Period")) {
                if first {
                    DatePicker("Start", selection: $startTime, in: ...endTime)
                } else {
                    HStack {
                        Text("Start")
                        Spacer()
                        Text(startTime, style: .date)
                        Text(startTime, style: .time)
                    }
                }
                DatePicker("End", selection: $endTime, in: startTime...endTime)
            }
        }
        .navigationTitle("Add Record")
        .navigationBarItems(trailing: Button("Done") {
            guard self.activity != "" else { return }
            guard self.startTime <= self.endTime else { return }
            let newRecord = Record(context: viewContext)
            newRecord.id = UUID()
            newRecord.activity = self.activity
            newRecord.startTime = self.startTime
            newRecord.endTime = self.endTime
            do {
                try viewContext.save()
                WidgetCenter.shared.reloadAllTimelines()
                print("Record saved.")
                presentationMode.wrappedValue.dismiss()
            } catch {
                print(error.localizedDescription)
            }
        })
    }
}

struct AddRecordSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordSheet(transientActivity: "Foo", previous: nil)
    }
}
