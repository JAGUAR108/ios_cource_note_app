//
//  LoadNotesBackendOperation.swift
//  Note
//
//  Created by Максим Бачурин on 30/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation

enum LoadNotesBackendResult {
    case success(FileNotebook)
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: LoadNotesBackendResult?
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
                print(response.statusCode < 300 ? "Success" : "FAIL responce code")
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
                    loadFromRawUrl(rawUrl: file.rawUrl)
                    return
                }
            }
        }
        result = .failure(.fileNotFound)
        finish()
    }
    
    func loadFromRawUrl(rawUrl: String) {
        guard let rawUrl = URL(string: rawUrl) else {
            result = .failure(.badUrl)
            finish()
            return
        }
        var rawRequest = URLRequest(url: rawUrl)
        rawRequest.setValue("token \(token)",
            forHTTPHeaderField: "Authorization")
        let rawTask = URLSession.shared.dataTask(with: rawUrl, completionHandler: {
            (data, response, error) in
            if let data = data {
                let notebook = try? JSONDecoder().decode(FileNotebook.self, from: data)
                if let notebook = notebook {
                    self.result = .success(notebook)
                    print("Load from server success")
                    self.finish()
                    return
                }
            }
            else {
                self.result = .failure(.unreachable)
                self.finish()
                return
            }
        })
        rawTask.resume()
    }
}

let gistFileName = "ios-course-notes-db"
