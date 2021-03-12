//
//  ContentView.swift
//  model-picker
//
//  Created by Eugene Kim on 2021/03/10.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: String?
    @State private var modelConfirmedPlacement: String?
    
    private var models: [String] = {
       // dynamically fetch file names
        let filemanager = FileManager.default
        guard let path = Bundle.main.resourcePath,
              let files = try?
                filemanager.contentsOfDirectory(atPath: path)
        else {
            return []
        }
        
        var availableModels: [String] = []
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            availableModels.append(modelName)
        }
        
        return availableModels
    }()
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelCOnfirmedPlacement: self.$modelConfirmedPlacement)
            if self.isPlacementEnabled {
                ButtonPlacementsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedPlacement: self.$modelConfirmedPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
            }
        }
    }

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelCOnfirmedPlacement: String?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.modelCOnfirmedPlacement {
            print("DEBUG: Adding model to scene \(modelName)")
            
            // reset when placed in scene to avoid stacking
            
        }
    }
    
}


// Model Picker view
struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    
    var models: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in Button(action: {
                        print("Debug: selected model with name \(self.models[index])")
                        
                        self.selectedModel = self.models[index]
                        
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: UIImage(named: self.models[index])!)
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
    @Binding var selectedModel: String?
    @Binding var modelConfirmedPlacement: String?
    
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
