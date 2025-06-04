//  SessionView.swift
//  reMind_appleDarts
//
//  Created by ryosuke on 2/6/2025.
//


import SwiftUI
import AVKit


struct TagsView: View {
    let tags: [String]
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    
    init(tags: [String], horizontalSpacing: CGFloat = 8, verticalSpacing: CGFloat = 8) {
        self.tags = tags
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lastHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                tagView(for: tag)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > UIScreen.main.bounds.width - 48 {
                            width = 0
                            height -= lastHeight + verticalSpacing
                            totalHeight += lastHeight + verticalSpacing
                        }
                        
                        let result = width
                        
                        if tag == tags.last {
                            width = 0
                        } else {
                            width -= d.width + horizontalSpacing
                        }
                        
                        return result
                    }
                    .alignmentGuide(.top) { d in
                        let result = height
                        lastHeight = d.height
                        if tag == tags.first {
                            totalHeight = d.height
                        }
                        return result
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: totalHeight, alignment: .topLeading)
        .padding(.vertical, 4)
    }
    
    private func tagView(for text: String) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
            
            
            
            
            ///
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
    }
}

struct SessionViewKeyboard: View {
    @State private var inputText: String = ""
    @State private var tags: [String] = []
    @State private var progress: Float = 0.6
    
    
    struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
        var items: Data
        var spacing: CGFloat = 8
        var alignment: HorizontalAlignment = .leading
        var content: (Data.Element) -> Content
        
        
        var body: some View {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        
        private func generateContent(in geometry: GeometryProxy) -> some View {
            var width = CGFloat.zero
            var height = CGFloat.zero
            
            return ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
                ForEach(self.items, id: \.self) { item in
                    self.content(item)
                        .padding([.horizontal], 4)
                        .alignmentGuide(.leading, computeValue: { d in
                            if abs(width - d.width) > geometry.size.width {
                                width = 0
                                height -= d.height + spacing
                            }
                            let result = width
                            if item == self.items.first {
                                width = 0
                            } else {
                                width -= d.width + spacing
                            }
                            return result
                        })
                        .alignmentGuide(.top, computeValue: { _ in
                            let result = height
                            if item == self.items.first {
                                height = 0
                            }
                            return result
                        })
                }
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            
            VideoView()
            
            
            
            // UI
            VStack {
                
                VStack {
                    HStack(spacing: 6) {
                        ForEach(0..<5) { index in
                            Capsule()
                                .frame(height: 4)
                                .foregroundColor(index < 1 ? .white : .white.opacity(0.3)) // adjust based on progress
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    Spacer()
                    Text("Now. Tell me 3 things you hear")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                    
                        .frame(width: 346, height: 64)
                        .background(.black.opacity(0.4))
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 16)
                    
                    
                    TextField("Type Here...", text: $inputText, onCommit: {
                        if !inputText.isEmpty && tags.count < 5 {
                            tags.append(inputText)
                            inputText = ""
                        }
                    })
                    .padding()
                    .frame(width: 346, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .foregroundColor(.black)
                    
                    Spacer().frame(height: 16)
                    
                    // Fixed WrappingHStack implementation
                    TagsView(tags: tags) // Use the new view
                        .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 80)
                    
                    
                    ZStack {
                        // Mic button
                        Button(action: {}) {
                            Image(systemName: "keyboard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                                .padding(.horizontal, 40)
                                .padding(.vertical, 26.66667)
                                .frame(width: 100, height: 100)
                                .background(.black.opacity(0.4))
                                .background(.ultraThinMaterial)
                                .cornerRadius(100)
                            
                            
                        }
                        
                        // Buttons around mic
                        HStack {
                            // Left: Keyboard
                            Button(action: {}) {
                                Image(systemName: "mic.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.leading, 24) // Adjusted from 12 to 24 for balance
                            
                            Spacer()
                            
                            // Right: Delete + Check
                            HStack(spacing: 16) {
                                Button(action: {}) {
                                    Image(systemName: "delete.left.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color(red: 220 / 255, green: 236 / 255, blue: 125 / 255))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }
}

struct SessionViewKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        SessionViewKeyboard()
    }
}
