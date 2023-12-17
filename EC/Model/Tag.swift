//
//  Tag.swift
//  EC
//
//  Created by Justin Zhang on 12/16/23.
//

import SwiftUI
import Firebase

struct Tag: Identifiable, Hashable, Encodable, Decodable {
  let id: String
  var value: String
  var isInitial: Bool = false
}
