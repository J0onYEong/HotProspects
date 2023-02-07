//
//  Prospect.swift
//  HotProspects
//
//  Created by 최준영 on 2023/02/02.
//

import Foundation

class Prospect: Identifiable, Codable, Equatable {
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    // It makes is this property modified in Prospects and read from outside. but can't be modified by outside
    fileprivate(set) var isContacted = false
    fileprivate(set) var lastContact: Date?
    
}


@MainActor class Prospects: ObservableObject {
    enum SortMethod {
        case name
        case recent
    }
    
    let key = "SavedData"
    
    @Published private(set) var people: [Prospect]
    
    init() {
        people = []
        let path = getDocumentDirectory().appendingPathComponent("prospects.json")
        do {
            let data = try Data(contentsOf: path)
            people = try JSONDecoder().decode([Prospect].self, from: data)
        } catch let error as NSError{
            switch error.code {
            case 260:
                print("파일이 아직 존재하지 않음")
            default:
                print(error.localizedDescription)
            }
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func remove(_ prospect: Prospect) {
        let index = people.firstIndex { element in
            element == prospect
        }
        people.remove(at: index!)
        save()
    }
    
    func toggle(_ prospect: Prospect) {
        // tell property will change to swiftui, first
        objectWillChange.send()
        prospect.isContacted.toggle()
        prospect.lastContact = prospect.isContacted ? Date.now : nil
        save()
    }
    
    func sort(type: SortMethod) {
        switch type {
        case .name:
            people.sort { lhs, rhs in
                return lhs.name < rhs.name
            }
        case .recent:
            people.sort { lhs, rhs in
                if let lhsDate = lhs.lastContact, let rhsDate = rhs.lastContact {
                    return lhsDate < rhsDate
                }
                fatalError("잘못된 곳에서 최신접촉순 정렬이 발생하였습니다.")
            }
        default:
            return
        }
    }
    
    func save() {
        guard let encodedData = try? JSONEncoder().encode(people) else {
            print("enocoding error")
            return
        }
        
        do {
            let path = getDocumentDirectory().appendingPathComponent("prospects.json")
            try encodedData.write(to: path, options: [.atomic])
        } catch {
            print("error occurs on data saving process")
        }
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
}
