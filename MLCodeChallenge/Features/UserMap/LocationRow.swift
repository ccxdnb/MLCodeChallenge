//
//  LocationRow.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/19/26.
//
import SwiftUI

struct LocationRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(value)
                    .font(.subheadline)
                    .textSelection(.enabled)
            }

            Spacer()
        }
    }
}
