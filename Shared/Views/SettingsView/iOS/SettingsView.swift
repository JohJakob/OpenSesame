//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/24/21.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @State private var isImporting: Bool = false
    
    private let icons: [String] = ["Default", "Green", "Orange", "Purple", "Red", "Silver", "Space Gray"]
    
    @StateObject var userSettings = UserSettings.default
    
    var body: some View {
        Form {
            // MARK: - Syncing
            Section("Syncing") {
                HStack {
                    Label("iCloud", systemImage: "key.icloud.fill")
                    Spacer()
                    Button {
                        try! persistenceController.uploadStoreTo(.iCloud)
                    } label: {
                        Image(systemName: "icloud.and.arrow.up")
                    }
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
                    
                    Divider()
                    
                    Button {
                        try! persistenceController.downloadStoreFrom(.iCloud)
                    } label: {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
                    .disabled(true)
                }.buttonStyle(.plain)
            }
            
            Section {
                Button {
                    isImporting.toggle()
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
                Button("Reset autofill", role: .destructive) {
                    ASCredentialIdentityStore.shared.getState { state in
                        ASCredentialIdentityStore.shared.removeAllCredentialIdentities { success, error in
                            print(success, error as Any)
                        }
                    }
                }
            }
            Section("Appearance") {
                Picker(selection: $userSettings.selectedIcon) {
                    ForEach(icons, id: \.self) { icon in
                        HStack(alignment: .top) {
                            HStack {
                                Image("\(icon)Icon")
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(15)
                                Text(icon)
                            }
                        }.tag(icon)
                    }
                } label: {
                    Label("Icon", systemImage: "app.fill")
                }
            }
            
            Section {
                NavigationLink {
                    TipJarView()
                        .navigationTitle("Tip Jar")
                } label: {
                    Label("Tip Jar", systemImage: "heart.fill")
                }
                Link(destination: URL(string: "https://github.com/OpenSesameManager/OpenSesame")!) {
                    Label("Source Code", systemImage: "chevron.left.slash.chevron.right")
                }
            }
        }
            .navigationTitle("Settings")
            .halfSheet(showSheet: $isImporting) {
                NavigationView {
                    ImportView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .navigationTitle("Import")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(.stack)
                .interactiveDismissDisabled()
                .onDisappear {
                    isImporting = false
                }
            } onEnd: {
                isImporting = false
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
