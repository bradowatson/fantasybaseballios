//
//  UserSettings.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/15/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import Foundation

class UserSettings: ObservableObject {
    @Published var apiToken: String?
    @Published var myTeamId: Int?
    @Published var myTeamName: String?
    @Published var loggedIn: Bool = false
}
