//
//  Client.swift
//
//
//  Created by Juraldinio on 09.04.2024.
//

import Foundation

final class Client {
    
    enum Error: Swift.Error {
        case invalidUrl
        case notFoundChannel
        case invaildJson(String)
    }
    
    typealias CompletionHandler = (Result<Channel, Error>) -> Void
    
    private let endpoint: String
    private let channelKey: String
    
    // MARK: - Init

    init(endpoint: String, channelKey: String) {
        self.endpoint = endpoint
        self.channelKey = channelKey
    }
    
    // MARK: - Methods

    func checkVersion(completion: CompletionHandler?) {
        
        var component = URLComponents(string: "\(self.endpoint)/api/apps/latest")!
        component.queryItems = self.buildQuery()
        
        guard let url = component.url else {
            completion?(.failure(.invalidUrl))
            return
        }

        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  error == nil else {
                    completion?(.failure(.notFoundChannel))
                    return
            }

            do {
                let decoder = JSONDecoder()
                let channel = try decoder.decode(Channel.self, from: data)
                completion?(.success(channel))
            } catch let parsingError {
                completion?(.failure(.invaildJson(parsingError.localizedDescription)))
            }
        }
        
        task.resume()
    }

    func buildQuery() -> [URLQueryItem] {
        
        var result = [URLQueryItem]()
        let bundle = Bundle.main
        
        if let bundleId = bundle.infoDictionary?["CFBundleIdentifier"] as? String {
            result.append(URLQueryItem(name: "bundle_id", value: bundleId))
        }
        
        if let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            result.append(URLQueryItem(name: "release_version", value: version))
        }
        
        if let buildVersion = bundle.infoDictionary?["CFBundleVersion"] as? String {
            result.append(URLQueryItem(name: "build_version", value: buildVersion))
        }
        
        if let sdkInfo = Bundle(for: type(of: self))
            .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            
            result.append(URLQueryItem(name: "sdk", value: "ios-\(sdkInfo)"))
        }
        
        result.append(URLQueryItem(name: "channel_key", value: self.channelKey))
        
        return result
    }
}
