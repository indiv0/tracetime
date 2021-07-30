//
//  AddRecordSheet.swift
//  AddRecordSheet
//
//  Created by Nikita Pekin on 2021-07-30.
//

import WidgetKit
import SwiftUI

struct AddRecordSheet: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var activity: String
    @State var startTime: Date
    @State var endTime: Date
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity")) {
                    TextField("Activity Name", text: $activity)
                }
                
                Section(header: Text("Time Period")) {
                    HStack {
                        Text("Start")
                        Spacer()
                        Text(startTime, style: .date)
                        Text(startTime, style: .time)
                    }
                    DatePicker("End", selection: $endTime, in: startTime...Date())
                }
            }
            .navigationBarTitle("Add Record")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Done") {
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
}

struct AddRecordSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordSheet(activity: "", startTime: Date().addingTimeInterval(-600), endTime: Date())
    }
}
