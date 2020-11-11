//
//  VCCubeTransition.swift
//  VideoClap
//
//  Created by laimincong on 2020/11/11.
//

import AVFoundation

public class VCCubeTransition: NSObject, VCTransitionProtocol {
    
    public var fromId: String = ""
    
    public var toId: String = ""
    
    public var timeRange: CMTimeRange = .zero

    public func transition(renderSize: CGSize, progress: Float, fromImage: CIImage, toImage: CIImage) -> CIImage? {
        var finalImage: CIImage?
        
        let filter = VCCubeFilter()
        filter.inputTime = NSNumber(value: progress)
        filter.inputImage = fromImage
        filter.inputTargetImage = toImage
        
        if let image = filter.outputImage {
            finalImage = image
        }
        
        return finalImage
    }
    
}
