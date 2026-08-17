//
//  ContentView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/14/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                let client = HTTPClient()
                let users: [User] = try await client.execute(UsersAPI.users)
                print("✅ \(users.count) users")
                print(users as Any)
            } catch {
                print("❌ \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
