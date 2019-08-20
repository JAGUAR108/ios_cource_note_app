import Foundation

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: SaveNotesBackendResult?
    var notebook: FileNotebook?
    let token: String
    
    init(token: String) {
        self.token = token
        super.init()
    }
    
    override func main() {
        guard let url = URL(string: "https://api.github.com/gists") else {
            result = .failure(.badUrl)
            finish()
            return
        }
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print(response.statusCode < 300 ? "Success" : "FAIL")
            }
            if let data = data {
                do {
                    let gists = try JSONDecoder().decode([Gist].self, from: data)
                    self.findFile(gists: gists)
                } catch {
                    print(error)
                    self.result = .failure(.unreachable)
                    self.finish()
                }
            } else {
                self.result = .failure(.unreachable)
                self.finish()
            }
        }
        task.resume()
    }
    
    func findFile(gists: [Gist]) {
        for gist in gists {
            for (_, file) in gist.files {
                if file.filename == gistFileName {
                    updateGist(for: gist.id)
                    return
                }
            }
        }
        result = .failure(.fileNotFound)
        finish()
    }
    
    func updateGist(for id: String) {
        guard let url = URL(string: "https://api.github.com/gists/\(id)") else {
            result = .failure(.badUrl)
            finish()
            return
        }
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        let data = try! JSONEncoder().encode(notebook)
        let stringData = String(data: data, encoding: .utf8)
        let param = ["description": "Notes", "files": ["\(gistFileName)":["content":stringData]]] as [String:Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: [])
        let task = URLSession.shared.dataTask(with: request) { [weak self](data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode < 300 {
                    self?.result = .success
                    print("Save on server success")
                }
            }
            self?.finish()
        }
        task.resume()
    }
}

