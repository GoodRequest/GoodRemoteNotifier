import SwiftUI

/// The main content view displaying a demo.
struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("GoodRemoteNotifier")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("A SwiftUI demo showcasing the GoodRemoteNotifier package — remote config")
                .font(.body)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
