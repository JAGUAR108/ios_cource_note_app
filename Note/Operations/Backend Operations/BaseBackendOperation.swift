import Foundation

enum NetworkError {
    case unreachable
    case badUrl
    case fileNotFound
}

class BaseBackendOperation: AsyncOperation {
    override init() {
        super.init()
    }
}
