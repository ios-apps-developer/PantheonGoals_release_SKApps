import SwiftUI

public struct LoadingAnimation: View {
    @State private var rotationAngleColorMory: Double = 0
    @State private var ballScaleColorMory: CGFloat = 1.0
    @State private var logoOpacityColorMory: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Image("bg_main")
                .resizable()
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                Image("logoColorMory")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 20)
                    .opacity(logoOpacityColorMory)
                    .scaleEffect(logoOpacityColorMory)
                
                Spacer()
                VStack(spacing: 15) {
                    Image("load_spinnerColorMory")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(rotationAngleColorMory * 2))
                        .opacity(0.8)
                    
                    Text("LOADING...")
                        .font(.custom("Rubik-Bold", size: 32))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(logoOpacityColorMory)
            }
        }
        .onAppear {
            startAnimationsColorMory()
        }
    }
    
    private func startAnimationsColorMory() {
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            logoOpacityColorMory = 1.0
        }

        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotationAngleColorMory = 360
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            ballScaleColorMory = 1.2
        }
    }
}