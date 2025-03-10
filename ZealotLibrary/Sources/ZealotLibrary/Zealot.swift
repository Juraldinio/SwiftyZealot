//
//  Zealot.swift
//  Zealot
//
//  Created by Juraldinio on 09.04.2024.
//

import Foundation
import UIKit

public final class Zealot {
    
    public enum Error: Swift.Error {
        case notFoundChannelKey
        case notFoundChannel
        case invaildJson(String)
    }
    
    public let defaultEnvironment = "default"
    public private(set) var enviroment: String
    public private(set) var endpoint: String
    public private(set) var channelKeys: [String: String]
    
    // MARK: - Init

    public init(endpoint: String, channelKey: String, enviroment: String? = nil) {
        self.endpoint = endpoint
        self.enviroment = enviroment ?? defaultEnvironment
        
        self.channelKeys = [String: String]()
        self.channelKeys[self.enviroment] = channelKey
    }

    public init(endpoint: String, channelKeys: [String: String], default enviroment: String) {
        self.endpoint = endpoint
        self.enviroment = enviroment
        self.channelKeys = channelKeys
    }
    
    // MARK: - Public
    
    public func update(channelKey: String, for environment: String) {
        self.channelKeys[environment] = channelKey
    }
    
    public func checkVersion() {
        let client = try! Client(endpoint: endpoint, channelKey: self.channelKey())
        client.checkVersion { result in
            switch result {
            case .success(let channel):
                DispatchQueue.main.async {
                    self.showAlert(channel)
                }
            case .failure(_): break  // ignore
            }
        }
    }
    
    // MARK: - Private
    
    func channelKey() throws -> String {
        let channelKey = self.channelKeys[self.enviroment] ?? self.channelKeys[self.defaultEnvironment]
        guard let channelKey else {
            throw Error.notFoundChannelKey
        }

        return channelKey
    }
    
}

// MARK: - Alert
private extension Zealot {
    
    func showAlert(_ channel: Channel) {
        guard channel.releases.count > 0 else { return }
        let alertController = createAlertVC(releases: channel.releases)
        WindowHandler.shared.present(viewController: alertController)
    }

    func updateAlertAction(url: String) -> UIAlertAction {
        return UIAlertAction(title: "立即更新 ♻️", style: .default) { (UIAlertAction) in
            guard let installUrl = URL(string: url) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(installUrl, options: [:]) { _ in
                    WindowHandler.shared.dismiss()
                }
            } else {
                WindowHandler.shared.dismiss()
                UIApplication.shared.openURL(installUrl)
            }
        }
    }

    func cancelAlertAction() -> UIAlertAction {
        return UIAlertAction(title: "下次再说 ⛔️", style: .cancel) { (UIAlertAction) in
            WindowHandler.shared.dismiss()
        }
    }

    func createAlertVC(releases: [Channel.Release]) -> UIAlertController {
        let release = releases[0]

        let title = "⭐️发现新版本⭐️"
        let message = "\(release.releaseVersion) (\(release.buildVersion))"
        let changelog = generateChangelog(releases: releases)

        let alert = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        alert.setMaxHeight(UIScreen.main.bounds.height / 2)
        alert.addTextView(text: changelog)
        alert.addAction(updateAlertAction(url: release.installUrl))
        alert.addAction(cancelAlertAction())

        return alert
    }
}

// MARK: - Helper methods
private extension Zealot {
    
    func generateChangelog(releases: [Channel.Release]) -> String {
        var changelogMessage = [String]()
        var number = 1
        for release in releases {
            for changelog in release.changelog {
                if changelog.message.isEmpty { continue }

                changelogMessage.append("\(number). \(changelog.message)")
                number += 1
            }
        }

        return changelogMessage.joined(separator: "\n")
    }
}
