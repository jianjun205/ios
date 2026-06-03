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
    @State private var currentTask: URLSessionDataTask? = nil

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
        .id(url) // 极其重要：当URL变化时，强制重建View并清空旧Image状态，防止List单元格重用导致旧图残留
        .onAppear(perform: load)
        .onDisappear(perform: cancel) // 极其重要：当视图滑出屏幕时，自动取消下载任务，防止极速滑动导致的网络请求并发雪崩与限流
    }

    private func load() {
        if image != nil { return }
        let key = url as NSString
        if let cached = RemoteImageCache.shared.object(forKey: key) {
            self.image = cached
            return
        }
        
        // 增进安全：对可能含有特殊字符或中文的URL进行高兼容性百分比转义，防止URL创建失败
        guard let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let imageURL = URL(string: encodedUrlString) else {
            print("⚠️ [RemoteImageView] URL格式非法: \(url)")
            return
        }
        
        // 构建带有标准移动端Safari User-Agent的高透Request，规避CDN等防盗链或防抓取机制拦截，并配置持久本地网络缓存
        var request = URLRequest(url: imageURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.currentTask = nil
                }
            }
            
            if let error = error as NSError?, error.code != NSURLErrorCancelled {
                print("⚠️ [RemoteImageView] 网络图片加载出错: \(url), 错误描述: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("⚠️ [RemoteImageView] 服务器返回非200状态码: (URL: \(url)), 状态码: \(httpResponse.statusCode)")
            }
            
            guard let data = data, let ui = UIImage(data: data) else { return }
            RemoteImageCache.shared.setObject(ui, forKey: key)
            DispatchQueue.main.async {
                self.image = ui
            }
        }
        self.currentTask = task
        task.resume()
    }

    private func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}
