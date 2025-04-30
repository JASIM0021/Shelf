//
//  ServerConfigICO.swift
//  Shelf
//

//

import Foundation
enum APIMode {
    case localDevelopment
    case production
    case staging
    case development
}

struct ServerConfig {

    // MARK: - Static stored properties
    static var baseURL = ""
    static var dataUrl = ""

    // MARK: Setting mode changes the stored URLs
    static var mode: APIMode = .production {
        didSet {
            switch mode {

            case .localDevelopment:
                baseURL = ""
                dataUrl = ""
            case .production:
                baseURL = Production_Base_URL
                dataUrl = Production_Base_URL
            case .staging:
                baseURL = ""
                dataUrl = ""
            case .development:
                baseURL = ""
                dataUrl = ""
            }
        }
    }

    // MARK: - Initializer
    init(withMode mode: APIMode) {
        ServerConfig.mode = mode
    }
}
