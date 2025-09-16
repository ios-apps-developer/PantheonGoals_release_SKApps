import SwiftUI
import WebKit

public struct RemoteScreen<Content: View>: View {
    private let content: Content
    @StateObject private var appParameters = AppParameters.shared
    @State private var webView: WKWebView?
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private struct NavigationBar: View {
        let webView: WKWebView
        
        var body: some View {
            HStack {
                Button(action: {
                    webView.goBack()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Button(action: {
                    if let targetUrl = UserDefaults.standard.string(forKey: AppConfig.Keys.targetUrl),
                       let url = URL(string: targetUrl) {
                        webView.load(URLRequest(url: url))
                    }
                }) {
                    Image(systemName: "house")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                .padding(.trailing, 20)
            }
            .frame(height: 50)
            .background(Color.black)
        }
    }
    
    public var body: some View {
        ZStack {
            if !UserDefaults.standard.bool(forKey: AppConfig.Keys.checksComplete) {
                LoadingAnimation()
            } else if appParameters.currentScreen == .webView, let url = appParameters.webViewURL {
                VStack(spacing: 0) {
                    if let wv = webView {
                        NavigationBar(webView: wv)
                    }
                    
                    BrowserView(url: url, webView: $webView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            AppDelegate.shared?.orientationMask = .all
                            AppDelegate.shared?.updateScreenOrientation()
                        }
                        .onDisappear {
                            AppDelegate.shared?.orientationMask = .portrait
                            AppDelegate.shared?.updateScreenOrientation()
                        }
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                content
            }
        }
    }
}
