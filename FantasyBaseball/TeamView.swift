//
//  TeamView.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/10/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import SwiftUI

struct Contract: Codable {
    let playerID: Int
    let name, team, position: String
    let espnPrice: Int
    let headshotURL: String
    let number, teamID, price2014, price2015: Int
    let price2016, price2017, price2018, price2019: Int
    let price2020, price2021, price2022, price2023: Int
    let price2024, price2025: Int
    let currentlyRostered, franchise: CurrentlyRostered
    let additionType: AdditionType
    let length, startYear, extensionLength, extensionStartYear: Int

    enum CodingKeys: String, CodingKey {
        case playerID = "PlayerID"
        case name = "Name"
        case team = "Team"
        case position = "Position"
        case espnPrice = "ESPNPrice"
        case headshotURL = "HeadshotURL"
        case number = "Number"
        case teamID = "TeamID"
        case price2014 = "Price2014"
        case price2015 = "Price2015"
        case price2016 = "Price2016"
        case price2017 = "Price2017"
        case price2018 = "Price2018"
        case price2019 = "Price2019"
        case price2020 = "Price2020"
        case price2021 = "Price2021"
        case price2022 = "Price2022"
        case price2023 = "Price2023"
        case price2024 = "Price2024"
        case price2025 = "Price2025"
        case currentlyRostered = "CurrentlyRostered"
        case franchise = "Franchise"
        case additionType = "AdditionType"
        case length = "Length"
        case startYear = "StartYear"
        case extensionLength = "ExtensionLength"
        case extensionStartYear = "ExtensionStartYear"
    }
}

enum AdditionType: String, Codable {
    case c = "C"
    case f = "F"
    case n = "N"
}

enum CurrentlyRostered: String, Codable {
    case n = "N"
    case y = "Y"
}

struct TeamView: View {
    @State var contracts = [Contract]()
    @EnvironmentObject var settings: UserSettings
    let teamId: Int
    let teamName: String
    let myTeam: Bool
    
    var body: some View {
        
        return NavigationView {
            
            
            List(getSortedContracts(), id: \.playerID) { item in
                URLImageView(urlString: item.headshotURL)
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    self.resultText(contract: item)
                    Spacer()
                }
            }.navigationBarTitle(Text(teamName), displayMode: .inline).font(.headline)
            .onAppear(perform: loadData)
        }
    }
    
    func getSortedContracts() -> [Contract] {
        let sortedContracts = contracts.sorted {
            if $0.price2021 > $1.price2021 {
                return $0.price2021 > $1.price2021
            } else {
                return $0.price2020 > $1.price2020
            }
        }
        return sortedContracts
    }
    
    func resultText(contract: Contract) -> Text {
        let expYear = getExpYear(contract: contract)
        let price = getPrice(contract: contract)
        let length = getLength(contract: contract)
        let text: String = "$" + "\(price) " + "\(length)" + ". Expires: " + "\(expYear)"
        if isInactive(contract: contract) {
            return Text(text).foregroundColor(Color.red)
        }
        return Text(text)
    }
    
    func isInactive(contract: Contract) -> Bool {
        if contract.currentlyRostered.rawValue.uppercased().contains("N") {
            return true
        }
        return false
    }
    
    func getExpYear(contract: Contract) -> Int {
        let date = Date()
        let year = Calendar.current.component(.year, from: date)
        if contract.extensionStartYear != 0 {
            return contract.extensionStartYear + contract.extensionLength - 1
        }
        return year
    }
    
    func getLength(contract: Contract) -> String {
        if contract.extensionLength == 0 {
            return "1 yr"
        }
        return "\(contract.extensionLength)" + " yrs"
    }
    
    func getPrice(contract: Contract) -> Int {
        if contract.price2021 > 0 {
            return contract.price2021
        }
        return contract.price2020
    }
    
    func getApiToken() -> String {
        return settings.apiToken!
    }
    
    func loadData() {
        guard let url = URL(string: "http://bradwatson.ddns.net:81/fantasybaseballREST/rest/ContractService/contracts/team/" + "\(self.teamId)") else {
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
                    let decodedResponse = try JSONDecoder().decode(Array<Contract>.self, from: data)
                        DispatchQueue.main.async {
                            self.contracts = decodedResponse
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
