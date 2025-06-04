import SwiftUI
import WebKit


struct Break: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("businessman")
                .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 340, height: 240)

            VStack(spacing: 8){
                Text("Good Job, you are almost there!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Text("Just a bit more to support your sitautional distress!")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                
            }

            Button(action: {
                print("Finish tapped")
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .font(.headline)
                    .frame(width: 200)
            }

            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct Break_Previews: PreviewProvider {
    static var previews: some View {
        Break()
    }
}
