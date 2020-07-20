//
//  ContentView.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/8/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @EnvironmentObject var settings: UserSettings
 
    var body: some View {
        
        ZStack {
            if isLoggedIn() {
                LoggedInView().environmentObject(settings)
            } else {
                LoginView().environmentObject(settings)
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        let keychain = KeychainSwift()
        keychain.accessGroup = "83GXZHXT6G.Watson.FantasyBaseball"
        if self.settings.loggedIn {
            return true
        } else if let myTeamId = keychain.get("myTeamId") {
            self.settings.loggedIn = true
            self.settings.myTeamId = Int(myTeamId) ?? 1
            self.settings.myTeamName = keychain.get("myTeamName")
            self.settings.apiToken = keychain.get("apiToken")
            return true
        }
        return false
    }
}

struct LoggedInView: View {
   @State private var selection = 0
   @EnvironmentObject var settings: UserSettings
    
    init() {
        //UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor.darkGray
    }

    var body: some View {

        TabView(selection: $selection) {
            TeamView(teamId: getTeamId(), teamName: getTeamName(), myTeam: true).environmentObject(settings)
                .tabItem {
                    Image("myteam")
                    Text("My Team")
            }.tag(0)

            LeagueView().environmentObject(settings)
                .tabItem {
                    Image("league")
                    Text("League")
            }.tag(1)
        }
    }
   
    func getTeamId() -> Int {
        return self.settings.myTeamId!
    }
   
    func getTeamName() -> String {
        return self.settings.myTeamName!
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
