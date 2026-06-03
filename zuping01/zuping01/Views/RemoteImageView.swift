//
//  RemoteImageView.swift
//  zuping01
//
//  iOS 13 兼容的远程图片加载（替代 AsyncImage）
//

import SwiftUI

private final class RemoteImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct RemoteImageView: View {
    let url: String
    var contentMode: ContentMode = .fill
    var placeholder: AnyView = AnyView(
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "photo")
                .font(.system(size: 30))
                .foregroundColor(Color.blue.opacity(0.5))
        }
    )

    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        if image != nil { return }
        let key = url as NSString
        if let cached = RemoteImageCache.shared.object(forKey: key) {
            self.image = cached
            return
        }
        guard let imageURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            guard let data = data, let ui = UIImage(data: data) else { return }
            RemoteImageCache.shared.setObject(ui, forKey: key)
            DispatchQueue.main.async {
                self.image = ui
            }
        }.resume()
    }
}
