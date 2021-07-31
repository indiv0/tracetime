//
//  ContentView.swift
//  tracetime
//
//  Created by Nikita Pekin on 2021-07-30.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Record.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.startTime, ascending: false)]
    ) var records: FetchedResults<Record>
    
    var fmt: DateFormatter {
        let tmp = DateFormatter()
        tmp.dateStyle = .short
        return tmp
    }

    @State private var addRecordSheetId = 0
    @State private var transientActivity: String = ""
    @State private var isAddRecordLinkActive: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                let recordsDict = groupByDate(records)
                ForEach(recordsDict.indices, id: \.self) { i in
                    Section(header: Text(self.fmt.string(from: recordsDict[i][0].startTime))) {
                        ForEach(recordsDict[i].indices, id: \.self) { j in
                            HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(recordsDict[i][j].activity)")
                                            .font(.headline)
                                        Text("\(recordsDict[i][j].startTime...recordsDict[i][j].endTime)")
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                    NavigationLink(destination: {
                                        EditRecordSheet(record: recordsDict[i][j], latest: i == 0 && j == 0)
                                    }) {}
                            }
                            .frame(height: 50)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewContext.delete(records[index])
                    }
                    do {
                        try viewContext.save()
                        WidgetCenter.shared.reloadAllTimelines()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Records")
            .navigationBarItems(trailing: NavigationLink(
                destination: AddRecordSheet(transientActivity: transientActivity, previous: records.first).id(addRecordSheetId),
                isActive: $isAddRecordLinkActive
            ) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            })
            .onOpenURL { url in
                guard url.scheme == "tracetime" else { return }
                guard url.host == "create" else { return }
                
                transientActivity = ""
                if let query = url.query {
                    let components = query.split(separator: ",").flatMap { $0.split(separator: "=") }
                    if let activityIndex = components.firstIndex(of: "activity") {
                        if activityIndex + 1 < components.count {
                            transientActivity = String(components[activityIndex + 1]).removingPercentEncoding!
                        }
                    }
                }
                
                isAddRecordLinkActive = true
                // Update the ID so that the `AddRecordSheet` `View` is replace entirely.
                // This is less than ideal in terms of efficiency, but it's necessary to clear
                // the state of the view.
                addRecordSheetId += 1
                print("Create \(transientActivity)")
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    func groupByDate(_ result: FetchedResults<Record>) -> [[Record]] {
        return Dictionary(grouping: result) { (element: Record) in
            fmt.string(from: element.startTime)
        }.values.sorted() { $0[0].startTime > $1[0].startTime }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
