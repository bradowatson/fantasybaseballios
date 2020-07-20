//
//  URLImageView.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/12/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import SwiftUI

struct URLImageView: View {
    @ObservedObject var urlImageModel : URLImageModel
    
    init(urlString: String?) {
        urlImageModel = URLImageModel(urlString: urlString)
    }
    
    var body: some View {
        Image(uiImage: urlImageModel.image ?? URLImageView.defaultImage!)
        .resizable()
        .scaledToFit()
        .frame(width: 45, height: 60)
    }
    
    static var defaultImage = UIImage(named: "playericon")
}

struct URLImageView_Previews: PreviewProvider {
    static var previews: some View {
        URLImageView(urlString: nil)
    }
}
