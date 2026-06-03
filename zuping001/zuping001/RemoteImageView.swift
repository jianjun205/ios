//
//  RemoteImageView.swift
//  zuping01
//
//  iOS 13 兼容的超级双通道缓存+高容错远程图片加载器
//

import SwiftUI

private final class RemoteImageCache {
    static let shared = RemoteImageCache()
    private let memCache = NSCache<NSString, UIImage>()
    
    private init() {
        memCache.countLimit = 150 // 限制内存中缓存150张，防止内存溢出
    }
    
    private var cacheDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RemoteImageCache")
    }
    
    func get(_ urlString: String) -> UIImage? {
        let key = urlString as NSString
        // 1. 优先从高速系统内存中获取
        if let cached = memCache.object(forKey: key) {
            return cached
        }
        
        // 2. 内存缺失时，尝试从App沙盒持久化物理缓存(Disk Cache)中拉取，保障离线与二次加载毫秒级瞬开
        let fileURL = diskCacheURL(for: urlString)
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            memCache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
    
    func set(_ image: UIImage, data: Data, for urlString: String) {
        let key = urlString as NSString
        memCache.setObject(image, forKey: key)
        
        // 异步存盘，避免卡顿主线程
        DispatchQueue.global(qos: .background).async {
            let dir = self.cacheDirectory
            if !FileManager.default.fileExists(atPath: dir.path) {
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }
            let fileURL = self.diskCacheURL(for: urlString)
            try? data.write(to: fileURL)
        }
    }
    
    private func diskCacheURL(for urlString: String) -> URL {
        // 使用安全且唯一的Base64做不冲突磁盘缓存文件名
        let safeName: String
        if let data = urlString.data(using: .utf8) {
            safeName = data.base64EncodedString()
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "=", with: "")
        } else {
            safeName = String(urlString.hashValue)
        }
        return cacheDirectory.appendingPathComponent(safeName)
    }
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
    @State private var retryCount: Int = 0 // 失败重试次数，最多2次

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

    /// 解析并自动优化可能遭遇网络屏障的URL
    private func getOptimizedURL(_ urlStr: String, useFallback: Bool = false) -> String {
        let trimmed = urlStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 针对raw.githubusercontent.com加载极其缓慢甚至被墙的问题进行多通道优化
        if trimmed.contains("raw.githubusercontent.com") {
            if useFallback {
                // 如果主CDN异常，则采用备用高速镜像加速网
                return trimmed.replacingOccurrences(of: "https://raw.githubusercontent.com/", with: "https://raw.gitmirror.com/")
            } else {
                // 主线路：自动转换成全球极速的 jsDelivr CDN 直连线路，国内访问极速且稳定
                let pattern = "https://raw.githubusercontent.com/([^/]+)/([^/]+)/([^/]+)/(.+)"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
                    if let match = regex.firstMatch(in: trimmed, options: [], range: range) {
                        if let usernameRange = Range(match.range(at: 1), in: trimmed),
                           let repoRange = Range(match.range(at: 2), in: trimmed),
                           let branchRange = Range(match.range(at: 3), in: trimmed),
                           let pathRange = Range(match.range(at: 4), in: trimmed) {
                            let username = String(trimmed[usernameRange])
                            let repo = String(trimmed[repoRange])
                            let branch = String(trimmed[branchRange])
                            let path = String(trimmed[pathRange])
                            return "https://cdn.jsdelivr.net/gh/\(username)/\(repo)@\(branch)/\(path)"
                        }
                    }
                }
                return trimmed.replacingOccurrences(of: "https://raw.githubusercontent.com/", with: "https://raw.gitmirror.com/")
            }
        }
        return trimmed
    }

    private func load() {
        if image != nil { return }
        
        // 优先从内存/本地沙盒缓存拉取
        if let cached = RemoteImageCache.shared.get(url) {
            self.image = cached
            return
        }
        
        executeDownload(useFallback: false)
    }

    private func executeDownload(useFallback: Bool) {
        let requestUrlStr = getOptimizedURL(url, useFallback: useFallback)
        
        // 增进安全：对可能含有特殊字符或中文的URL进行高兼容性百分比转义，防止URL创建失败
        guard let encodedUrlString = requestUrlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let imageURL = URL(string: encodedUrlString) else {
            print("⚠️ [RemoteImageView] URL格式非法: \(requestUrlStr)")
            return
        }
        
        // 构建带有标准移动端Safari User-Agent的高透Request，规避CDN等防盗链或防抓取机制拦截，并配置持久本地网络缓存
        var request = URLRequest(url: imageURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 12)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.currentTask = nil
                }
            }
            
            // 处理取消状态
            if let error = error as NSError?, error.code == NSURLErrorCancelled {
                return
            }
            
            // 自动重试机制：如果出错、超时或返回非200状态码，进行备用通道或重试
            if error != nil || (response as? HTTPURLResponse)?.statusCode != 200 {
                DispatchQueue.main.async {
                    if self.retryCount < 2 {
                        self.retryCount += 1
                        print("🔄 [RemoteImageView] 主渠道加载失败，尝试备用高速通道(重试次数: \(self.retryCount)): \(self.url)")
                        self.executeDownload(useFallback: true)
                    } else {
                        print("⚠️ [RemoteImageView] 图片加载终极失败: \(self.url)")
                    }
                }
                return
            }
            
            guard let data = data, let ui = UIImage(data: data) else { return }
            
            // 保存至双通道缓存（内存+持久化磁盘沙盒）
            RemoteImageCache.shared.set(ui, data: data, for: self.url)
            
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
