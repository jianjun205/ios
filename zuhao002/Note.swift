//
//  Note.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import Foundation

struct Note: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
    var isPinned: Bool
    
    init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date(), modifiedAt: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isPinned = isPinned
    }
}

class NoteStorage: ObservableObject {
    static let shared = NoteStorage()

    @Published var notes: [Note] = []
    
    private let fileName = "local_notes.json"
    
    init() {
        loadNotes()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    func loadNotes() {
        let url = fileURL
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedNotes = try decoder.decode([Note].self, from: data)
                self.notes = decodedNotes
            } catch {
                print("Failed to load notes: \(error)")
                self.notes = []
            }
        } else {
            self.notes = []
        }
    }
    
    func saveNotes() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(notes)
            try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    func addNote(title: String, content: String) {
        let newNote = Note(title: title, content: content)
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updated = note
            updated.modifiedAt = Date()
            notes[index] = updated
            saveNotes()
        }
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    func togglePin(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            // Use a single explicit full assignment to guarantee @Published fires
            var updated = notes[index]
            updated.isPinned.toggle()
            notes[index] = updated
            saveNotes()
        }
    }
}
