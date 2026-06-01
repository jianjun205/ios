//
//  NoteEditorView.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import SwiftUI

struct NoteEditorView: View {
    @ObservedObject var storage: NoteStorage
    @Environment(\.presentationMode) var presentationMode
    
    var note: Note?
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isPinned: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    private var isNewNote: Bool {
        note == nil
    }
    
    private var characterCount: Int {
        content.count
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Title Area
                TextField("请输入标题...", text: $title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Content Editor Wrapper
                TextViewWrapper(text: $content, placeholder: "写点什么吧，一切都将100%存在你的手机本地...")
                    .padding(.horizontal, 8)
                    .background(Color(.systemBackground))
                
                Spacer()
                
                // Bottom Utility Toolbar
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        // Date Modified Banner
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(isNewNote ? "创建于：刚刚" : "最后修改：\(formatDate(note?.modifiedAt ?? Date()))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Word Count Badge
                        Text("\(characterCount) 字")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.12))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(.systemGroupedBackground))
                }
            }
            
            // Toast view overlay
            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .padding(.bottom, 80)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.spring(), value: showToast)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            trailing: HStack(spacing: 16) {
                // Pin Button
                Button(action: {
                    guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        alertMessage = "请先输入内容再置顶"
                        showAlert = true
                        return
                    }
                    isPinned.toggle()
                    pinAndSave()
                    triggerToast(isPinned ? "已置顶并保存" : "已取消置顶并保存")
                }) {
                    Image(systemName: isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(isPinned ? .orange : .accentColor)
                }
                
                // Copy Action Button
                Button(action: {
                    if content.isEmpty {
                        alertMessage = "笔记内容为空，无法复制"
                        showAlert = true
                    } else {
                        UIPasteboard.general.string = content
                        triggerToast("已成功复制到剪贴板")
                    }
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                
                // Share Action Button
                Button(action: {
                    if content.isEmpty {
                        alertMessage = "无内容可分享"
                        showAlert = true
                    } else {
                        showShareSheet = true
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                
                // Elegant Done/Save Button
                Button(action: saveNote) {
                    Text("保存")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.accentColor)
                }
            }
        )
        .onAppear {
            if let existingNote = note {
                self.title = existingNote.title
                self.content = existingNote.content
                self.isPinned = existingNote.isPinned
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("好的")))
        }
        .sheet(isPresented: $showShareSheet) {
            ShareActivityView(text: "\(title)\n\n\(content)")
        }
    }
    
    private func triggerToast(_ msg: String) {
        toastMessage = msg
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showToast = false
        }
    }
    
    private func pinAndSave() {
        let displayTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "无标题笔记" : title
        if isNewNote {
            let freshNote = Note(title: displayTitle, content: content, createdAt: Date(), modifiedAt: Date(), isPinned: isPinned)
            storage.notes.insert(freshNote, at: 0)
            storage.saveNotes()
        } else if let originalNote = note {
            var updated = originalNote
            updated.title = displayTitle
            updated.content = content
            updated.isPinned = isPinned
            updated.modifiedAt = Date()
            storage.updateNote(updated)
        }
    }

    private func saveNote() {
        let displayTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "无标题笔记" : title
        
        if isNewNote {
            let freshNote = Note(title: displayTitle, content: content, createdAt: Date(), modifiedAt: Date(), isPinned: isPinned)
            storage.notes.insert(freshNote, at: 0)
            storage.saveNotes()
        } else if let originalNote = note {
            var updated = originalNote
            updated.title = displayTitle
            updated.content = content
            updated.isPinned = isPinned
            updated.modifiedAt = Date()
            storage.updateNote(updated)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

// System Share Sheet View Controller Wrapper
struct ShareActivityView: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
