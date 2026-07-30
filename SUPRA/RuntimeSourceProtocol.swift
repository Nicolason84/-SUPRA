import Foundation

enum RuntimeSourceMode: String, CaseIterable, Codable {
    case json = "JSON"
    case auto = "AUTO"
    case opencode = "OpenCode"
}

protocol RuntimeSourceProtocol: AnyObject {
    var connectionState: RuntimeConnectionState { get }
    var mode: RuntimeSourceMode { get }

    func start()
    func stop()
    func refresh()
}
