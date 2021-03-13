//
//  model.swift
//  model-picker
//
//  Created by Eugene Kim on 2021/03/13.
//

import Foundation
import UIKit
import RealityKit
// async framework
import Combine


// async model loading

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename).sink(receiveCompletion: { loadCompletion in
            // error handling
            print("DEBUG: Cannot laod model entity for model name: \(self.modelName)")
        }, receiveValue: {
            // fetch model entity
            modelEntity in
            self.modelEntity = modelEntity
            print("DEBUG: Loaded model entity for model name: \(self.modelName)")
        })
    }
}
