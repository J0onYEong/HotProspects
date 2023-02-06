//
//  ProspectsView.swift
//  HotProspects
//
//  Created by 최준영 on 2023/02/02.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none
        case contacted
        case uncontacted
    }
    @EnvironmentObject var prospects: Prospects
    
    @State private var isShowingScanner = false
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var filterType: FilterType
    
    
    var title: String {
        switch filterType {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted"
        case .uncontacted:
            return "UnContacted"
        }
    }
    
    var people: [Prospect] {
        switch filterType {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(people) { person in
                    HStack(spacing: 0) {
                        Image(systemName: "person.crop.square")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                        VStack {
                            HStack {
                                Text(person.name)
                                    .font(.body)
                                Spacer()
                            }
                            HStack {
                                Text(person.emailAddress)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.leading, 10)
                    }
                    .frame(height: 30)
                    .swipeActions(edge: .trailing) {
                        if person.isContacted {
                            Button {
                                prospects.toggle(person)
                            } label: {
                                Label("make it uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.red)
                        } else {
                            Button {
                                prospects.toggle(person)
                            } label: {
                                Label("make it contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            addNotification(person)
                        } label: {
                            Label("Remind me", systemImage: "bell")
                        }
                        .tint(.mint)
                    }
                }
            }
                .toolbar {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                    
                    Button("Test") {
                        let ins = Prospect()
                        ins.name = "test name"
                        ins.emailAddress = "test address"
                        prospects.add(ins)
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], completion: codeScannerHandler)
                }
                .navigationTitle(title)
        }
    }
    
    func codeScannerHandler(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let success):
            let strData = success.string.split(separator: "\n")
            let newPerson = Prospect()
            let startIndex = strData.startIndex
            newPerson.name = String(strData.first ?? "")
            newPerson.emailAddress = String(strData[strData.index(startIndex, offsetBy: 1)])
            // Add new person
            prospects.add(newPerson)
        case .failure(let error):
            switch error {
            case .badInput:
                alertTitle = "카메라 오류"
                alertMessage = "카메라를 실행할 수 없습니다."
            case .badOutput:
                alertTitle = "스캔이미지 오류"
                alertMessage = "QR코드가 재대로 인식되지 않습니다."
            case .permissionDenied:
                alertTitle = "권한 없음"
                alertMessage = "카메라 접근 권한을 확인해 주십시오."
            default:
                alertTitle = "오류"
                alertMessage = "예기치 못한 오류가 발생했습니다."
            }
        }
    }
    
    func addNotification(_ prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        let addRequest = {
            let contents = UNMutableNotificationContent()
            contents.title = "접촉 확인"
            contents.body = "\(prospect.name)분과 접촉하셨나요?"
            contents.badge = 1
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let reqeust = UNNotificationRequest(identifier: "contact alarm", content: contents, trigger: trigger)
            
            center.add(reqeust)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print(error?.localizedDescription ?? "error occured")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filterType: .none)
            .environmentObject(Prospects())
    }
}
