import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack {
            Image(systemName: "gift.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Amigo Secreto")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
    }
}
