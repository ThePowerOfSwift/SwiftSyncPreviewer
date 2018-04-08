//
//  ViewController+Model.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 05.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

//MARK: Configured
extension ViewController.Model {
    func configured(document: Document?) -> Self {
        self.document = document
        return self
    }
}
