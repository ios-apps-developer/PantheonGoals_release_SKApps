import SwiftUI

public struct LoadingAnimation: View {
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var labelOpacity: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Image("pahntheonBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Image("copilSeven")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Loading...")
                    .font(.custom("aAhaWow", size: 24))
                    .foregroundColor(.white)
                    .opacity(labelOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.5)) {
            labelOpacity = 1.0
            opacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            scale = 1.2
            opacity = 0.6
        }
    }
}
