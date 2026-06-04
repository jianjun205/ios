//
//  ProductDetailView.swift
//  zuping01
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cartManager: CartManager
    @State private var showAddedAlert = false
    @State private var navigateToOrder = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 设备大图
                    Group {
                        if product.isRemoteImage {
                            RemoteImageView(url: product.imageUrl)
                        } else if UIImage(named: product.imageUrl) != nil {
                            Image(product.imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color(red: 0, green: 0.8, blue: 1).opacity(0.2)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .foregroundColor(Color.blue.opacity(0.5))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("¥\(String(format: "%.0f", product.price))/天")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)

                        Text(product.name)
                            .font(.system(size: 22))
                            .fontWeight(.semibold)

                        Text(product.category)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())

                        Divider()

                        SectionHeader(text: "设备介绍")

                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()
                            .padding(.top, 4)

                        SectionHeader(text: "设备规格")

                        VStack(spacing: 0) {
                            SpecRow(label: "设备类别", value: product.category)
                            SpecRow(label: "技术规格", value: "官方旗舰版本 / 原装配件齐全")
                            SpecRow(label: "参考重量", value: "随设备型号而定")
                            SpecRow(label: "包装方式", value: "防震内衬 + 专业运输箱")
                            SpecRow(label: "起租时长", value: "1 天起租", isLast: true)
                        }
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        SectionHeader(text: "租赁须知")
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(text: "支持灵活租期，可按需选择租用天数。")
                            TipRow(text: "提交订单后工作人员会在 72 小时内与您联系确认档期与配送细节。")
                            TipRow(text: "设备采用专业防震包装，支持同城配送与跨城物流。")
                            TipRow(text: "使用期间请妥善保管，归还时如有损坏将按合同约定收取相应费用。")
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal)
                }
            }

            // 底部操作栏
            HStack(spacing: 12) {
                // 隐藏 NavigationLink
                NavigationLink(
                    destination: OrderConfirmView(product: product),
                    isActive: $navigateToOrder
                ) { EmptyView() }
                .frame(width: 0, height: 0)
                .opacity(0)

                Button {
                    if authManager.requireLogin() {
                        cartManager.addToCart(product: product)
                        showAddedAlert = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                        Text("加入购物车")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    if authManager.requireLogin() {
                        navigateToOrder = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("立即租赁")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(
                BlurView(style: .systemThickMaterial)
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
        .navigationBarTitle("", displayMode: .inline)
        .alert(isPresented: $showAddedAlert) {
            Alert(title: Text("已加入购物车"), dismissButton: .cancel(Text("确定")))
        }
    }
}

// MARK: - 区块标题
struct SectionHeader: View {
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 3, height: 16)
            Text(text)
                .font(.headline)
        }
    }
}

// MARK: - 规格行
struct SpecRow: View {
    let label: String
    let value: String
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .padding(.leading, 12)
            }
        }
    }
}

// MARK: - 须知行
struct TipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.black)
                .font(.system(size: 22))
                .padding(.top, -2)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
