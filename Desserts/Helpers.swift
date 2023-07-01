//
//  Helpers.swift
//  Desserts
//
//  Created by Desmond Fitch on 6/30/23.
//

import Foundation
import SwiftUI

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}

struct AsyncImageView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.load(url: url)
    }
}
