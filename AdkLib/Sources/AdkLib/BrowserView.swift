import SwiftUI
import WebKit

public struct BrowserView: UIViewRepresentable {
    let url: String
    @Binding var webView: WKWebView?
    
    public init(url: String, webView: Binding<WKWebView?>) {
        self.url = url
        self._webView = webView
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        
        if let cookieData = UserDefaults.standard.array(forKey: AppConfig.Keys.cookies) as? [Data] {
            for data in cookieData {
                if let cookie = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? HTTPCookie {
                    WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie)
                }
            }
        }
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = UserAgentManager.shared.userAgent
        webView.backgroundColor = .white
        webView.isOpaque = true
        webView.scrollView.backgroundColor = .white
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        DispatchQueue.main.async {
            self.webView = webView
            
            if let url = URL(string: self.url) {
                print("🌐 Loading URL: \(self.url)")
                webView.load(URLRequest(url: url))
            }
        }
        
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: BrowserView
        
        init(_ parent: BrowserView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                let cookieData = cookies.compactMap {
                    try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false)
                }
                UserDefaults.standard.set(cookieData, forKey: AppConfig.Keys.cookies)
            }
        }
        
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            
            if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorNotConnectedToInternet {
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: AppConfig.Alert.noInternetTitle,
                        message: AppConfig.Alert.noInternetMessage,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: AppConfig.Alert.okButton, style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
            }
        }
    }
}
