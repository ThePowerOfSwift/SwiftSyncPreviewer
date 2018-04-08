//
//  Result.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 05.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
enum Result<A, B> {
    case success(A)
    case error(B)
}
