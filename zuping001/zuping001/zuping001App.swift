//
//  zuping001App.swift
//  zuping001
//

import SwiftUI

// MARK: - 主Tab容器视图（iOS 13 兼容）
struct MainTabView: View {
    @State private var selectedTab = 0
    @ObservedObject private var router = AppRouter.shared
    @EnvironmentObject var authManager: AuthManager
    @State private var pendingProtectedTab: Int? = nil

    private var tabSelection: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if (newValue == 1 || newValue == 2) && !authManager.isLoggedIn {
                    pendingProtectedTab = newValue
                    authManager.showLoginView = true
                } else {
                    selectedTab = newValue
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            TabView(selection: tabSelection) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("首页")
                    }
                    .tag(0)

                CartView()
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("购物车")
                    }
                    .tag(1)

                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("个人中心")
                    }
                    .tag(2)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $authManager.showLoginView) {
            LoginView()
                .environmentObject(authManager)
        }
        .onReceive(router.$navigateToOrderList) { navigate in
            if navigate {
                // 当收到全局路由触发跳转至订单页面的请求时，切到个人中心 Tab 并清除触发标记
                selectedTab = 2
                router.navigateToOrderList = false
            }
        }
        .onReceive(authManager.$isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                if let pending = pendingProtectedTab {
                    DispatchQueue.main.async {
                        selectedTab = pending
                        pendingProtectedTab = nil
                    }
                }
            } else {
                // 如果退出登录/注销账号，自动退回首页
                DispatchQueue.main.async {
                    selectedTab = 0
                    pendingProtectedTab = nil
                }
            }
        }
    }
}

// MARK: - App 启动入口生命周期代理 (兼容 iOS 13 无 SceneDelegate)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        // 统一注入各业务控制器作为全局环境共享对象 (EnvironmentObject)
        let root = MainTabView()
            .environmentObject(AuthManager.shared)
            .environmentObject(CartManager.shared)
            .environmentObject(OrderManager.shared)
            .environmentObject(AddressManager.shared)
            .environmentObject(ProductStore.shared)
            .environmentObject(AppRouter.shared)
        
        window.rootViewController = UIHostingController(rootView: root)
        self.window = window
        window.makeKeyAndVisible()
        
        // 自动触发商品数据首屏拉取
        ProductStore.shared.fetchProducts()
        
        return true
    }
}
