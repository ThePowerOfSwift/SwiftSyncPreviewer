//
//  ViewControllersProtocols.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 05.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
protocol HasModelProtocol: class {
    associatedtype ModelType
    var model: ModelType? {set get}
    func updateForNewModel()
}

extension HasModelProtocol {
    func setup(model: ModelType) {
        self.model = model
        self.updateForNewModel()
    }
    func configured(model: ModelType) -> Self {
        self.setup(model: model)
        return self
    }
}
