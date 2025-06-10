import SwiftUI

struct Break: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image("businessman")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 340, height: 240)

                VStack(spacing: 8) {
                    Text("Good Job, you are almost there!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Text("Lastly, let me guide your breathing to help you relax!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                NavigationLink(destination: PulsingView()) {
                    Text("Next")
                        .frame(width: 200)
                        .padding()
                        .background(Color.primaryGreen)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .font(.headline)
                }

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}


struct Break_Previews: PreviewProvider {
    static var previews: some View {
        Break()
    }
}
