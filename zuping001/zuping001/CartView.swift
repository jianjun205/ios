//
//  CartView.swift
//  zuping01
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var orderManager: OrderManager
    @ObservedObject private var router = AppRouter.shared
    @State private var navigateToOrderConfirm = false
    @State private var navigateToOrderList = false
    @State private var checkoutItems: [CartItem] = []

    var body: some View {
        Group {
            if cartManager.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("购物车是空的")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("去首页挑选数码设备吧")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack {
                        List {
                            ForEach(cartManager.items) { item in
                                CartItemRow(item: item)
                            }
                            .onDelete(perform: cartManager.removeFromCart)
                        }
                        .listStyle(PlainListStyle())

                        // 底部结算栏
                        HStack {
                            VStack(alignment: .leading) {
                                Text("合计")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("¥\(String(format: "%.0f", cartManager.totalPrice))")
                                    .font(.system(size: 22))
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }

                            Spacer()

                            Button {
                                // 快照当前购物车，避免提交后清空购物车导致订单项丢失
                                checkoutItems = cartManager.items
                                navigateToOrderConfirm = true
                            } label: {
                                Text("结算(\(cartManager.itemCount))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding()
                        .background(
                            BlurView(style: .systemThickMaterial)
                                .edgesIgnoringSafeArea(.bottom)
                        )
                    }
                }
            }
            .navigationBarTitle("购物车", displayMode: .inline)
            .background(
                // 两个跳转链接始终存在（独立于购物车空/非空状态），确保清空购物车后链接及其绑定不被销毁
                ZStack {
                    NavigationLink(
                        destination: OrderConfirmView(cartItems: checkoutItems, onOrderPlaced: {
                            // 提交成功：在本栈内用“我的订单”替换“确认订单”，返回时直接回到购物车
                            navigateToOrderConfirm = false
                            navigateToOrderList = true
                        }),
                        isActive: $navigateToOrderConfirm
                    ) { EmptyView() }
                    .isDetailLink(false)
                    .frame(width: 0, height: 0)
                    .opacity(0)

                    NavigationLink(
                        destination: OrderListView(initialTab: 0, onBack: {
                            navigateToOrderList = false
                        }),
                        isActive: $navigateToOrderList
                    ) { EmptyView() }
                    .isDetailLink(false)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                }
            )
    }
}


// MARK: - 购物车商品行
struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if item.product.isRemoteImage {
                    RemoteImageView(url: item.product.imageUrl)
                } else if UIImage(named: item.product.imageUrl) != nil {
                    Image(item.product.imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.15)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Color.blue.opacity(0.5))
                        )
                }
            }
            .frame(width: 70, height: 70)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.product.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(item.product.category)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Text("¥\(String(format: "%.0f", item.product.price))/天")
                        .font(.headline)
                        .foregroundColor(.red)

                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            cartManager.updateQuantity(for: item, quantity: item.quantity - 1)
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(item.quantity <= 1 ? Color.gray.opacity(0.5) : .gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(item.quantity <= 1)

                        Text("\(item.quantity)")
                            .font(.subheadline)
                            .frame(minWidth: 20)

                        Button {
                            cartManager.updateQuantity(for: item, quantity: item.quantity + 1)
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartManager.shared)
            .environmentObject(OrderManager.shared)
    }
}
