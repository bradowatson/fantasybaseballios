//
//  TeamView.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/10/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import SwiftUI

struct Team: Codable {
    let teamID: Int
    let teamName: String
    let logoURL: String

    enum CodingKeys: String, CodingKey {
        case teamID = "TeamID"
        case teamName = "TeamName"
        case logoURL = "LogoURL"
    }
}

struct LeagueView: View {
    @State var teams = [Team]()
    @EnvironmentObject var settings: UserSettings
    @State var selectedTeam: Int?
    
    var body: some View {
        return NavigationView {
            List(teams, id: \.teamID) { item in
                
                NavigationLink(destination: TeamView(teamId: item.teamID, teamName: item.teamName, myTeam: false).environmentObject(self.settings)) {
                    URLImageView(urlString: item.logoURL)
                    
                    VStack(alignment: .leading) {
                        Text(item.teamName)
                            .font(.headline)
                    }
                }.navigationBarTitle(Text("League"), displayMode: .inline).font(.headline)
            }.onAppear(perform: loadData)
        }
    }
    
    func getApiToken() -> String {
        return settings.apiToken!
    }
    
    func loadData() {
        guard let url = URL(string: "http://bradwatson.ddns.net:81/fantasybaseballREST/rest/TeamService/teams") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let header: String = "Bearer " + getApiToken()
        request.setValue(header, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(Array<Team>.self, from: data)
                        DispatchQueue.main.async {
                            self.teams = decodedResponse
                        }
                        return
                } catch {
                    print("\(error)")
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct LeagueView_Previews: PreviewProvider {
    static var previews: some View {
        LeagueView()
    }
}
