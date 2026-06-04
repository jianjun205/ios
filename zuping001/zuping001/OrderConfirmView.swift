//
//  OrderConfirmView.swift
//  zuping01
//

import SwiftUI

struct OrderConfirmView: View {
    var product: Product?
    var cartItems: [CartItem]?

    @EnvironmentObject var addressManager: AddressManager
    @EnvironmentObject var orderManager: OrderManager
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var router: AppRouter
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedAddress: Address?
    @State private var quantity: Int = 1
    @State private var showSuccessAlert = false
    @State private var showNoAddressAlert = false
    @State private var agreedToRentalGuide = true
    @State private var showRentalGuide = false

    private var orderItems: [CartItem] {
        if let cartItems = cartItems { return cartItems }
        if let product = product { return [CartItem(product: product, quantity: quantity)] }
        return []
    }

    private var totalAmount: Double {
        orderItems.reduce(0) { $0 + $1.totalPrice }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AddressSelectorView(selectedAddress: $selectedAddress)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("设备信息")
                                .font(.headline)

                            if let product = product {
                                OrderItemRow(item: CartItem(product: product, quantity: quantity))
                            } else if let cartItems = cartItems {
                                VStack(spacing: 8) {
                                    ForEach(cartItems) { item in
                                        OrderItemRow(item: item)
                                    }
                                }
                            }
                        }

                        if product != nil {
                            HStack {
                                Text("租用天数")
                                    .font(.subheadline)
                                Spacer()
                                HStack(spacing: 16) {
                                    Button {
                                        if quantity > 1 { quantity -= 1 }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(quantity <= 1 ? .gray : .blue)
                                    }
                                    .disabled(quantity <= 1)
                                    .buttonStyle(BorderlessButtonStyle())

                                    Text("\(quantity)")
                                        .font(.headline)
                                        .frame(minWidth: 30)

                                    Button {
                                        quantity += 1
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        HStack {
                            Text("合计金额")
                                .font(.headline)
                            Spacer()
                            Text("¥\(String(format: "%.0f", totalAmount))")
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Spacer(minLength: 120)
                    }
                    .padding()
                }

                // 底部确认栏
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Button {
                            agreedToRentalGuide.toggle()
                        } label: {
                            Image(systemName: agreedToRentalGuide ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(agreedToRentalGuide ? .blue : Color.gray.opacity(0.5))
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        HStack(spacing: 3) {
                            Text("我已阅读并同意")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Button {
                                showRentalGuide = true
                            } label: {
                                Text("《租赁须知》")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                    Button {
                        guard selectedAddress != nil else {
                            showNoAddressAlert = true
                            return
                        }
                        _ = orderManager.createOrder(from: orderItems, address: selectedAddress)
                        showSuccessAlert = true
                    } label: {
                        Text("提交订单")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(agreedToRentalGuide ? Color.blue : Color.gray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!agreedToRentalGuide)
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(
                    BlurView(style: .systemThickMaterial)
                        .edgesIgnoringSafeArea(.bottom)
                )
        }
        .navigationBarTitle("确认订单", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
        })
        .onAppear {
            selectedAddress = addressManager.defaultAddress
        }
        .sheet(isPresented: $showRentalGuide) {
            NavigationView {
                RentalGuideView()
                    .navigationBarItems(trailing: Button("关闭") { showRentalGuide = false })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .background(
            EmptyView()
                .alert(isPresented: $showSuccessAlert) {
                    Alert(
                        title: Text("提交成功"),
                        message: Text("租赁订单已成功提交，请您耐心等候，后续工作人员将尽快与您联系对接。"),
                        dismissButton: .default(Text("确定")) {
                            if cartItems != nil { cartManager.clearCart() }
                            router.goToOrderList()
                        }
                    )
                }
        )
        .background(
            EmptyView()
                .alert(isPresented: $showNoAddressAlert) {
                    Alert(
                        title: Text("请添加收货地址"),
                        message: Text("请先添加一个收货地址再提交订单"),
                        dismissButton: .cancel(Text("确定"))
                    )
                }
        )
    }
}

// MARK: - 订单商品行
struct OrderItemRow: View {
    let item: CartItem

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
                    Text("\(item.quantity)天")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 地址选择器
struct AddressSelectorView: View {
    @EnvironmentObject var addressManager: AddressManager
    @Binding var selectedAddress: Address?
    @State private var navigateToPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 隐藏跳转链接（始终挂载，避免条件分支被销毁时 iOS 13 nav binding 失联）
            NavigationLink(
                destination: AddressPickerView(selectedAddress: $selectedAddress),
                isActive: $navigateToPicker
            ) { EmptyView() }
            .frame(width: 0, height: 0)
            .opacity(0)

            HStack {
                Text("收货地址")
                    .font(.headline)
                Spacer()
                if !addressManager.addresses.isEmpty {
                    Button("更改地址") { navigateToPicker = true }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            if let address = selectedAddress {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(address.name).fontWeight(.medium)
                        Text(address.phone).foregroundColor(.secondary)
                    }
                    Text(address.fullAddress)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                NavigationLink(destination: AddAddressView { newAddress in
                    addressManager.addAddress(newAddress)
                    selectedAddress = newAddress
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("添加收货地址")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

// MARK: - 地址选择页（NavigationLink push，彻底规避 iOS 13 sheet-in-push 自动关页 bug）
struct AddressPickerView: View {
    @EnvironmentObject var addressManager: AddressManager
    @Binding var selectedAddress: Address?
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List(addressManager.addresses) { address in
            Button {
                selectedAddress = address
                presentationMode.wrappedValue.dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(address.name).fontWeight(.medium)
                        Text(address.phone).foregroundColor(.secondary)
                        if address.isDefault {
                            Text("默认").font(.system(size: 11)).foregroundColor(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        Spacer()
                        if selectedAddress?.id == address.id {
                            Image(systemName: "checkmark").foregroundColor(.blue)
                        }
                    }
                    Text(address.fullAddress).font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .foregroundColor(.primary)
        }
        .navigationBarTitle("选择收货地址", displayMode: .inline)
        .navigationBarItems(trailing: NavigationLink(destination: AddAddressView { newAddress in
            addressManager.addAddress(newAddress)
            selectedAddress = newAddress
        }) {
            Image(systemName: "plus").foregroundColor(.blue)
        })
    }
}
