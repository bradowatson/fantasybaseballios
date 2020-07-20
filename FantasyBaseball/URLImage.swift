//
//  URLImage.swift
//  FantasyBaseball
//
//  Created by Bradley Watson on 7/11/20.
//  Copyright © 2020 Bradley Watson. All rights reserved.
//

import SwiftUI

struct URLImage: View {

    @ObservedObject private var imageLoader: DataLoader

    public init(imageURL: URL?) {
        imageLoader = DataLoader(resourseURL: imageURL)
    }

    public var body: some View {
        if let uiImage = UIImage(data: self.imageLoader.data) {
            return AnyView(Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: ContentMode.fit))
        } else {
            return AnyView(Image(systemName: "ellipsis")
                            .onAppear(perform: { self.imageLoader.loadImage() }))
        }
    }
}
