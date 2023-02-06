//
//  Prospect.swift
//  HotProspects
//
//  Created by 최준영 on 2023/02/02.
//

import Foundation

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    // It makes is this property modified in Prospects and read from outside. but can't be modified by outside
    fileprivate(set) var isContacted = false
}


@MainActor class Prospects: ObservableObject {
    let key = "SavedData"
    
    @Published private(set) var people: [Prospect]
    
    init() {
        if let loadedData = UserDefaults.standard.data(forKey: key) {
            if let decodedData = try? JSONDecoder().decode([Prospect].self, from: loadedData) {
                self.people = decodedData
                return
            }
            print("data encoding error")
            self.people = []
            return
        }
        print("data loading error")
        self.people = []
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func toggle(_ prospect: Prospect) {
        prospect.isContacted.toggle()
        save()
        objectWillChange.send()
    }
    
    func save() {
        guard let encodedData = try? JSONEncoder().encode(people) else {
            print("enocoding error")
            return
        }
        UserDefaults.standard.setValue(encodedData, forKey: key)
    }
}
