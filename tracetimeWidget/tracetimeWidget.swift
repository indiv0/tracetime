//
//  tracetimeWidget.swift
//  tracetimeWidget
//
//  Created by Nikita Pekin on 2021-07-30.
//

import CoreData
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    var viewContext: NSManagedObjectContext
    var record: Record?
    var activities: [String]
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        print("Starting Provider with viewContext \(viewContext)")
        let records = Provider.loadData(viewContext: viewContext)
        self.activities = records.map { $0.activity }.unique
        print(records)
        self.record = records.first
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(record: record, date: Date(), activities: activities)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(record: record, date: Date(), activities: activities)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let records = Provider.loadData(viewContext: viewContext)
        let record = records.first
        let activities = records.map { $0.activity }.unique
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(record: record, date: entryDate, activities: activities)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    static func loadData(viewContext: NSManagedObjectContext) -> [Record] {
        let request = NSFetchRequest<Record>(entityName: "Record")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Record.startTime, ascending: false)]
        do {
            let result = try viewContext.fetch(request)
            return result
        } catch let error as NSError {
            print("Could not fetch. \(error.userInfo)")
        }
        return []
    }
}

struct SimpleEntry: TimelineEntry {
    let record: Record?
    let date: Date
    let activities: [String]
}

struct SmallTracetimeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("TRACK AGAIN")
                .font(.body)
                .fontWeight(.heavy)
                .frame(maxHeight: .infinity)
            Divider()
            Text(entry.record!.endTime, style: .timer)
                .frame(maxHeight: .infinity)
        }
        .multilineTextAlignment(.center)
        .padding(8)
        .widgetURL(createActivityUrl(activity: entry.record == nil ? nil : entry.record!.activity))
    }
}

struct tracetimeWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        switch self.widgetFamily {
        case .systemSmall:
            SmallTracetimeWidgetEntryView(entry: entry)
        default:
            let targetCount: Int = {
                switch self.widgetFamily {
                case .systemMedium: return 4
                case .systemSmall: return 4
                default: return 8
                }
            }();
            // https://forums.swift.org/t/padding-arrays/41041/2
            let paddedActivities = entry.activities + Array(repeating: "", count: max(targetCount - entry.activities.count, 0))
            VStack {
                HStack {
                    Text("TRACK AGAIN")
                        .font(.body)
                        .fontWeight(.heavy)
                        .fixedSize()
                    if widgetFamily != .systemSmall {
                        Spacer()
                            .frame(maxWidth: .infinity)
                        Text(entry.record!.endTime, style: .timer)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(8)
                .frame(height: 50)
                VStack {
                    ForEach(Array(stride(from: 0, to: targetCount, by: 2)), id: \.self) { i in
                        Divider()
                        HStack {
                            Link(destination: createActivityUrl(activity: paddedActivities[i])) {
                                Text(paddedActivities[i])
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            Divider()
                            Link(destination: createActivityUrl(activity: paddedActivities[i + 1])) {
                                Text(paddedActivities[i + 1])
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .padding(8)
        }
    }
}

func createActivityUrl(activity: String?) -> URL {
    var components = URLComponents()
    components.scheme = "tracetime"
    components.host = "create"
    if activity != nil {
        components.queryItems = [
            URLQueryItem(name: "activity", value: activity)
        ]
    }
    print(components.url)
    return components.url!
}

@main
struct tracetimeWidget: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "com.frecency.tracetime.tracetimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(viewContext: persistenceController.container.viewContext)) { entry in
            tracetimeWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .configurationDisplayName("tracetime Detail")
        .description("Track time with tracetime.")
    }
}

struct tracetimeWidget_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.preview
    
    static var previews: some View {
        Group {
            let records = Provider.loadData(viewContext: persistenceController.container.viewContext)
            let activities = records.map { $0.activity }.unique
            let record = records.first
            
            tracetimeWidgetEntryView(entry: SimpleEntry(record: record, date: Date(), activities: activities))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            tracetimeWidgetEntryView(entry: SimpleEntry(record: record, date: Date(), activities: activities))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            tracetimeWidgetEntryView(entry: SimpleEntry(record: record, date: Date(), activities: activities))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            tracetimeWidgetEntryView(entry: SimpleEntry(record: nil, date: Date(), activities: []))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            tracetimeWidgetEntryView(entry: SimpleEntry(record: nil, date: Date(), activities: []))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            tracetimeWidgetEntryView(entry: SimpleEntry(record: nil, date: Date(), activities: []))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

// https://stackoverflow.com/a/27624476
extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
