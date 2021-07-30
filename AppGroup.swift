//
//  AppGroup.swift
//  AppGroup
//
//  Created by Nikita Pekin on 2021-07-30.
//

import Foundation

public enum AppGroup: String {
    case facts = "group.com.frecency.tracetime"
    
    public var containerUrl: URL {
        switch self {
        case .facts:
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
        }
    }
}
