import SwiftUI

public struct MarkdownView: View {
    public let markdown: String
    
    public init(markdown: String) {
        self.markdown = markdown
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            let lines = markdown.components(separatedBy: .newlines)
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                parseLine(line)
            }
        }
    }
    
    @ViewBuilder
    private func parseLine(_ line: String) -> some View {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        if trimmed.hasPrefix("# ") {
            Text(LocalizedStringKey(String(trimmed.dropFirst(2))))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.top, 6)
        } else if trimmed.hasPrefix("## ") {
            Text(LocalizedStringKey(String(trimmed.dropFirst(3))))
                .font(.system(size: 13.5, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.top, 4)
        } else if trimmed.hasPrefix("### ") {
            Text(LocalizedStringKey(String(trimmed.dropFirst(4))))
                .font(.system(size: 12.5, weight: .bold))
                .foregroundStyle(Color.discordBlurple)
                .padding(.top, 3)
        } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
            HStack(alignment: .top, spacing: 6) {
                Text("•")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.discordBlurple)
                Text(LocalizedStringKey(String(trimmed.dropFirst(2))))
                    .font(.system(size: 11))
                    .foregroundStyle(.primary.opacity(0.9))
            }
            .padding(.leading, 4)
        } else if !trimmed.isEmpty {
            Text(LocalizedStringKey(trimmed))
                .font(.system(size: 11))
                .foregroundStyle(.primary.opacity(0.85))
        }
    }
}
