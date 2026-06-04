//
//  ProfileView.swift
//  zuping01
//

import SwiftUI

// MARK: - 主视图
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var orderManager: OrderManager
    @ObservedObject private var router = AppRouter.shared
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showDeleteAccountConfirmAlert = false

    private var orderCount: Int { orderManager.orders.count }

    var body: some View {
        ZStack {
            ScrollView {
                ZStack(alignment: .top) {
                    // 隐藏 NavigationLink 用于 router.goToOrderList() 跳转
                    NavigationLink(
                        destination: OrderListView(initialTab: router.pendingOrderListTab ?? 0),
                        isActive: $router.navigateToOrderList
                    ) { EmptyView() }
                    .frame(width: 0, height: 0)
                    .opacity(0)

                    VStack(spacing: 0) {
                        // 顶部渐变背景 + 用户信息
                        ZStack(alignment: .bottom) {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.75), Color.blue.opacity(0.45)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(height: 280)
                            .edgesIgnoringSafeArea(.top)

                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.25))
                                        .frame(width: 90, height: 90)

                                    Image(systemName: "person.fill")
                                        .font(.system(size: 38, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 76, height: 76)
                                        .background(Circle().fill(Color.white.opacity(0.3)))
                                }

                                Text(authManager.currentUser?.nickname ?? "用户")
                                    .font(.system(size: 22))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                HStack(spacing: 10) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 11))
                                        Text(maskedPhone)
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(Color.white.opacity(0.9))

                                    Text("普通会员")
                                        .font(.system(size: 11))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color.white))
                                }
                            }
                            .padding(.bottom, 30)
                        }

                        // 订单概览
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                NavigationLink(destination: OrderListView(initialTab: 0)) {
                                    OrderQuickItem(icon: "clock.fill", title: "待处理", count: orderCount)
                                }.buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: OrderListView(initialTab: 1)) {
                                    OrderQuickItem(icon: "archivebox.fill", title: "配送中", count: 0)
                                }.buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: OrderListView(initialTab: 2)) {
                                    OrderQuickItem(icon: "checkmark.circle.fill", title: "已完成", count: 0)
                                }.buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: OrderListView(initialTab: 3)) {
                                    OrderQuickItem(icon: "arrow.counterclockwise", title: "退还中", count: 0)
                                }.buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 18)
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 16)
                        .offset(y: -20)

                        // 常用工具
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                NavigationLink(destination: AddressListView()) {
                                    ToolQuickItem(icon: "mappin.circle.fill", color: .blue, title: "收货地址")
                                }.buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: FAQView()) {
                                    ToolQuickItem(icon: "questionmark.circle.fill", color: .green, title: "常见问题")
                                }.buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: RentalGuideView()) {
                                    ToolQuickItem(icon: "doc.text.fill", color: .orange, title: "租赁须知")
                                }.buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: AboutUsView()) {
                                    ToolQuickItem(icon: "info.circle.fill", color: .purple, title: "关于我们")
                                }.buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 18)
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, -4)

                        // 服务保障
                        VStack(spacing: 14) {
                            HStack(spacing: 12) {
                                ServiceBadge(icon: "checkmark.seal.fill", title: "正品保障", color: .blue)
                                ServiceBadge(icon: "car.fill", title: "安全配送", color: .green)
                                ServiceBadge(icon: "arrow.triangle.2.circlepath", title: "退换无忧", color: .orange)
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        // 退出登录
                        Button {
                            showLogoutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .font(.body)
                                Text("退出登录")
                                    .font(.body)
                            }
                            .foregroundColor(Color.red.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // 注销账号
                        Button {
                            showDeleteAccountAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.body)
                                Text("注销账号")
                                    .font(.body)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 30)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("确认退出"),
                    message: Text("是否确认退出当前账号？"),
                    primaryButton: .destructive(Text("退出")) { authManager.logout() },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
            .background(
                EmptyView()
                    .alert(isPresented: $showDeleteAccountAlert) {
                        Alert(
                            title: Text("注销账号"),
                            message: Text("注销后将永久删除您的账户信息、订单记录、收货地址等全部数据，且无法恢复。是否继续？"),
                            primaryButton: .destructive(Text("继续")) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    showDeleteAccountConfirmAlert = true
                                }
                            },
                            secondaryButton: .cancel(Text("取消"))
                        )
                    }
            )
            .background(
                EmptyView()
                    .alert(isPresented: $showDeleteAccountConfirmAlert) {
                        Alert(
                            title: Text("再次确认"),
                            message: Text("此操作不可撤销。确定要立即注销账号并删除全部数据吗？"),
                            primaryButton: .destructive(Text("确认注销")) {
                                authManager.deleteAccount()
                            },
                            secondaryButton: .cancel(Text("取消"))
                        )
                    }
            )
        }
        .id(router.profileNavId)
    }

    private var maskedPhone: String {
        let phone = authManager.currentUser?.phone ?? ""
        guard phone.count >= 11 else { return phone }
        let prefix = phone.prefix(3)
        let suffix = phone.suffix(4)
        return "\(prefix)****\(suffix)"
    }
}

// MARK: - 订单快捷入口
struct OrderQuickItem: View {
    let icon: String
    let title: String
    var count: Int = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(Color.blue.opacity(0.85))

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 10, y: -6)
                }
            }
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 工具快捷入口
struct ToolQuickItem: View {
    let icon: String
    let color: Color
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 服务标签
struct ServiceBadge: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 订单列表
struct OrderListView: View {
    @EnvironmentObject var orderManager: OrderManager
    @State var selectedTab: Int
    var onBack: (() -> Void)? = nil

    init(initialTab: Int = 0, onBack: (() -> Void)? = nil) {
        _selectedTab = State(initialValue: initialTab)
        self.onBack = onBack
    }

    private let tabs = Order.OrderStatus.allCases

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年MM月dd日 HH:mm"
        return f
    }()

    private func ordersFor(_ status: Order.OrderStatus) -> [Order] {
        orderManager.orders.filter { $0.status == status }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.element) { index, status in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(status.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .foregroundColor(selectedTab == index ? .blue : .secondary)

                            Rectangle()
                                .fill(selectedTab == index ? Color.blue : Color.clear)
                                .frame(height: 2)
                                .frame(maxWidth: 30)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 8)
            .background(Color(.systemBackground))

            let status = tabs[selectedTab]
            let filtered = ordersFor(status)
            Group {
                if filtered.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(Color.gray.opacity(0.5))
                        Text("暂无\(status.rawValue)订单")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filtered) { order in
                                NavigationLink(destination: OrderDetailView(order: order)) {
                                    OrderCardView(order: order, dateText: Self.dateFormatter.string(from: order.orderDate))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarTitle("我的订单", displayMode: .inline)
        .navigationBarBackButtonHidden(onBack != nil)
        .navigationBarItems(leading: Group {
            if let onBack = onBack {
                Button(action: {
                    onBack()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("返回")
                            .foregroundColor(.blue)
                    }
                }
            }
        })
    }
}

// MARK: - 订单卡片
struct OrderCardView: View {
    let order: Order
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("订单号 \(String(order.id.uuidString.prefix(8)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(order.status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Capsule())
            }

            Divider()

            VStack(spacing: 10) {
                ForEach(order.items) { item in
                    HStack(spacing: 10) {
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
                        .frame(width: 50, height: 50)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text(item.product.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("¥\(String(format: "%.0f", item.product.price))")
                                .font(.subheadline)
                                .foregroundColor(.red)
                            Text("\(item.quantity)天")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("共\(order.items.count)件商品")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("合计 ")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                + Text("¥\(String(format: "%.0f", order.totalAmount))")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 收货地址列表
struct AddressListView: View {
    @EnvironmentObject var addressManager: AddressManager
    @State private var showAddAddress = false

    var body: some View {
        Group {
            if addressManager.addresses.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "mappin")
                        .font(.system(size: 50))
                        .foregroundColor(Color.gray.opacity(0.5))
                    Text("暂无收货地址")
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(addressManager.addresses) { address in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(address.name)
                                    .fontWeight(.medium)
                                Text(address.phone)
                                    .foregroundColor(.secondary)
                                if address.isDefault {
                                    Text("默认")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                }
                            }
                            Text(address.fullAddress)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        addressManager.removeAddress(at: offsets)
                    }
                }
            }
        }
        .navigationBarTitle("收货地址", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            showAddAddress = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showAddAddress) {
            NavigationView {
                AddAddressView { newAddress in
                    addressManager.addAddress(newAddress)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(addressManager)
        }
    }
}

// MARK: - 新增收货地址
struct AddAddressView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var name = ""
    @State private var phone = ""
    @State private var province = ""
    @State private var city = ""
    @State private var district = ""
    @State private var detail = ""
    @State private var showRegionPicker = false
    @State private var showError = false
    @State private var errorMessage = ""

    var onSave: (Address) -> Void

    private var regionDisplay: String {
        if province.isEmpty { return "请选择" }
        return [province, city, district].filter { !$0.isEmpty }.joined(separator: " ")
    }

    private var phoneBinding: Binding<String> {
        Binding(get: { phone }, set: { newValue in
            let filtered = newValue.filter { $0.isNumber }
            phone = String(filtered.prefix(11))
        })
    }

    private var isValidPhone: Bool {
        let pattern = "^1[3-9]\\d{9}$"
        return phone.range(of: pattern, options: .regularExpression) != nil
    }

    var body: some View {
        Form {
            Section(header: Text("收货人信息")) {
                TextField("收货人姓名", text: $name)
                TextField("手机号码", text: phoneBinding)
                    .keyboardType(.phonePad)
            }

            Section(header: Text("收货地址")) {
                Button {
                    showRegionPicker = true
                } label: {
                    HStack {
                        Text("所在地区")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(regionDisplay)
                            .foregroundColor(province.isEmpty ? .secondary : .primary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                TextField("详细地址", text: $detail)
            }
        }
        .navigationBarTitle("新增地址", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            },
            trailing: Button("保存") {
                if !isValidPhone {
                    errorMessage = "请输入正确的11位格式手机号（以1开头）"
                    showError = true
                    return
                }
                let address = Address(name: name, phone: phone, province: province, city: city, district: district, detail: detail, isDefault: false)
                onSave(address)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(name.isEmpty || phone.count != 11 || province.isEmpty || city.isEmpty || district.isEmpty || detail.isEmpty)
        )
        .sheet(isPresented: $showRegionPicker) {
            RegionPickerView(province: $province, city: $city, district: $district)
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("格式错误"),
                message: Text(errorMessage),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}

// MARK: - 省市区选择器
struct RegionPickerView: View {
    @Binding var province: String
    @Binding var city: String
    @Binding var district: String
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedProvinceIndex: Int = 0
    @State private var selectedCityIndex: Int = 0
    @State private var selectedDistrictIndex: Int = 0

    private var provinces: [Region] { RegionData.provinces }
    private var cities: [City] {
        guard selectedProvinceIndex < provinces.count else { return [] }
        return provinces[selectedProvinceIndex].cities
    }
    private var districts: [String] {
        guard selectedCityIndex < cities.count else { return [] }
        return cities[selectedCityIndex].districts
    }

    private var provinceBinding: Binding<Int> {
        Binding(
            get: { selectedProvinceIndex },
            set: { newValue in
                selectedProvinceIndex = newValue
                selectedCityIndex = 0
                selectedDistrictIndex = 0
            }
        )
    }

    private var cityBinding: Binding<Int> {
        Binding(
            get: { selectedCityIndex },
            set: { newValue in
                selectedCityIndex = newValue
                selectedDistrictIndex = 0
            }
        )
    }

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                Picker("省份", selection: provinceBinding) {
                    ForEach(0..<provinces.count, id: \.self) { index in
                        Text(provinces[index].name).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("城市", selection: cityBinding) {
                    ForEach(0..<cities.count, id: \.self) { index in
                        Text(cities[index].name).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("区县", selection: $selectedDistrictIndex) {
                    ForEach(0..<districts.count, id: \.self) { index in
                        Text(districts[index]).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .padding()
            .navigationBarTitle("选择地区", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("确定") {
                    if selectedProvinceIndex < provinces.count {
                        province = provinces[selectedProvinceIndex].name
                    }
                    if selectedCityIndex < cities.count {
                        city = cities[selectedCityIndex].name
                    }
                    if selectedDistrictIndex < districts.count {
                        district = districts[selectedDistrictIndex]
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                if let pIdx = provinces.firstIndex(where: { $0.name == province }) {
                    selectedProvinceIndex = pIdx
                    if let cIdx = provinces[pIdx].cities.firstIndex(where: { $0.name == city }) {
                        selectedCityIndex = cIdx
                        if let dIdx = provinces[pIdx].cities[cIdx].districts.firstIndex(of: district) {
                            selectedDistrictIndex = dIdx
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - 自定义不透明警告弹窗
struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButtonText: String
    let primaryAction: () -> Void
    let secondaryButtonText: String
    let secondaryAction: () -> Void
    var isDestructive: Bool = false

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            HStack(spacing: 12) {
                Button(action: primaryAction) {
                    Text(primaryButtonText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: secondaryAction) {
                    Text(secondaryButtonText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDestructive ? .red : .blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 300)
        .background(
            Color(.systemBackground)
                .opacity(0.98) // 实色卡片背景，不再过于透光
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.18), radius: 25, x: 0, y: 12)
        .transition(.scale.combined(with: .opacity))
    }
}
