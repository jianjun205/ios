//
//  ContentView.swift
//  zuhao004
//
//  Created by andy 正道 on 2026/6/5.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var store: EventStore
    @State private var selectedTab = 0
    @State private var hasAgreedToPrivacy = UserDefaults.standard.bool(forKey: "hasAgreedToPrivacy")
    @State private var showPrivacyBlockAlert = false
    
    var body: some View {
        ZStack {
            if hasAgreedToPrivacy {
                TabView(selection: $selectedTab) {
                    HomeListView()
                        .tabItem {
                            Image(systemName: "clock")
                            Text("倒计时")
                        }
                        .tag(0)
                    
                    MyCalendarView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("日历")
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("设置")
                        }
                        .tag(2)
                }
            } else {
                // 首次启动强制隐私同意遮罩
                PrivacyConsentView(onAgree: {
                    UserDefaults.standard.set(true, forKey: "hasAgreedToPrivacy")
                    withAnimation {
                        hasAgreedToPrivacy = true
                    }
                }, onDisagree: {
                    showPrivacyBlockAlert = true
                })
                .alert(isPresented: $showPrivacyBlockAlert) {
                    Alert(
                        title: Text("隐私保护知情"),
                        message: Text("为了保证您的隐私安全，本应用完全采用离线本机存储来记录纪念日文字及图片。我们需要您阅览并同意此知情条款方可开始使用本App。"),
                        dismissButton: .default(Text("好的，我再看看"))
                    )
                }
            }
        }
    }
}

// MARK: - 辅助：获取分类专属颜色
func getCategoryColor(_ category: EventCategory) -> Color {
    switch category {
    case .family: return .blue
    case .love: return .pink
    case .work: return .orange
    case .birthday: return .purple
    case .custom: return Color(red: 17/255, green: 153/255, blue: 142/255) // teal
    }
}

// MARK: - 首页：倒计时列表视图
struct HomeListView: View {
    @EnvironmentObject var store: EventStore
    @State private var searchText = ""
    @State private var selectedCategoryFilter: EventCategory? = nil
    @State private var isShowingAddSheet = false
    
    // 按天数和是否未来科学排序
    var filteredEvents: [Event] {
        var list = store.events
        
        // 搜索名字/备注
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.note.localizedCaseInsensitiveContains(searchText) }
        }
        
        // 分类检索过滤
        if let filter = selectedCategoryFilter {
            list = list.filter { $0.category == filter }
        }
        
        // 排序规则：
        // 1. 先算各事件的剩余天数。我们在 items 中，未到期/今日发生的（daysCalculation().isFuture = true）
        //    按剩余天数升序。
        // 2. 对于已过去的事件（daysCalculation().isFuture = false）
        //    按已过去天数降序/升序或排在其后。为了能完美查看：我们将未发生的排在前面（按天数从小到大），已发生的排在后面（按已过去天数从小到大）。
        return list.sorted { (e1, e2) -> Bool in
            let calc1 = e1.daysCalculation()
            let calc2 = e2.daysCalculation()
            
            if calc1.isFuture && !calc2.isFuture {
                return true // 未发生的排在前面
            } else if !calc1.isFuture && calc2.isFuture {
                return false
            } else {
                // 相同类型，按天数绝对值排序
                return calc1.days < calc2.days
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶端搜索框
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("搜索纪念日、备注...", text: $searchText)
                            .foregroundColor(.primary)
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    
                    if !searchText.isEmpty {
                        Button("取消") {
                            searchText = ""
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // 顶部分类滑动快轴
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: {
                            selectedCategoryFilter = nil
                        }) {
                            Text("全部")
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategoryFilter == nil ? Color.accentColor : Color(.secondarySystemBackground))
                                .foregroundColor(selectedCategoryFilter == nil ? .white : .primary)
                                .cornerRadius(14)
                        }
                        
                        ForEach(EventCategory.allCases) { cat in
                            Button(action: {
                                selectedCategoryFilter = cat
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: cat.icon)
                                    Text(cat == .custom ? "自定义" : cat.rawValue)
                                }
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategoryFilter == cat ? getCategoryColor(cat) : Color(.secondarySystemBackground))
                                .foregroundColor(selectedCategoryFilter == cat ? .white : .primary)
                                .cornerRadius(14)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                
                // 事件列表或空占位图
                if filteredEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(searchText.isEmpty ? "还没有记录纪念日" : "未找到搜索结果")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(searchText.isEmpty ? "点击右上角“+”号添加您的首个本地纪念日" : "换个搜索词试试吧")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventRow(event: event)
                            }
                        }
                        .onDelete(perform: deleteFromList)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("本地纪念日", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    isShowingAddSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding(4)
                }
            )
            .sheet(isPresented: $isShowingAddSheet) {
                EventAddEditView()
                    .environmentObject(store)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteFromList(offsets: IndexSet) {
        // 由于是从 filteredEvents 删除，需要找到在 store 对应的事件
        for index in offsets {
            let targetEvent = filteredEvents[index]
            store.deleteEvent(targetEvent)
        }
    }
}

// MARK: - 单行卡片 Row (iOS 13+ 适配)
struct EventRow: View {
    let event: Event
    
    var body: some View {
        let calc = event.daysCalculation()
        return HStack(spacing: 12) {
            // 左边分类高亮色块圈
            ZStack {
                Circle()
                    .fill(getCategoryColor(event.category).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: event.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(getCategoryColor(event.category))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    if event.isYearlyRepeat {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
                
                Text(formatDate(event.date))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                if !event.note.isEmpty {
                    Text(event.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 右边醒目大字
            VStack(alignment: .trailing, spacing: 2) {
                if calc.days == 0 {
                    Text("今天")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                    Text("🎉 到了")
                        .font(.system(size: 10))
                        .foregroundColor(.pink)
                } else if calc.isFuture {
                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                        Text("\(calc.days)")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(getCategoryColor(event.category))
                        Text("天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("倒计时")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                } else {
                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                        Text("\(calc.days)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        Text("天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("已过去")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 纪念日详情页面
struct EventDetailView: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.presentationMode) var presentationMode
    let event: Event
    
    @State private var isShowingEditSheet = false
    @State private var loadedImage: UIImage? = nil
    
    var body: some View {
        let calc = event.daysCalculation()
        let catColor = getCategoryColor(event.category)
        
        return ScrollView {
            VStack(spacing: 20) {
                // 倒计时核心大卡片
                VStack(spacing: 12) {
                    Text(event.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: event.category.icon)
                        Text(event.displayCategoryName)
                        if event.isYearlyRepeat {
                            Text("· 每年重复")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(catColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(catColor.opacity(0.12))
                    .cornerRadius(12)
                    
                    Divider().padding(.horizontal)
                    
                    if calc.days == 0 {
                        Text("就是今天！")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.pink)
                        Text("祝您在这快乐的一天诸事顺意 🎉")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 4) {
                            Text("\(calc.days)")
                                .font(.system(size: 64, weight: .heavy, design: .rounded))
                                .foregroundColor(calc.isFuture ? catColor : .gray)
                            
                            Text(calc.isFuture ? "距离大纪念日还有今天起算的天数" : "距离该时刻已悄然流逝")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(calc.isFuture ? "倒计时天" : "累计纪念天")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(calc.isFuture ? .primary : .secondary)
                        }
                    }
                    
                    Text("目标发生日: \(formatDate(event.date))")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // 备注大框卡片
                if !event.note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(catColor)
                            Text("事件备忘")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        Text(event.note)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // 本地关联的私密照片 (如果有)
                if let imgFileName = event.imageFileName, let img = store.loadImage(fileName: imgFileName) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(catColor)
                            Text("本地私密附图")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                            .shadow(radius: 4)
                        
                        Text("🔒 图片完全物理保存在您的本机沙盒中，未加载第三方同步，不占用任何云存储。")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // 通知提醒指示
                HStack(spacing: 12) {
                    Image(systemName: event.isNotificationEnabled ? "bell.badge.fill" : "bell.slash")
                        .foregroundColor(event.isNotificationEnabled ? .orange : .gray)
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.isNotificationEnabled ? "本地消息提醒已开启" : "本事件未开启通知")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        if event.isNotificationEnabled {
                            let textOffset = event.notificationTimeOffset == 0 ? "当天 (09:00)" : "提前 \(event.notificationTimeOffset) 天"
                            Text("将在发生日 \(textOffset) 通过系统通道发送通知")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // 删除动作
                Button(action: {
                    store.deleteEvent(event)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("删除该条纪念日记录")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitle("纪念日详情", displayMode: .inline)
        .navigationBarItems(trailing:
            Button("编辑") {
                isShowingEditSheet = true
            }
        )
        .sheet(isPresented: $isShowingEditSheet) {
            EventAddEditView(editingEvent: event)
                .environmentObject(store)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 纪念日新增/编辑页面
struct EventAddEditView: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.presentationMode) var presentationMode
    
    var editingEvent: Event? = nil
    
    @State private var title: String
    @State private var date: Date
    @State private var note: String
    @State private var category: EventCategory
    @State private var customCategoryName: String
    @State private var isNotificationEnabled: Bool
    @State private var notificationTimeOffset: Int
    @State private var isYearlyRepeat: Bool
    @State private var selectedImage: UIImage?
    
    @State private var isImagePickerPresented = false
    @State private var showingCustomCategoryGuide = false
    
    init(editingEvent: Event? = nil, initialDate: Date = Date()) {
        self.editingEvent = editingEvent
        if let editing = editingEvent {
            _title = State(initialValue: editing.title)
            _date = State(initialValue: editing.date)
            _note = State(initialValue: editing.note)
            _category = State(initialValue: editing.category)
            _customCategoryName = State(initialValue: editing.customCategoryName ?? "")
            _isNotificationEnabled = State(initialValue: editing.isNotificationEnabled)
            _notificationTimeOffset = State(initialValue: editing.notificationTimeOffset)
            _isYearlyRepeat = State(initialValue: editing.isYearlyRepeat)
            _selectedImage = State(initialValue: nil)
        } else {
            _title = State(initialValue: "")
            _date = State(initialValue: initialDate)
            _note = State(initialValue: "")
            _category = State(initialValue: .family)
            _customCategoryName = State(initialValue: "")
            _isNotificationEnabled = State(initialValue: false)
            _notificationTimeOffset = State(initialValue: 0)
            _isYearlyRepeat = State(initialValue: false)
            _selectedImage = State(initialValue: nil)
        }
    }
    
    var isEditMode: Bool {
        editingEvent != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("纪念日基本内容 (必填)")) {
                    TextField("事件名称，如：妈妈生日、恋爱纪念日...", text: $title)
                    
                    DatePicker("发生日期", selection: $date, displayedComponents: .date)
                    
                    Toggle(isOn: $isYearlyRepeat) {
                        HStack {
                            Image(systemName: "repeat")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("每年重复")
                                    .font(.subheadline)
                                Text("开启后，倒计时次年将自动重计日期")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("分类归属")) {
                    Picker("挑选所属类别", selection: $category) {
                        ForEach(EventCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if category == .custom {
                        TextField("写一个您的个性化分类 (如：开学、理财...)", text: $customCategoryName)
                    }
                }
                
                Section(header: Text("本地附图 (离线、安全、不可批量)")) {
                    HStack {
                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                            
                            Button(action: {
                                selectedImage = nil
                            }) {
                                Text("移除照片")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Button(action: {
                                    isImagePickerPresented = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("添加本地私密相册图")
                                    }
                                    .foregroundColor(.accentColor)
                                }
                                Text("图片绝不联网，仅在您手机物理沙盒中归档。单个事件仅能选一张。")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("本地消息提醒规则 (不使用网络)")) {
                    Toggle(isOn: $isNotificationEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("倒计时到期提醒")
                                    .font(.subheadline)
                                Text("到期当天自动在手机弹出提醒通知")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if isNotificationEnabled {
                        Picker("提前提醒时间", selection: $notificationTimeOffset) {
                            Text("当天提醒").tag(0)
                            Text("提前1天提醒").tag(1)
                            Text("提前3天提醒").tag(3)
                            Text("提前1周提醒").tag(7)
                        }
                    }
                }
                
                Section(header: Text("附加备注说明")) {
                    TextField("补充一些文字备注，如地点、回忆点或需要准备的礼物...", text: $note)
                }
            }
            .navigationBarTitle(isEditMode ? "编辑纪念日" : "新增纪念日", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveAction()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                if let editing = editingEvent {
                    title = editing.title
                    date = editing.date
                    note = editing.note
                    category = editing.category
                    customCategoryName = editing.customCategoryName ?? ""
                    isNotificationEnabled = editing.isNotificationEnabled
                    notificationTimeOffset = editing.notificationTimeOffset
                    isYearlyRepeat = editing.isYearlyRepeat
                    if let imgFile = editing.imageFileName {
                        selectedImage = store.loadImage(fileName: imgFile)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func saveAction() {
        let targetCustomName = category == .custom ? (customCategoryName.isEmpty ? "自定义" : customCategoryName) : nil
        
        if let editing = editingEvent {
            // 编辑已有事件
            let updated = Event(
                id: editing.id,
                title: title,
                date: date,
                note: note,
                category: category,
                customCategoryName: targetCustomName,
                isNotificationEnabled: isNotificationEnabled,
                notificationTimeOffset: notificationTimeOffset,
                imageFileName: editing.imageFileName,
                isYearlyRepeat: isYearlyRepeat
            )
            
            // 如果用户关闭了通知，则我们顺带取消
            if !isNotificationEnabled {
                store.cancelNotification(for: editing)
            }
            
            store.updateEvent(updated, image: selectedImage)
        } else {
            // 新建一事件
            let newObj = Event(
                id: UUID(),
                title: title,
                date: date,
                note: note,
                category: category,
                customCategoryName: targetCustomName,
                isNotificationEnabled: isNotificationEnabled,
                notificationTimeOffset: notificationTimeOffset,
                imageFileName: nil,
                isYearlyRepeat: isYearlyRepeat
            )
            
            // 提醒权限请求辅助：如果开启了通知
            if isNotificationEnabled {
                store.requestNotificationPermission { granted in
                    // 仅获取权限，内部不作侵入式强退
                }
            }
            
            store.addEvent(newObj, image: selectedImage)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - 精致纯本土月历日历
struct MyCalendarView: View {
    @EnvironmentObject var store: EventStore
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var isShowingAddSheet = false
    @State private var showingDetailEvent: Event? = nil
    
    private let calendar = Calendar.current
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    
    // 筛选选中日期当天的所有本地事件
    var eventsOnSelectedDate: [Event] {
        return store.events.filter { event in
            if event.isYearlyRepeat {
                // 每年重复：只要选择的月和日对上
                let eventComp = calendar.dateComponents([.month, .day], from: event.date)
                let selectedComp = calendar.dateComponents([.month, .day], from: selectedDate)
                return eventComp.month == selectedComp.month && eventComp.day == selectedComp.day
            } else {
                // 一次性：精确对比年月日
                return calendar.isDate(event.date, inSameDayAs: selectedDate)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 月份导航切换栏
                    HStack {
                        Button(action: {
                            changeMonth(by: -1)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20))
                                .padding(10)
                        }
                        
                        Spacer()
                        
                        Text(formatMonthYear(currentMonth))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            changeMonth(by: 1)
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .padding(10)
                        }
                    }
                    .padding(.horizontal)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // 星期表头
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 6x7 纯 SwiftUI 兼容月历方格网
                    VStack(spacing: 10) {
                        ForEach(0..<6, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<7, id: \.self) { col in
                                    let index = row * 7 + col
                                    let datesList = daysInMonth()
                                    
                                    if index < datesList.count, let date = datesList[index] {
                                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                                        let isToday = calendar.isDateInToday(date)
                                        let dayEvents = eventsForDate(date)
                                        
                                        Button(action: {
                                            selectedDate = date
                                        }) {
                                            VStack(spacing: 2) {
                                                Text("\(calendar.component(.day, from: date))")
                                                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                                                    .foregroundColor(isSelected ? .white : (isToday ? .pink : .primary))
                                                    .frame(width: 34, height: 34)
                                                    .background(isSelected ? Color.accentColor : (isToday ? Color.pink.opacity(0.1) : Color.clear))
                                                    .clipShape(Circle())
                                                
                                                // 格子小彩点标识 (如有事件)
                                                HStack(spacing: 3) {
                                                    if !dayEvents.isEmpty {
                                                        ForEach(dayEvents.prefix(3)) { ev in
                                                            Circle()
                                                                .fill(getCategoryColor(ev.category))
                                                                .frame(width: 5, height: 5)
                                                        }
                                                    } else {
                                                        Spacer().frame(height: 5)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        // 填充上月/下月非本月区域留白
                                        Text("")
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 41)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // 下方当天纪念日卡片面板
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.pink)
                            Text("\(formatShortDate(selectedDate)) 记录")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if eventsOnSelectedDate.isEmpty {
                            VStack(spacing: 8) {
                                Text("本日尚未录入生活纪念日")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    isShowingAddSheet = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle")
                                        Text("添加这一天的重要节点")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.accentColor)
                                    .cornerRadius(20)
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            ForEach(eventsOnSelectedDate) { ev in
                                Button(action: {
                                    showingDetailEvent = ev
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Image(systemName: ev.category.icon)
                                                    .foregroundColor(getCategoryColor(ev.category))
                                                Text(ev.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                            }
                                            if !ev.note.isEmpty {
                                                Text(ev.note)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("日历大盘", displayMode: .inline)
            .sheet(isPresented: $isShowingAddSheet) {
                EventAddEditView(initialDate: selectedDate)
                    .environmentObject(store)
            }
            .sheet(item: $showingDetailEvent) { ev in
                NavigationView {
                    EventDetailView(event: ev)
                        .environmentObject(store)
                        .navigationBarItems(leading: Button("关闭") {
                            showingDetailEvent = nil
                        })
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func changeMonth(by amount: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
    
    // 获取当月42天的数据源(包含上下月补正空白)
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        let startOfMonth = monthInterval.start
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        
        var days: [Date?] = []
        
        // 填充上月空白
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // 提取本月范围
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return days }
        let numberOfDays = range.count
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // 填充后续至42格
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        return store.events.filter { event in
            if event.isYearlyRepeat {
                let evM = calendar.component(.month, from: event.date)
                let evD = calendar.component(.day, from: event.date)
                let dM = calendar.component(.month, from: date)
                let dD = calendar.component(.day, from: date)
                return evM == dM && evD == dD
            } else {
                return calendar.isDate(event.date, inSameDayAs: date)
            }
        }
    }
}

// MARK: - 设置中心
struct SettingsView: View {
    @EnvironmentObject var store: EventStore
    @State private var isShowingPrivacySheet = false
    @State private var isShowingAboutSheet = false
    @State private var showingClearAllAlert = false
    
    // 导入和导出状态管理
    @State private var isShowingExportShareSheet = false
    @State private var exportURL: URL? = nil
    
    @State private var isShowingImportAlert = false
    @State private var isShowingClipboardError = false
    @State private var isShowingImportSuccess = false
    @State private var importMessage = ""
    
    // 深浅色模式手动切换（由于iOS13有.environment(\.colorScheme)，我们可以让用户自主选择跟随系统，或由开发者设置。这里在设置里提供一个模拟说明）
    @State private var followSystemTheme = true
    @State private var isDarkModeLocal = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("本地消息提醒设置")) {
                    Toggle(isOn: $store.isAppWideNotificationEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("开启倒计时铃提醒推送")
                                    .font(.subheadline)
                                Text("若因未同意授权，请先往“设置-通知”开启")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Button(action: {
                        sendNotificationTest()
                    }) {
                        HStack {
                            Image(systemName: "bell.circle")
                            Text("向本机发送一条5秒后的测试提醒")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
                
                Section(header: Text("安全数据包管理 (全断网、极保密)")) {
                    Button(action: {
                        doExport()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                            Text("手动备份数据导出 (保存到本机文件)")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        isShowingImportAlert = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.blue)
                            Text("粘贴剪贴板备份数据导入")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        showingClearAllAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("一键抹除全部记录 (恢复初装状态)")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("关于纪念日 & 隐私保障")) {
                    Button(action: {
                        isShowingPrivacySheet = true
                    }) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(Color(red: 0, green: 0.5, blue: 0.5))
                            Text("核心隐私政策及安全不联网规范")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        isShowingAboutSheet = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                            Text("关于我们与App自律宗旨")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationBarTitle("应用配置", displayMode: .inline)
            .sheet(isPresented: $isShowingPrivacySheet) {
                NavigationView {
                    ScrollView {
                        PrivacyDocView()
                    }
                    .navigationBarTitle("隐私与合规规范详情", displayMode: .inline)
                    .navigationBarItems(leading: Button("关闭") {
                        isShowingPrivacySheet = false
                    })
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .sheet(isPresented: $isShowingAboutSheet) {
                NavigationView {
                    AboutUsView()
                        .navigationBarTitle("关于纪念工坊", displayMode: .inline)
                        .navigationBarItems(leading: Button("关闭") {
                            isShowingAboutSheet = false
                        })
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .sheet(isPresented: $isShowingExportShareSheet, content: {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            })
            .alert(isPresented: $showingClearAllAlert) {
                Alert(
                    title: Text("确定清空全部数据吗？"),
                    message: Text("此操作将永久彻底地抹杀并粉碎您手机里的所有本地纪念日数据日志、备注内容以及导入的物理多重相册照片，无法通过任何云端机制找回，请再次谨慎确认。"),
                    primaryButton: .destructive(Text("永久抹除")) {
                        store.clearAllData()
                    },
                    secondaryButton: .cancel(Text("保留"))
                )
            }
            // 剪贴板导入确认 Alert
            .alert(isPresented: $isShowingImportAlert) {
                Alert(
                    title: Text("从粘贴板导入备份"),
                    message: Text("点击确定后，本App将对剪贴板的内容进行检测。如果识别到先前导出的数据包密钥，将秒速补充、合并入现有的记录中。"),
                    primaryButton: .default(Text("确认加载")) {
                        tryImportFromClipboard()
                    },
                    secondaryButton: .cancel(Text("退出"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // 成功反馈
        .background(
            EmptyView()
                .alert(isPresented: $isShowingImportSuccess) {
                    Alert(
                        title: Text("成功"),
                        message: Text(importMessage),
                        dismissButton: .default(Text("好的"))
                    )
                }
        )
        // 失败反馈
        .background(
            EmptyView()
                .alert(isPresented: $isShowingClipboardError) {
                    Alert(
                        title: Text("导入失败"),
                        message: Text("在我们未能从您的剪切板找到合法的、格式正确的本App备份序列化数据，请手动复制您之前备份导出的备份文件文本内容后重新点击。"),
                        dismissButton: .default(Text("明白"))
                    )
                }
        )
    }
    
    // 执行数据导出
    private func doExport() {
        if let file = store.exportEventsToJSON() {
            self.exportURL = file
            self.isShowingExportShareSheet = true
        }
    }
    
    // 执行剪贴板导入
    private func tryImportFromClipboard() {
        if let text = UIPasteboard.general.string, !text.isEmpty {
            // 我们写个容错处理，看是直接是JSON、或者是从文件临时备份导入。
            // 考虑有些用户可能是通过隔空投送把 events.json 导出并作为文本复制了
            guard let jsonData = text.data(using: .utf8) else {
                isShowingClipboardError = true
                return
            }
            
            // 试试解析
            do {
                let imported = try JSONDecoder().decode([Event].self, from: jsonData)
                if imported.isEmpty {
                    isShowingClipboardError = true
                    return
                }
                
                var count = 0
                for event in imported {
                    if !store.events.contains(where: { $0.id == event.id }) {
                        store.events.append(event)
                        count += 1
                    }
                }
                
                store.syncAllNotifications()
                self.importMessage = "已智能识别！成功零失误导入了 \(count) 条纪念日历史归档到本机中！"
                self.isShowingImportSuccess = true
            } catch {
                isShowingClipboardError = true
            }
        } else {
            isShowingClipboardError = true
        }
    }
    
    // 发送一条临时本地测试通知
    private func sendNotificationTest() {
        store.requestNotificationPermission { granted in
            guard granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "纪念日模拟测试提醒 🎉"
            content.body = "恭喜，您的系统本地推送授权通路一切正常，未产生任何后台网络交互，100% 物理级私密。"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "TestLocalNotif", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

// MARK: - 包装 iOS 13 UIKit 共享
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 隐私声明卡片视图 (App Store 5.1 专业规避)
struct PrivacyDocView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Group {
                Text("安全与隐私基本准则（白皮书）")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 6)
                
                Text("1. 数据完全『脱网离线』存储")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("本软件在设计之初就确立了“绝不接触、不存储用户任何文字及图片”的核心理念。一切应用数据、分类属性、配置项、通知延迟，全部通过系统的 Codable 机制固化在您个人的 iPhone 沙盒目录中的 `events.json` 物理文件上。应用甚至未申请网络套接字端口（Network Socket）以及任何联机域名。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Group {
                Text("2. 图片『零批量、全物理离线本地化』机制")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("关于相册存图：应用绝无批量网络图或图床服务。您为纪念日分配的背景照片，仅能点击时通过 iOS 控制中心在您手机的「本地相册」中挑选。被选定的照片会被单张克隆（命名为 ID.jpg）存放在沙盒文档下，其他照片绝不会被程序扫描。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Group {
                Text("3. 严格遵循 5.1 规则，不集成追踪 SDK")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("我们拒绝在应用内集成目前市场上多见的包括：广告分发、热度埋点、用户设备画、活跃度监控等第三方 SDK (例如友盟、听云、AdMob 等)。没有任何数据共享给第三方商业机构。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Group {
                Text("4. 纯净全功能免费承诺")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("本软件的所有功能均完全向用户免费开放，零内购、零广告、零收费门槛。包括无限添加纪念日、自定义分类及其命名、本地私密相册、倒计时到期提醒等，皆为终身免费使用，让您享受最安静、最放心的离线时光记录体验。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        }
        .padding()
    }
}

// MARK: - 关于我们视图
struct AboutUsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 20)
            
            Image(systemName: "hourglass")
                .font(.system(size: 72))
                .foregroundColor(.accentColor)
                .padding()
            
            Text("纪念日计时工坊")
                .font(.title)
                .fontWeight(.bold)
            
            Text("最低支持 iOS 13 / 版本 1.0.0")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("我们是一个秉持“化繁为简、数据归还给个人”理念的独立个人硬件与效率工具工坊。")
                Text("本团队誓不在此应用中塞入广告。如果您用着觉得省心，可以购买高级版或者向熟人推荐我们，这就是对无广告、不作恶工具最好的鼓舞和认同！")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Text("Copyright © 2026 Memorial Workshop. All Rights Reserved.")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
    }
}

// MARK: - 首次使用知情同意遮罩 UI
struct PrivacyConsentView: View {
    var onAgree: () -> Void
    var onDisagree: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                        .padding(.top, 40)
                    
                    Text("纪念日倒计时记事薄\n隐私保护与知情同意书")
                        .font(.title)
                        .fontWeight(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("本App专为追求私密、厌恶广告和社交追踪的高阶用户打造。在您体验之前，请务必了解以下知情书：")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(alignment: .top) {
                            Text("🔒").bold()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("没有云端服务器，全部离线存储")
                                    .fontWeight(.bold)
                                Text("您的纪念日标题、备注、分类、图片，只会以加密/结构化形式保存在您的本机固态存储上，软件没有后台网络端口、不产生任何入站/出站连接流量，彻底杜绝数据泄露。")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Text("🛡️").bold()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("零用户追踪，零广告 SDK")
                                    .fontWeight(.bold)
                                Text("拒绝接入友盟、Firebase、AdMob、Facebook等任何数据埋点或行为画像收集工具。您的隐私，连我们自己都不知道。")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Text("🎨").bold()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("相册与通知独立授权")
                                    .fontWeight(.bold)
                                Text("当您添加照片时，系统会弹出相册访问提示，我们仅对单张照片进行拷贝；本地推送（UNNotification）在添加完后由系统引擎分发，绝不包含外部广告营销推送。")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Text("�").bold()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("完全免费，无任何内购和广告")
                                    .fontWeight(.bold)
                                Text("我们绝不设置任何付费门槛或隐藏弹窗，所有功能（如无限自定义分类、本地相册等）全部开放，终身完全免费。只为给您提供纯粹、放心的工具。")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .font(.system(size: 13))
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            // 底部操作大按钮区
            VStack(spacing: 12) {
                Button(action: {
                    onAgree()
                }) {
                    Text("同意以上条款，开始记录时光")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button(action: {
                    onDisagree()
                }) {
                    Text("不同意并退出")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 24)
            }
            .padding(.top, 10)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - 兼容 iOS 13 的 UIKit 相册选择器包装
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

