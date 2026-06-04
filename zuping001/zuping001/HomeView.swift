//
//  HomeView.swift
//  zuping01
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cartManager: CartManager
    @ObservedObject private var store  = ProductStore.shared
    @ObservedObject private var router = AppRouter.shared
    @State private var selectedCategory: String? = nil

    /// 根据选中分类过滤后的设备列表
    private var displayedProducts: [Product] {
        guard let category = selectedCategory else { return store.products }
        return store.products.filter { $0.category == category }
    }

    var body: some View {
        Group {
            if store.isLoading && store.products.isEmpty {
                    VStack(spacing: 16) {
                        ActivityIndicatorView()
                            .scaleEffect(1.2)
                        Text("加载中...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = store.errorMessage, store.products.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("重新加载") {
                            store.fetchProducts()
                        }
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            let banners = store.bannerProducts.isEmpty
                                ? Array(store.products.prefix(3))
                                : store.bannerProducts
                            if !banners.isEmpty {
                                BannerView(products: banners)
                                    .padding(.top, 12)
                            }

                            // 分类快捷入口
                            CategoryQuickBar(products: store.products,
                                             selectedCategory: $selectedCategory)
                                .padding(.horizontal)

                            ProductGrid(products: displayedProducts)
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationBarTitle("数码租赁平台", displayMode: .inline)
            .onAppear {
                if store.products.isEmpty {
                    store.fetchProducts()
                }
            }
            .id(router.homeNavId)
    }
}

// MARK: - 分类快捷入口
struct CategoryQuickBar: View {
    let products: [Product]
    @Binding var selectedCategory: String?

    /// 不在分类栏中展示的分类
    private let hiddenCategories: Set<String> = ["游戏设备", "音影设备"]

    private var categories: [String] {
        var seen = Set<String>()
        return products.compactMap { p in
            guard !hiddenCategories.contains(p.category) else { return nil }
            guard !seen.contains(p.category) else { return nil }
            seen.insert(p.category)
            return p.category
        }
    }

    private func icon(for category: String) -> String {
        switch category {
        case "相机摄影": return "camera.fill"
        case "无人机":   return "airplane"
        case "笔记本电脑": return "laptopcomputer"
        case "手机平板": return "iphone"
        case "游戏设备": return "gamecontroller.fill"
        case "音影设备": return "tv.fill"
        default:        return "square.grid.2x2.fill"
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(categories, id: \.self) { cat in
                let isSelected = selectedCategory == cat
                Button {
                    // 再次点击已选中的分类则取消筛选
                    selectedCategory = isSelected ? nil : cat
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: icon(for: cat))
                            .font(.system(size: 22))
                            .foregroundColor(isSelected ? .white : .blue)
                            .frame(width: 48, height: 48)
                            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text(cat)
                            .font(.caption)
                            .foregroundColor(isSelected ? .blue : .primary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 两列网格（iOS 13 替代 LazyVGrid）
struct ProductGrid: View {
    let products: [Product]

    var body: some View {
        let pairs: [[Product]] = stride(from: 0, to: products.count, by: 2).map { idx in
            idx + 1 < products.count ? [products[idx], products[idx + 1]] : [products[idx]]
        }
        return VStack(spacing: 12) {
            ForEach(0..<pairs.count, id: \.self) { i in
                HStack(spacing: 12) {
                    ForEach(pairs[i]) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            ProductCardView(product: product)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    if pairs[i].count == 1 {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Banner 轮播（iOS 13 兼容，无缝循环）
struct BannerView: View {
    let products: [Product]
    private var loopedProducts: [Product] {
        guard products.count > 1, let first = products.first else { return products }
        return products + [first]
    }
    @State private var currentIndex   = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging     = false
    @State private var navigatingProductIndex: Int? = nil
    private let timer        = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let bannerHeight: CGFloat  = 200
    private let horizontalPadding: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let pageWidth = geo.size.width
            let pages = loopedProducts
            ZStack(alignment: .bottom) {
                ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                    NavigationLink(
                        destination: ProductDetailView(product: product),
                        tag: index,
                        selection: $navigatingProductIndex
                    ) { EmptyView() }
                    .frame(width: 0, height: 0)
                    .opacity(0)
                }

                HStack(spacing: 0) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        BannerItemView(product: pages[index])
                            .frame(width: pageWidth, height: bannerHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .frame(width: pageWidth, height: bannerHeight, alignment: .leading)
                .offset(x: -CGFloat(currentIndex) * pageWidth + dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold = pageWidth / 4
                            let dx = value.translation.width
                            let dy = value.translation.height
                            if abs(dx) < 5 && abs(dy) < 5 {
                                navigatingProductIndex = currentIndex % products.count
                                withAnimation(.easeInOut(duration: 0.2)) { dragOffset = 0 }
                                isDragging = false
                                return
                            }
                            var newIndex = currentIndex
                            if dx < -threshold {
                                newIndex = min(currentIndex + 1, pages.count - 1)
                            } else if dx > threshold {
                                newIndex = max(currentIndex - 1, 0)
                            }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex = newIndex
                                dragOffset = 0
                            }
                            isDragging = false
                            handleLoopReset(pageCount: pages.count)
                        }
                )

                HStack(spacing: 6) {
                    ForEach(0..<products.count, id: \.self) { i in
                        Circle()
                            .fill(i == (currentIndex % products.count) ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 10)
            }
            .frame(width: pageWidth, height: bannerHeight)
            .clipped()
        }
        .frame(height: bannerHeight)
        .padding(.horizontal, horizontalPadding)
        .onReceive(timer) { _ in
            guard products.count > 1, !isDragging, dragOffset == 0 else { return }
            withAnimation(.easeInOut(duration: 0.4)) { currentIndex += 1 }
            handleLoopReset(pageCount: loopedProducts.count)
        }
    }

    private func handleLoopReset(pageCount: Int) {
        guard products.count > 1, currentIndex == pageCount - 1 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
            currentIndex = 0
        }
    }
}

extension Array {
    subscript(safeIndex idx: Int) -> Element? {
        return indices.contains(idx) ? self[idx] : nil
    }
}

// MARK: - Banner 单张
struct BannerItemView: View {
    let product: Product

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.gray.opacity(0.1)
                .overlay(
                    Group {
                        if product.isRemoteImage {
                            RemoteImageView(url: product.imageUrl)
                        } else if UIImage(named: product.imageUrl) != nil {
                            Image(product.imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color(red: 0, green: 0.8, blue: 1).opacity(0.5)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.45), Color.clear]),
                startPoint: .bottom,
                endPoint: .center
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("推荐")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())

                Text(product.name)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("¥\(String(format: "%.0f", product.price))/天")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }
            .padding()
        }
    }
}

// MARK: - 商品卡片
struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.gray.opacity(0.12)
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .overlay(
                    Group {
                        if product.isRemoteImage {
                            RemoteImageView(url: product.imageUrl)
                        } else if UIImage(named: product.imageUrl) != nil {
                            Image(product.imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(Color.blue.opacity(0.5))
                        }
                    }
                )
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(product.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(product.category)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)

            Text("¥\(String(format: "%.0f", product.price))/天")
                .font(.headline)
                .foregroundColor(.red)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - iOS 13 兼容菊花
struct ActivityIndicatorView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let v = UIActivityIndicatorView(style: .medium)
        v.startAnimating()
        v.color = .gray
        return v
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
