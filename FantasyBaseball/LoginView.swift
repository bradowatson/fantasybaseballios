//
//  LoginView.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/8/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import SwiftUI

struct JSON: Codable {
    let result: Result
}

struct Result: Codable {
    let key: String
    let teamID: Int
    let teamName: String

    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case teamID = "TeamId"
        case teamName = "TeamName"
    }
}

struct User: Encodable {
    let name: String?
    let password: String?
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    let keychain = KeychainSwift()
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ZStack {
            Color(hex: 0x000088)
            VStack(alignment: .center, spacing: 10) {
                
                Image("mlblogo").resizable().frame(width: 224, height: 121, alignment: .center)
                
                UsernameTextField(username: $username)
                PasswordTextField(password: $password)
                
                Button(action: {
                    print("Button Press!")
                    self.postData(user: self.username, password: self.password)
                }) {
                    Text("Login")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(Color.white)
                    .cornerRadius(8)
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text("Failed Login!"), message: Text("Incorrect username or bad password"))
                }
            }
        }
    }
    
    func setFailedLogin() {
        self.showingAlert = true
    }
    
    func setMyTeamId(myTeamId: Int) {
        self.settings.myTeamId = myTeamId
        keychain.set("\(myTeamId)", forKey: "myTeamId")
    }
    
    func setMyTeamName(myTeamName: String) {
        self.settings.myTeamName = myTeamName
        keychain.set(myTeamName, forKey: "myTeamName")
    }
    
    func setApiToken(apiToken: String) {
        self.settings.apiToken = apiToken
        keychain.set(apiToken, forKey: "apiToken")
    }
    
    func setLoggedIn(loggedIn: Bool, myTeamId: Int, apiToken: String, myTeamName: String) {
        self.settings.loggedIn = loggedIn
        keychain.accessGroup = "83GXZHXT6G.Watson.FantasyBaseball"
        self.setMyTeamId(myTeamId: myTeamId)
        self.setApiToken(apiToken: apiToken)
        self.setMyTeamName(myTeamName: myTeamName)
    }
    
    func isLoggedIn() -> Bool {
        if self.settings.loggedIn {
            return true
        }
        return false
    }
    
    func postData(user: String, password: String) {
        guard let url = URL(string: "http://bradwatson.ddns.net:81/fantasybaseballREST/rest/Authentication/login") else {
            print("Invalid URL")
            return
        }
        let user = User.init(name: user, password: password)
        let jsonData = try? JSONEncoder().encode(user)
        var json: JSON?
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(JSON.self, from: data)
                        DispatchQueue.main.async {
                            json = decodedResponse
                            self.setLoggedIn(loggedIn: true, myTeamId: json?.result.teamID ?? 1, apiToken: json?.result.key ?? "", myTeamName: json?.result.teamName ?? "")
                            print("SUCCESSFUL LOGIN")
                        }
                        return
                } catch {
                    print("\(error)")
                    self.setFailedLogin()
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            print(data.debugDescription)
            }.resume()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct UsernameTextField: View {
    @Binding var username: String
    var body: some View {
        return TextField("Username", text: $username)
        .padding()
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct PasswordTextField: View {
    @Binding var password: String
    var body: some View {
        return SecureField("Password", text: $password)
        .padding()
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}
