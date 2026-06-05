//
//  Item.swift
//  zuhao004
//
//  Created by andy 正道 on 2026/6/5.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import UserNotifications

// MARK: - 分类枚举
enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case family = "亲情"
    case love = "爱情"
    case work = "工作"
    case birthday = "生日"
    case custom = "自定义"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .family: return "house.fill"
        case .love: return "heart.fill"
        case .work: return "briefcase.fill"
        case .birthday: return "gift.fill"
        case .custom: return "star.fill"
        }
    }
    
    var colorName: String {
        switch self {
        case .family: return "blue"
        case .love: return "pink"
        case .work: return "orange"
        case .birthday: return "purple"
        case .custom: return "teal"
        }
    }
}

// MARK: - 纪念日模型
struct Event: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var note: String
    var category: EventCategory
    var customCategoryName: String? // 自定义分类的个性化命名
    var isNotificationEnabled: Bool = false
    var notificationTimeOffset: Int = 0 // 提前几天提醒：0=当天, 1=提前1天, 3=提前3天
    var imageFileName: String? // 本地存储的关联图片文件名（UUID.jpg）
    var isYearlyRepeat: Bool = false // 是否每年重复（如生日、节日）

    // 格式化分类显示名
    var displayCategoryName: String {
        if category == .custom {
            return customCategoryName ?? "自定义"
        }
        return category.rawValue
    }
    
    // 计算剩余天数及相关状态
    func daysCalculation() -> (days: Int, isFuture: Bool, text: String) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let eventDay = calendar.startOfDay(for: self.date)
        
        if !self.isYearlyRepeat {
            // 一次性事件
            let components = calendar.dateComponents([.day], from: today, to: eventDay)
            let diff = components.day ?? 0
            if diff == 0 {
                return (0, true, "就在今天")
            } else if diff > 0 {
                return (diff, true, "还有 \(diff) 天")
            } else {
                return (abs(diff), false, "已过去 \(abs(diff)) 天")
            }
        } else {
            // 每年重复性节日
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            let eventComponents = calendar.dateComponents([.month, .day], from: eventDay)
            
            var nextDateComponents = DateComponents()
            nextDateComponents.month = eventComponents.month
            nextDateComponents.day = eventComponents.day
            nextDateComponents.year = todayComponents.year
            
            guard let nextDateInThisYear = calendar.date(from: nextDateComponents) else {
                return (0, true, "计算错误")
            }
            
            let startOfNextDateInThisYear = calendar.startOfDay(for: nextDateInThisYear)
            
            if startOfNextDateInThisYear == today {
                return (0, true, "就在今天")
            } else if startOfNextDateInThisYear > today {
                let diff = calendar.dateComponents([.day], from: today, to: startOfNextDateInThisYear).day ?? 0
                return (diff, true, "还有 \(diff) 天")
            } else {
                // 当年的事件已经过去了，计算到明年的倒计时
                nextDateComponents.year = (todayComponents.year ?? 2026) + 1
                if let nextDateInNextYear = calendar.date(from: nextDateComponents) {
                    let startOfNextDateInNextYear = calendar.startOfDay(for: nextDateInNextYear)
                    let diff = calendar.dateComponents([.day], from: today, to: startOfNextDateInNextYear).day ?? 0
                    return (diff, true, "还有 \(diff) 天")
                }
                return (0, true, "计算错误")
            }
        }
    }
}

// MARK: - 数据持久化与事件管理中心
class EventStore: ObservableObject {
    static let shared = EventStore()
    
    @Published var events: [Event] = [] {
        didSet {
            saveEvents()
        }
    }
    
    @Published var isPremiumUnlocked: Bool = true
    
    @Published var isAppWideNotificationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAppWideNotificationEnabled, forKey: "isAppWideNotificationEnabled")
            syncAllNotifications()
        }
    }
    
    var imageCache = [String: UIImage]()
    
    private init() {
        self.isPremiumUnlocked = true
        // 默认开启全局消息提醒
        if UserDefaults.standard.object(forKey: "isAppWideNotificationEnabled") == nil {
            self.isAppWideNotificationEnabled = true
        } else {
            self.isAppWideNotificationEnabled = UserDefaults.standard.bool(forKey: "isAppWideNotificationEnabled")
        }
        loadEvents()
    }
    
    // MARK: - 路径辅助
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getEventsFilePath() -> URL {
        return getDocumentsDirectory().appendingPathComponent("events.json")
    }
    
    private func getImagesDirectory() -> URL {
        let url = getDocumentsDirectory().appendingPathComponent("images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    
    // MARK: - 持久化逻辑
    func loadEvents() {
        let path = getEventsFilePath()
        guard FileManager.default.fileExists(atPath: path.path) else {
            self.events = []
            return
        }
        do {
            let data = try Data(contentsOf: path)
            let decoded = try JSONDecoder().decode([Event].self, from: data)
            self.events = decoded
        } catch {
            print("加载纪念日数据失败: \(error)")
            self.events = []
        }
    }
    
    func saveEvents() {
        do {
            let data = try JSONEncoder().encode(events)
            try data.write(to: getEventsFilePath(), options: [.atomicWrite])
        } catch {
            print("保存纪念日数据失败: \(error)")
        }
    }
    
    // MARK: - 图片存储逻辑
    func saveImage(image: UIImage, forEventId id: UUID) -> String {
        let fileName = "\(id.uuidString).jpg"
        let path = getImagesDirectory().appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: path)
            imageCache[fileName] = image
        }
        return fileName
    }
    
    func loadImage(fileName: String) -> UIImage? {
        if let cached = imageCache[fileName] {
            return cached
        }
        let path = getImagesDirectory().appendingPathComponent(fileName)
        if let image = UIImage(contentsOfFile: path.path) {
            imageCache[fileName] = image
            return image
        }
        return nil
    }
    
    func deleteImage(fileName: String) {
        imageCache.removeValue(forKey: fileName)
        let path = getImagesDirectory().appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: path)
    }
    
    func clearAllImages() {
        imageCache.removeAll()
        let dir = getImagesDirectory()
        if let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
    
    // MARK: - 事件增删改逻辑
    func addEvent(_ event: Event, image: UIImage?) {
        var newEvent = event
        if let img = image {
            let fileName = saveImage(image: img, forEventId: event.id)
            newEvent.imageFileName = fileName
        }
        events.append(newEvent)
        if newEvent.isNotificationEnabled {
            scheduleNotification(for: newEvent)
        }
    }
    
    func updateEvent(_ event: Event, image: UIImage?) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        var updatedEvent = event
        
        // 处理图片：如果用户上传了新图，覆盖或创建；如果是nil但原有的不为nil，且用户没有指明删除，则保留旧图
        if let img = image {
            if let oldFile = events[index].imageFileName {
                deleteImage(fileName: oldFile)
            }
            let fileName = saveImage(image: img, forEventId: event.id)
            updatedEvent.imageFileName = fileName
        } else {
            // 保留原有图片
            updatedEvent.imageFileName = events[index].imageFileName
        }
        
        // 如果原本开启了通知，现在关闭了，取消
        cancelNotification(for: events[index])
        
        events[index] = updatedEvent
        
        if updatedEvent.isNotificationEnabled {
            scheduleNotification(for: updatedEvent)
        }
    }
    
    func deleteEvent(at offsets: IndexSet) {
        for index in offsets {
            let event = events[index]
            if let imgFile = event.imageFileName {
                deleteImage(fileName: imgFile)
            }
            cancelNotification(for: event)
        }
        events.remove(atOffsets: offsets)
    }
    
    func deleteEvent(_ event: Event) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        if let imgFile = event.imageFileName {
            deleteImage(fileName: imgFile)
        }
        cancelNotification(for: event)
        events.remove(at: index)
    }
    
    func clearAllData() {
        // 取消所有本地通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 删除所有物理图片
        clearAllImages()
        
        // 清空事件数组
        events.removeAll()
        
        // 清除持久化文件
        try? FileManager.default.removeItem(at: getEventsFilePath())
    }
    
    // MARK: - 导出与导入
    func exportEventsToJSON() -> URL? {
        let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("MyMemorialEvents_Backup.json")
        do {
            let data = try JSONEncoder().encode(events)
            try data.write(to: exportURL, options: [.atomicWrite])
            return exportURL
        } catch {
            print("导出事件数据失败: \(error)")
            return nil
        }
    }
    
    func importEventsFromJSON(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let imported = try JSONDecoder().decode([Event].self, from: data)
            
            // 我们采取合并的策略（基于 UUID 避重）
            var count = 0
            for event in imported {
                if !events.contains(where: { $0.id == event.id }) {
                    events.append(event)
                    count += 1
                }
            }
            // 重新同步一下所有通知
            syncAllNotifications()
            return true
        } catch {
            print("导入事件数据失败: \(error)")
            return false
        }
    }
    
    // MARK: - 本地通知控制
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotification(for event: Event) {
        guard isAppWideNotificationEnabled && event.isNotificationEnabled else { return }
        
        let content = UNMutableNotificationProvider()
        content.title = "纪念日到期提醒 🔔"
        content.body = "今天「\(event.title)」" + (event.note.isEmpty ? "到了！" : "。备注：\(event.note)")
        content.sound = .default
        
        let calendar = Calendar.current
        var targetDate = event.date
        
        // 提前天数逻辑比较
        if event.notificationTimeOffset > 0 {
            if let earlierDate = calendar.date(byAdding: .day, value: -event.notificationTimeOffset, to: event.date) {
                targetDate = earlierDate
            }
            content.body = "你的纪念日「\(event.title)」还有 \(event.notificationTimeOffset) 天就要到啦！"
        }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
        // 约定早上 09:00 进行推送提醒
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger: UNNotificationTrigger
        if event.isYearlyRepeat {
            // 每年重复，按月日触发
            let yearlyComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: calendar.date(from: dateComponents) ?? targetDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: yearlyComponents, repeats: true)
        } else {
            // 一次性
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let err = error {
                print("推送调度错误: \(err.localizedDescription)")
            }
        }
    }
    
    private func UNMutableNotificationProvider() -> UNMutableNotificationContent {
        return UNMutableNotificationContent()
    }
    
    func cancelNotification(for event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
    }
    
    func syncAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard isAppWideNotificationEnabled else { return }
        for event in events {
            if event.isNotificationEnabled {
                scheduleNotification(for: event)
            }
        }
    }
}

