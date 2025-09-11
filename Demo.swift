import Foundation

struct Demo {
    static let basic = URL(string: "https://73a667edd86d.ngrok-free.app")!
    static let turbolinks5 = URL(string: "http://192.168.1.46:8000/dashboard?turbolinks=1")!
    
    static let local = URL(string: "http://localhost:8000")!
    static let turbolinks5Local = URL(string: "http://localhost:8000?turbolinks=1")!

    /// Update this to choose which demo is run
    static var current: URL {
        basic
    }
}
