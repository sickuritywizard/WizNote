import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var text: String = ""
    @State private var showPopover = false
    @State private var autoSaveTimer: Timer? // Timer for auto-save
    @State private var savedFileURL: URL? // Store the URL of the saved file or loaded file
    
    var body: some View {
        VStack {
            // Text Editor
            TextEditor(text: $text)
                .frame(width: 350, height: 321) // Size
                .padding()

            HStack {
                // Popover button for load and save
                Spacer()  // Push button to right
                Button(action: {
                    showPopover.toggle()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 15, height: 15) // Popover Icon size
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $showPopover) {
                    VStack(spacing: 10) { // Reduced spacing between buttons

                        // Save Button
                        Button(action: saveText) {
                            Text("Save")
                                .font(.system(size: 9)) // Save Button Font size
                                .padding(5)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        
                        // Load Button
                        Button(action: openTextFile) {
                            Text("Load")
                                .font(.system(size: 9))
                                .padding(5)
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    .padding()
                    .frame(width: 120)  // Popover width
                }
            }
            .padding([.trailing, .bottom], 12) // Popover button padding
        }
        .frame(width: 350, height: 350) // Full App Size
        .padding()
        .onAppear {
            startAutoSaveTimer()
        }
        .onDisappear {
            stopAutoSaveTimer()
        }
    }

    func saveText() {
        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.title = "Save your note"
            savePanel.allowedContentTypes = [UTType.plainText]
            savePanel.nameFieldStringValue = "WizNote.txt"
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false

            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    self.savedFileURL = url // Store the URL of the saved file
                    saveTextToFile(url: url)
                }
            }
        }
    }

    func saveTextToFile(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try text.write(to: url, atomically: true, encoding: .utf8)
                print("Note saved successfully!")
            } catch {
                print("Failed to save text: \(error)")
            }
        }
    }

    func openTextFile() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Load Note"
        openPanel.allowedContentTypes = [UTType.plainText]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                do {
                    let loadedText = try String(contentsOf: url, encoding: .utf8)
                    DispatchQueue.main.async {
                        self.text = loadedText
                        self.savedFileURL = url // Track the loaded file's URL for future saves
                    }
                } catch {
                    print("Failed to load text: \(error)")
                }
            }
        }
    }
    
    // Start the auto-save timer
    func startAutoSaveTimer() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { _ in //1 hour
            autoSave()
        }
    }

    // Stop the auto-save timer
    func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }

    // Auto-save function
    func autoSave() {
        guard let autoSaveURL = savedFileURL else {
            print("No file has been saved or loaded yet, skipping auto-save.")
            return
        }
        saveTextToFile(url: autoSaveURL)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
