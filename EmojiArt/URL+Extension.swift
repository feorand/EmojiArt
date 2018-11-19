//
//  URL+Extension.swift
//  EmojiArt
//
//  Created by Pavel Prokofyev on 19/11/2018.
//  Copyright © 2018 Pavel Prokofyev. All rights reserved.
//

import UIKit

extension URL {
    var networkImageURL: URL {
        for queryComponent in query?.components(separatedBy: "&") ?? [] {
            let parametersComponents = queryComponent.components(separatedBy: "=")
            
            if parametersComponents.count == 2 && parametersComponents[1] == "imgurl" {
                let url = URL(string: parametersComponents[0].removingPercentEncoding ?? "")
                
                if let url = url {
                    return url
                }
            }
        }
        
        return baseURL ?? self
    }
}
