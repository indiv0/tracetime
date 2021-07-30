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
    
    enum ActiveSheet: Identifiable {
        case create(activity: String?), edit(record: Record)
        
        var id: Int {
            switch self {
            case .create: return 1
            case .edit: return 2
            }
        }
    }
    
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
    
    @State var activeSheet: ActiveSheet?
    
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
                                    Button(action: {
                                        activeSheet = .edit(record: recordsDict[i][j])
                                    }) {
                                        Image(systemName: "pencil")
                                            .imageScale(.large)
                                            .foregroundColor(.blue)
                                    }
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
            .navigationBarItems(trailing: Button(action: {
                activeSheet = .create(activity: nil)
            }, label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }))
            .onOpenURL { url in
                print(url)
                guard url.scheme == "tracetime" else { return }
                guard url.host == "create" else { return }
                guard let query = url.query else { return }
                let components = query.split(separator: ",").flatMap { $0.split(separator: "=") }
                print(components)
                guard let activityIndex = components.firstIndex(of: "activity") else { return }
                guard activityIndex + 1 < components.count else { return }
                print(String(components[activityIndex + 1]).removingPercentEncoding!)
                activeSheet = .create(activity: String(components[activityIndex + 1]).removingPercentEncoding!)
                print(activeSheet)
            }
            .sheet(item: $activeSheet) { item in
                switch item {
                case .create(let activity):
                    let now = Date();
                    if let record = records.first {
                        AddRecordSheet(
                            activity: activity ?? record.activity,
                            // Every task must start at least one second
                            // after the last task ended to ensure that they
                            // can be sorted correctly.
                            startTime: record.endTime.addingTimeInterval(1),
                            endTime: now > record.endTime ? now : record.endTime
                        )
                    } else {
                        AddRecordSheet(activity: activity ?? "", startTime: now, endTime: now)
                    }
                case .edit(let value):
                    EditRecordSheet(record: value, last: records.first!.id! == value.id!)
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    func groupByDate(_ result: FetchedResults<Record>) -> [[Record]] {
        return Dictionary(grouping: result) { (element: Record) in
            fmt.string(from: element.startTime)
        }.values.sorted() { $0[0].startTime > $1[0].startTime }
    }
    
    //func extendRecord(record: Record) {
    //    let newEndTime = Date()
    //    viewContext.performAndWait {
    //        record.endTime = newEndTime
    //        try? viewContext.save()
    //    }
    //}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
