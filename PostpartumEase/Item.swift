//
//  Item.swift
//  PostpartumEase
//
//  Created by Matthew Morrison on 30/12/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
