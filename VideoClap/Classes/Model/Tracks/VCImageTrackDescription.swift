//
//  VCImageTrackDescription.swift
//  VideoClap
//
//  Created by lai001 on 2020/11/22.
//

import AVFoundation

protocol VCImagePros: NSObject, NSCopying, NSMutableCopying {
    
    var prefferdTransform: CGAffineTransform? { get set }
    
    var isFit: Bool { get set }
    
    var isFlipHorizontal: Bool { get set }
    
    var filterIntensity: NSNumber { get set }
    
    var lutImageURL: URL? { get set }
    
    /// 顺时针，弧度制，1.57顺时针旋转90度，3.14顺时针旋转180度
    var rotateRadian: CGFloat { get set }
    
    /// 归一化下裁剪区域，范围（0~1）
    var cropedRect: CGRect? { get set }
    
    var trajectory: VCTrajectoryProtocol? { get set }
    
    var canvasStyle: VCCanvasStyle? { get set }
    
}

public class VCImageTrackDescription: NSObject, VCImagePros, VCTrackDescriptionProtocol {
    
    public var mediaURL: URL? = nil
    
    public var id: String = ""
    
    public var prefferdTransform: CGAffineTransform? = nil
    
    public var timeRange: CMTimeRange = .zero
    
    public var isFit: Bool = true
    
    public var isFlipHorizontal: Bool = false
    
    public var filterIntensity: NSNumber = 1.0
    
    public var lutImageURL: URL?
    
    /// 顺时针，弧度制，1.57顺时针旋转90度，3.14顺时针旋转180度
    public var rotateRadian: CGFloat = 0.0
    
    /// 归一化下裁剪区域，范围（0~1）
    public var cropedRect: CGRect?
    
    public var trajectory: VCTrajectoryProtocol?
    
    public var canvasStyle: VCCanvasStyle?
    
    public override init() {
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        let copyObj = VCImageTrackDescription()
        copyObj.mediaURL         = mediaURL
        copyObj.id               = id
        copyObj.timeRange        = timeRange
        copyObj.isFit            = isFit
        copyObj.isFlipHorizontal = isFlipHorizontal
        copyObj.filterIntensity  = filterIntensity
        copyObj.lutImageURL      = lutImageURL
        copyObj.rotateRadian     = rotateRadian
        copyObj.cropedRect       = cropedRect
        copyObj.trajectory       = trajectory
        copyObj.canvasStyle      = canvasStyle
        return copyObj
    }
    
}
