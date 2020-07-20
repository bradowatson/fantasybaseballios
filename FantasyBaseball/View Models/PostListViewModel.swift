//
//  PostListViewModel.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/9/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class PostListViewModel: BindableObject {
    
    init() {
        fetchPosts()
    }
    
    var posts = [Post]() {
        didSet {
            didChange.send(self)
        }
    }
    
    private func fetchPosts() {
        Webservice().getAllPosts(address: "") {
            self.posts = $0
        }
    }
    
    let didChange = PassthroughSubject<PostListViewModel,Never>()
}
