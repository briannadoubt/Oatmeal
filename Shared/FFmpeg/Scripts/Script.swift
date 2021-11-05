//
//  Script.swift
//  Oatmeal
//
//  Created by Bri on 11/3/21.
//

import Foundation

public protocol Script {
    var command: String { get }
}

public protocol VideoScript: Script {
    var inputFile: URL { get }
}

public extension VideoScript {
    func absolute(_ url: URL) -> String {
        url.absoluteString.removingPercentEncoding ?? ""
    }
}
