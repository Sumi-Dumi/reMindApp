//  Untitled.swift
//  reMind_appleDarts
//
//  Created by Ansha on 2/6/2025.
//
//
//  EditProfile.swift
//  reMind_appleDarts
//
//  Created by Ansha on 2/6/2025.
//
import SwiftUI

struct EditProfile: View {
    @State private var Name = ""
    @State private var Theme = ""
    @State private var selectedLanguage = "English"
    let languages = ["English", "Spanish", "French", "German", "Japanese"]
    @State private var Voice = ""

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [
                Color.white,
                Color.primaryGreen.opacity(0.08),
                Color.pink.opacity(0.05)
            ]),
            startPoint: .top,
            endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title and subtitle
                Text("Details")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                Text("Update your details")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Input Fields
                VStack(alignment: .leading, spacing: 16) {
                    // name
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Name", text: $Name)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        }
                 
                    }

                    // theme
                    VStack(alignment: .leading) {
                        Text("Theme")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Theme", text: $Theme)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                    }
                    VStack(alignment: .leading, spacing: 8) {
                                Text("Language")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Menu {
                                    ForEach(languages, id: \.self) { language in
                                        Button(action: {
                                            selectedLanguage = language
                                        }) {
                                            Text(language)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedLanguage)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3))
                                    )
                                }
                            }
                           
             
                    // Voice
                    VStack(alignment: .leading) {
                        Text("Voice")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        SecureField("Voice", text: $Voice)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
                HStack{
                    
                    
                    // Cancel Button
                    Button(action: {
                        // Cancel action
                    }) {
                        Text("Cancel")
                            .frame(width: 100, height: 30)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .font(.headline)
                    }
                    .padding(.horizontal, 30)
                    //Save Button
                    Button(action: {
                        // Save action
                    }) {
                        Text("Save")
                            .frame(width: 100, height: 30)
                            .padding()
                            .background(Color.primaryGreen)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .font(.headline)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    EditProfile()
}


