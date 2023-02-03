//
//  ContentView.swift
//  HotProspects
//
//  Created by 최준영 on 2023/01/29.
//

import SwiftUI

struct ContentView: View {
    @StateObject var prospects = Prospects()

    var body: some View {
        TabView {
            ProspectsView(filterType: .none)
                .tabItem {
                    Label("Everyone", systemImage: "person.3")
                }
            ProspectsView(filterType: .contacted)
                .tabItem {
                    Label("contacted", systemImage: "checkmark.circle")
                }
            ProspectsView(filterType: .uncontacted)
                .tabItem {
                    Label("uncontacted", systemImage: "questionmark.diamond")
                }
            UserInformationView()
                .tabItem {
                    Label("user information", systemImage: "person.crop.square")
                }
        }
        .environmentObject(prospects)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
