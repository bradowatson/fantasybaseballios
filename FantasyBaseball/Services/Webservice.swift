//
//  Webservice.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/9/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import Foundation

class Webservice {
    
    func getAllPosts(address: String, completion: @escaping ([Post]) -> ()) {
    
        guard let url = URL(string: address) else {
            fatalError("Incorrect URL")
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            let posts = try!
                JSONDecoder().decode([Post].self, from: data!)
            DispatchQueue.main.async {
                completion(posts)
            }
        }.resume()
    }
}
