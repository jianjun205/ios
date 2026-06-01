//
//  ContentView.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case modifiedDesc = "修改时间（较新优先）"
    case modifiedAsc = "修改时间（较旧优先）"
    case createdDesc = "创建时间（较新优先）"
    case titleAsc = "标题字意排序 (A-Z)"
    
    var id: String { self.rawValue }
}

struct ContentView: View {
    @ObservedObject var storage = NoteStorage.shared
    @ObservedObject var securityManager = SecurityManager.shared
    
    @State private var searchText = ""
    @State private var selectedSort: SortOption = .modifiedDesc
    @State private var showSettings = false
    @State private var showSortOptions = false
    
    // Filter and sort computation
    private var filteredNotes: [Note] {
        let searched = storage.notes.filter { note in
            if searchText.isEmpty { return true }
            return note.title.localizedCaseInsensitiveContains(searchText) ||
                   note.content.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedSort {
        case .modifiedDesc:
            return searched.sorted { $0.modifiedAt > $1.modifiedAt }
        case .modifiedAsc:
            return searched.sorted { $0.modifiedAt < $1.modifiedAt }
        case .createdDesc:
            return searched.sorted { $0.createdAt > $1.createdAt }
        case .titleAsc:
            return searched.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        }
    }
    
    private var pinnedNotes: [Note] {
        filteredNotes.filter { $0.isPinned }
    }
    
    private var regularNotes: [Note] {
        filteredNotes.filter { !$0.isPinned }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Stat Information block
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("我的记事本")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text(storage.notes.isEmpty ? "轻触右下角书写第一篇笔记" : "共 \(storage.notes.count) 篇本地笔记")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Gear settings buttons
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                            .padding(10)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Elegant Search Bar (iOS 13+ support)
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 15, weight: .bold))
                        TextField("搜索标题或内容...", text: $searchText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Sort options trigger button
                    Button(action: { showSortOptions = true }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.accentColor)
                            .padding(11)
                            .background(Color.accentColor.opacity(0.12))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Active Sort Banner (if chosen non-default)
                if selectedSort != .modifiedDesc {
                    HStack {
                        Text("排序规则：\(selectedSort.rawValue)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.12))
                            .cornerRadius(6)
                        Spacer()
                        Button("重置排序") {
                            selectedSort = .modifiedDesc
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                
                // Content Switcher
                if filteredNotes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 64))
                            .foregroundColor(.accentColor.opacity(0.25))
                        Text(storage.notes.isEmpty ? "随手记录，绝对私密" : "没有找到相关的笔记")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(storage.notes.isEmpty ? "所有数据100%安全存储于您本机沙盒中，不会上传到任何服务器。" : "换个搜索词试试看吧。")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.72))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 48)
                        Spacer()
                    }
                    .padding(.bottom, 40)
                } else {
                    List {
                        // Pinned Section with Beautiful custom look
                        if !pinnedNotes.isEmpty {
                            Section(header: Text("已置顶").font(.system(size: 12, weight: .bold)).foregroundColor(.accentColor)) {
                                ForEach(pinnedNotes) { note in
                                    NoteRow(note: note, storage: storage)
                                }
                                .onDelete { offsets in
                                    deleteNotes(from: pinnedNotes, at: offsets)
                                }
                            }
                        }
                        
                        // Regular Section
                        if !regularNotes.isEmpty {
                            Section(header: Text(pinnedNotes.isEmpty ? "所有笔记" : "其他笔记").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)) {
                                ForEach(regularNotes) { note in
                                    NoteRow(note: note, storage: storage)
                                }
                                .onDelete { offsets in
                                    deleteNotes(from: regularNotes, at: offsets)
                                }
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true) // We use our own customized premium header instead of boring standard navigation bar title
            .overlay(
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: NoteEditorView(storage: storage)) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                Text("新建记事")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.accentColor)
                                    .shadow(color: Color.accentColor.opacity(0.35), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            )
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView()
                        .navigationBarItems(trailing: Button("完成") {
                            showSettings = false
                        })
                }
            }
            .actionSheet(isPresented: $showSortOptions) {
                ActionSheet(
                    title: Text("笔记排序规则"),
                    message: Text("请选择列表排序模式"),
                    buttons: SortOption.allCases.map { option in
                        .default(Text(option.rawValue)) {
                            selectedSort = option
                        }
                    } + [.cancel(Text("取消"))]
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteNotes(from sourceList: [Note], at offsets: IndexSet) {
        for index in offsets {
            let noteToDelete = sourceList[index]
            storage.deleteNote(noteToDelete)
        }
    }
}

// Custom Premium Node Card Row
struct NoteRow: View {
    var note: Note
    @ObservedObject var storage: NoteStorage
    
    var body: some View {
        NavigationLink(destination: NoteEditorView(storage: storage, note: note)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 6) {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 11))
                    }
                    
                    Text(note.title)
                        .font(.system(size: 17, weight: .bold))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(formatDateOnly(note.modifiedAt))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                Text(note.content.isEmpty ? "无正文内容" : note.content)
                    .font(.system(size: 13, weight: .regular))
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(formatTimeOnly(note.modifiedAt))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Spacer()
                    
                    // Word count badge inside cell
                    Text("\(note.content.count) 字")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
            }
            .padding(.vertical, 6)
        }
        .contextMenu {
            Button(action: {
                storage.togglePin(note)
            }) {
                HStack {
                    Text(note.isPinned ? "取消置顶" : "置顶笔记")
                    Image(systemName: note.isPinned ? "pin.slash" : "pin")
                }
            }
            
            Button(action: {
                storage.deleteNote(note)
            }) {
                HStack {
                    Text("删除")
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    private func formatDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatTimeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

