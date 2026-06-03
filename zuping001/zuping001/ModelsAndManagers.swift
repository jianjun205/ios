//
//  ModelsAndManagers.swift
//  zuping001
//

import SwiftUI
import Combine

// MARK: - 模型定义

struct Product: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let category: String
    let price: Double
    let description: String
    let imageUrl: String
    let isBanner: Bool
    
    var isRemoteImage: Bool {
        imageUrl.hasPrefix("http")
    }
}

struct CartItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        product.price * Double(quantity)
    }
}

struct Address: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let name: String
    let phone: String
    let province: String
    let city: String
    let district: String
    let detail: String
    var isDefault: Bool
    
    var fullAddress: String {
        "\(province)\(city)\(district)\(detail)"
    }
}

struct Order: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let items: [CartItem]
    let shippingAddress: Address
    let orderDate: Date
    var status: OrderStatus = .pending
    
    enum OrderStatus: String, CaseIterable, Hashable, Codable {
        case pending = "待处理"
        case shipping = "配送中"
        case completed = "已完成"
        case returning = "退还中"
    }
    
    var statusDisplayName: String {
        status.rawValue
    }
    
    var statusDescription: String {
        switch status {
        case .pending: return "收货人信息已确认，等待发货"
        case .shipping: return "商品已经寄出，正在快马加鞭"
        case .completed: return "订单已顺利签收并完成结清"
        case .returning: return "商品退还正在寄回并做机器整修"
        }
    }
    
    var statusIcon: String {
        switch status {
        case .pending: return "clock.fill"
        case .shipping: return "car.fill"
        case .completed: return "checkmark.circle.fill"
        case .returning: return "arrow.counterclockwise"
        }
    }
    
    var totalQuantity: Int {
        items.count
    }
    
    var totalAmount: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年MM月dd日 HH:mm"
        return f.string(from: orderDate)
    }
}

struct Region: Identifiable {
    let id = UUID()
    let name: String
    let cities: [City]
}

struct City: Identifiable {
    let id = UUID()
    let name: String
    let districts: [String]
}

struct RegionData {
    static let provinces: [Region] = [
        Region(name: "北京市", cities: [
            City(name: "北京市", districts: ["东城区", "西城区", "朝阳区", "海淀区", "丰台区", "石景山区"])
        ]),
        Region(name: "上海市", cities: [
            City(name: "上海市", districts: ["黄浦区", "徐汇区", "长宁区", "静安区", "普陀区", "浦东新区"])
        ]),
        Region(name: "广东省", cities: [
            City(name: "广州市", districts: ["天河区", "越秀区", "海珠区", "荔湾区", "白云区", "番禺区"]),
            City(name: "深圳市", districts: ["福田区", "罗湖区", "南山区", "宝安区", "龙岗区", "盐田区"])
        ]),
        Region(name: "浙江省", cities: [
            City(name: "杭州市", districts: ["西湖区", "上城区", "拱墅区", "江干区", "滨江区", "萧山区"]),
            City(name: "宁波市", districts: ["海曙区", "江北区", "北仑区", "镇海区", "鄞州区"])
        ])
    ]
}

struct User: Codable, Hashable {
    let nickname: String
    let phone: String
}

// MARK: - 控制器定义

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var showLoginView = false
    @Published var currentUser: User?
    
    private let loginExpirationInterval: TimeInterval = 48 * 60 * 60 // 48小时
    
    private enum Keys {
        static let isLoggedIn = "auth_isLoggedIn"
        static let nickname = "auth_nickname"
        static let phone = "auth_phone"
        static let loginTimestamp = "auth_loginTimestamp"
    }
    
    init() {
        restoreSession()
    }
    
    private func restoreSession() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: Keys.isLoggedIn),
              let timestamp = defaults.object(forKey: Keys.loginTimestamp) as? Date else {
            // 首次运行或已退出，不自动登录
            return
        }
        
        // 检查是否超过48小时
        if Date().timeIntervalSince(timestamp) > loginExpirationInterval {
            clearLocalSession()
            return
        }
        
        let phone = defaults.string(forKey: Keys.phone) ?? ""
        let nickname = defaults.string(forKey: Keys.nickname) ?? "用户"
        currentUser = User(nickname: nickname, phone: phone)
        isLoggedIn = true
    }
    
    func requireLogin() -> Bool {
        if isLoggedIn {
            return true
        } else {
            showLoginView = true
            return false
        }
    }
    
    func loginWithCode(phone: String, code: String) -> Bool {
        // 测试账号控制：必须是测试账号手机号 18888888888 并且验证码为 999999 才能登录成功
        if phone == "18888888888" && code == "999999" {
            let nickname = "租客_\(String(phone.suffix(4)))"
            currentUser = User(nickname: nickname, phone: phone)
            isLoggedIn = true
            saveSession(nickname: nickname, phone: phone)
            return true
        }
        return false
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
        clearLocalSession()
    }
    
    /// 注销账号：永久删除本地账户及业务数据，不可恢复
    func deleteAccount() {
        OrderManager.shared.deleteAllData()
        AddressManager.shared.deleteAllData()
        CartManager.shared.clearCart()
        clearLocalSession()
        isLoggedIn = false
        currentUser = nil
    }
    
    private func saveSession(nickname: String, phone: String) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Keys.isLoggedIn)
        defaults.set(nickname, forKey: Keys.nickname)
        defaults.set(phone, forKey: Keys.phone)
        defaults.set(Date(), forKey: Keys.loginTimestamp)
    }
    
    private func clearLocalSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.isLoggedIn)
        defaults.removeObject(forKey: Keys.nickname)
        defaults.removeObject(forKey: Keys.phone)
        defaults.removeObject(forKey: Keys.loginTimestamp)
    }
}

class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var items: [CartItem] = []
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    func addToCart(product: Product) {
        if let idx = items.firstIndex(where: { $0.product.id == product.id }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func removeFromCart(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: idx)
            } else {
                items[idx].quantity = quantity
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
}

class OrderManager: ObservableObject {
    static let shared = OrderManager()
    
    @Published var orders: [Order] = []
    
    private let storageKey = "saved_orders"
    
    init() {
        loadOrders()
    }
    
    func createOrder(from items: [CartItem], address: Address?) -> Order? {
        guard let address = address else { return nil }
        let newOrder = Order(items: items, shippingAddress: address, orderDate: Date())
        orders.insert(newOrder, at: 0)
        saveOrders()
        return newOrder
    }
    
    private func saveOrders() {
        if let data = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadOrders() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([Order].self, from: data) {
            orders = saved
        }
    }
    
    func deleteAllData() {
        orders.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

class AddressManager: ObservableObject {
    static let shared = AddressManager()
    
    @Published var addresses: [Address] = []
    
    private let storageKey = "saved_addresses"
    
    init() {
        loadAddresses()
    }
    
    var defaultAddress: Address? {
        addresses.first(where: { $0.isDefault }) ?? addresses.first
    }
    
    func addAddress(_ address: Address) {
        var newAddr = address
        if addresses.isEmpty {
            newAddr.isDefault = true
        }
        addresses.append(newAddr)
        saveAddresses()
    }
    
    func removeAddress(at offsets: IndexSet) {
        let removingDefault = offsets.contains(where: { addresses[$0].isDefault })
        addresses.remove(atOffsets: offsets)
        if removingDefault, !addresses.isEmpty {
            addresses[0].isDefault = true
        }
        saveAddresses()
    }
    
    private func saveAddresses() {
        if let data = try? JSONEncoder().encode(addresses) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadAddresses() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([Address].self, from: data) {
            addresses = saved
        } else {
            addresses = [
                Address(name: "张三", phone: "13800138000", province: "北京市", city: "北京市", district: "朝阳区", detail: "科技路 100 号", isDefault: true)
            ]
        }
    }
    
    func deleteAllData() {
        addresses.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

struct ProductListResponse: Codable {
    let code: Int
    let message: String
    let total: Int
    let list: [Product]
}

class ProductStore: ObservableObject {
    static let shared = ProductStore()
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var products: [Product] = []
    @Published var bannerProducts: [Product] = []
    
    // 主线路：全球极速稳定的 jsDelivr CDN 直连线路，解决原始 GitHub Raw 地址在国内经常无法连接的问题
    private let primaryAPIURL = "https://cdn.jsdelivr.net/gh/jianjun205/ios@main/zuping001/listSM.json"
    // 备份线路：GitHub 原始物理镜像加速站
    private let fallbackAPIURL = "https://raw.gitmirror.com/jianjun205/ios/main/zuping001/listSM.json"
    // 用户直接指定的官方 GitHub 原始线路
    private let originalAPIURL = "https://raw.githubusercontent.com/jianjun205/ios/main/zuping001/listSM.json"
    
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        // 1. 优先尝试从本地绝对物理路径以及 App Bundle 中读取最新的 listSM.json
        // 这在本地开发和设备调试时极其关键，能够避开任何在线 CDN 缓存迟滞，让您对 listSM.json 的更改瞬时呈现
        if fetchFromLocal() {
            return
        }
        
        // 2. 如果本地绝对路径和 Bundle 均未命中（如发布后的正式用户端），降级尝试从高速 CDN 线路加载
        print("🔄 [ProductStore] 本地加载未命中，启动网络拉取进程...")
        fetchFromRemote(urlString: primaryAPIURL) { [weak self] success in
            guard let self = self else { return }
            if success { return }
            
            // 尝试备用镜像加速路线
            print("🔄 [ProductStore] CDN 获取失败，尝试使用备用镜像路线中...")
            self.fetchFromRemote(urlString: self.fallbackAPIURL) { success2 in
                if success2 { return }
                
                // 尝试最底层原始 GitHub 默认物理路线
                print("🔄 [ProductStore] 镜像获取失败，尝试最底层原始 GitHub 默认物理路线...")
                self.fetchFromRemote(urlString: self.originalAPIURL) { success3 in
                    if success3 { return }
                    
                    // 3. 最终静态兜底
                    print("⚠️ [ProductStore] 所有网络及文件获取失败，执行静态数据兜底...")
                    self.loadMockProducts()
                }
            }
        }
    }
    
    private func fetchFromRemote(urlString: String, onFinished: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            onFinished(false)
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("⚠️ [ProductStore] 网络加载故障 (\(urlString)): \(error.localizedDescription)")
                    onFinished(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    onFinished(false)
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(ProductListResponse.self, from: data)
                    self.products = res.list
                    self.bannerProducts = res.list.filter { $0.isBanner }
                    self.errorMessage = nil
                    self.isLoading = false
                    onFinished(true)
                } catch {
                    print("⚠️ [ProductStore] 数据解析故障: \(error)")
                    onFinished(false)
                }
            }
        }.resume()
    }
    
    @discardableResult
    private func fetchFromLocal() -> Bool {
        // 1. 优先尝试从绝对路径加载最新的 listSM.json
        let localPath = "/Users/andy/ios/zuping001/listSM.json"
        if let data = try? Data(contentsOf: URL(fileURLWithPath: localPath)) {
            do {
                let response = try JSONDecoder().decode(ProductListResponse.self, from: data)
                self.products = response.list
                self.bannerProducts = response.list.filter { $0.isBanner }
                self.isLoading = false
                print("✅ [ProductStore] 成功从本地绝对物理路径加载商品列表：\(localPath)")
                return true
            } catch {
                print("⚠️ [ProductStore] 读取本地绝对路径遇到解析错误: \(error)")
            }
        }
        
        // 2. 备用尝试从 Bundle 中加载 listSM.json
        if let bundleURL = Bundle.main.url(forResource: "listSM", withExtension: "json"),
           let data = try? Data(contentsOf: bundleURL) {
            do {
                let response = try JSONDecoder().decode(ProductListResponse.self, from: data)
                self.products = response.list
                self.bannerProducts = response.list.filter { $0.isBanner }
                self.isLoading = false
                print("✅ [ProductStore] 成功从 App Bundle 加载商品数据!")
                return true
            } catch {
                print("⚠️ [ProductStore] 读取 Bundle 内遇到解析错误: \(error)")
            }
        }
        return false
    }
    
    private func loadMockProducts() {
        // 💾 尝试从本地绝对路径加载 listSM.json 作为最底层的静态兜底数据数据源
        let localPath = "/Users/andy/ios/zuping001/listSM.json"
        if let data = try? Data(contentsOf: URL(fileURLWithPath: localPath)) {
            do {
                let response = try JSONDecoder().decode(ProductListResponse.self, from: data)
                self.products = response.list
                self.bannerProducts = response.list.filter { $0.isBanner }
                self.isLoading = false
                print("✅ [ProductStore] 静态兜底成功：已成功从本地绝对路径加载全部 \(response.list.count) 条静态商品！")
                return
            } catch {
                print("⚠️ [ProductStore] 静态兜底解析本地绝对路径报错: \(error)")
            }
        }
        
        // 💾 尝试从 App Bundle 中加载 listSM.json 作为最后的静态本地兜底
        if let bundleURL = Bundle.main.url(forResource: "listSM", withExtension: "json"),
           let data = try? Data(contentsOf: bundleURL) {
            do {
                let response = try JSONDecoder().decode(ProductListResponse.self, from: data)
                self.products = response.list
                self.bannerProducts = response.list.filter { $0.isBanner }
                self.isLoading = false
                print("✅ [ProductStore] 静态兜底成功：已成功从 App Bundle 中加载全部 \(response.list.count) 条静态商品！")
                return
            } catch {
                print("⚠️ [ProductStore] 静态兜底解析 Bundle 资源报错: \(error)")
            }
        }
        
        // 最后的最终极端备用数据（以防所有文件都不存在）
        let mockProducts = [
            Product(id: "1", name: "iPhone 15 Pro Max 512GB", category: "手机平板", price: 39.0, description: "搭载最新 A17 Pro 芯片，全新钛金属物理边框设计。4800万像素主摄，5倍光学变焦，长焦效果极其震撼，专业自媒体陈列与出片首选。", imageUrl: "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500&auto=format&fit=crop&q=60", isBanner: true),
            Product(id: "2", name: "iPad Pro 12.9 英寸 M2", category: "手机平板", price: 29.0, description: "业界天花板级生产力工具。搭配 Apple Pencil 以及极速妙控键盘，运行澎湃 M2 芯片，绚丽的 Liquid 视网膜 XDR 屏带给你顶级视听。", imageUrl: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500&auto=format&fit=crop&q=60", isBanner: true)
        ]
        self.products = mockProducts
        self.bannerProducts = mockProducts.filter { $0.isBanner }
        self.isLoading = false
    }
}

class AppRouter: ObservableObject {
    static let shared = AppRouter()
    
    @Published var navigateToOrderList = false
    @Published var pendingOrderListTab: Int? = 0
    @Published var showLogoutAlert = false
    @Published var showDeleteAccountAlert = false
    
    func goToOrderList() {
        pendingOrderListTab = 0
        navigateToOrderList = true
    }
}
