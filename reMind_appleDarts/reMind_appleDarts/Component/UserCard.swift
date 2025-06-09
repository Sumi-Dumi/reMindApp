import SwiftUI

struct UserCard: View {
    
    let welcomeText: String
    let descriptionText: String
    let profileImageURL: String
    
    init(welcomeText: String = "Welcome, User!",
         descriptionText: String = "Feel grounded with your loved one",
         profileImageURL: String = "") {
        self.welcomeText = welcomeText
        self.descriptionText = descriptionText
        self.profileImageURL = profileImageURL
        
    }
    
    var body: some View {
        HStack{
            AsyncImage(url: URL(string: finalImageURL)) { image in
                 image
                     .resizable()
                     .aspectRatio(contentMode: .fill)
             } placeholder: {
                 ZStack {
                     Circle()
                         .fill(Color.gray.opacity(0.3))
                     
                     Image(systemName: "person.fill")
                         .font(.system(size: 40))
                         .foregroundColor(.gray)
                 }
             }
             .frame(width: 100, height: 100)
             .clipShape(Circle())
             .padding()
            VStack(alignment: .leading){
                Text(welcomeText)
                    .font(.title)
                Text(descriptionText)
                    .font(.caption)
                    .foregroundColor(Color.gray)
                
            }
            Spacer()
            
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)

    }
    
    private var finalImageURL: String {
        let result = profileImageURL.isEmpty ? defaultProfileImageURL : profileImageURL
        print("🖼️ finalImageURL computed: '\(result)'")
        return result
    }
    
    private var defaultProfileImageURL: String {
        return "https://res.cloudinary.com/dvyjkf3xq/image/upload/v1749361609/initial_profile_zfoxw0.png"
    }
}

#Preview {
    VStack(spacing: 20) {

        UserCard(welcomeText: "Welcome User!",
                descriptionText: "Feel grounded with your loved one",
                profileImageURL: "")
        
        UserCard(welcomeText: "Welcome Specific User!",
                descriptionText: "Using Firebase profile image",
                profileImageURL: "https://res.cloudinary.com/dvyjkf3xq/image/upload/v1749362137/Screenshot_2025-06-03_at_1.40.52_pm_zik9v6.png")
        
    }
}
