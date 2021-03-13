//
//  ContentView.swift
//  model-picker
//
//  Created by Eugene Kim on 2021/03/10.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedPlacement: Model?
    
    private var models: [Model] = {
       // dynamically fetch file names
        let filemanager = FileManager.default
        guard let path = Bundle.main.resourcePath,
              let files = try?
                filemanager.contentsOfDirectory(atPath: path)
        else {
            return []
        }
        
        var availableModels: [Model] = []
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        
        return availableModels
    }()
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedPlacement: self.$modelConfirmedPlacement)
            if self.isPlacementEnabled {
                ButtonPlacementsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedPlacement: self.$modelConfirmedPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
            }
        }
    }

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
    let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        // lidar tracking
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedPlacement {
            // check for not nil
            if let modelEntity = model.modelEntity {
                print("DEBUG: Adding model to scene \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                // make copy of model on placement
                anchorEntity.addChild(modelEntity
                    .clone(recursive: true))
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: Can't load modelEntity for \(model.modelName)")
            }
            
            // reset when placed in scene to avoid stacking
            DispatchQueue.main.async {
                self.modelConfirmedPlacement = nil
            }
        }
    }
}

class CustomARView: ARView {
    let focusSquare = FocusEntity()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        
        self.setupARView()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        // lidar tracking
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        self.session.run(config)
    }
    
}

extension CustomARView: FocusEntityDelegate {
    func toTrackingState() {
        print("Tracking")
    }
    
    func toInitializingState() {
        print("Initializing")
    }
}

// Model Picker view
struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in Button(action: {
                        print("Debug: selected model with name \(self.models[index].modelName)")
                        
                        self.selectedModel = self.models[index]
                        
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct ButtonPlacementsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedPlacement: Model?
    
    var body: some View {
        HStack {
            // cancel
            Button(action: {
                print("DEBUG: Cancel Model Placement")
                self.resetPlacement()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white
                                    .opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            // confirm
            Button(action: {
                print("DEBUG: Confirm Model Placement")
                
                self.modelConfirmedPlacement = self.selectedModel
                
                self.resetPlacement()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white
                                    .opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacement() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
