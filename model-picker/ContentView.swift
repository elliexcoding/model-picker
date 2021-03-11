//
//  ContentView.swift
//  model-picker
//
//  Created by Eugene Kim on 2021/03/10.
//

import SwiftUI
import RealityKit

struct ContentView : View {
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
            ARViewContainer()
            
            // ModelPickerView(models: self.models)
            
            HStack {
                // cancel
                Button(action: {
                    print("DEBUG: Cancel Model Placement")
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
        }
    }

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        

        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}


// Model Picker view
struct ModelPickerView: View {
    var models: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in Button(action: {
                        print("Debug: selected model with name \(self.models[index])")
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

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
