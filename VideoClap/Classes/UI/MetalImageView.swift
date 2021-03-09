//
//  MetalImageView.swift
//  VideoClap
//
//  Created by lai001 on 2021/3/9.
//

import Foundation
import Metal
import MetalKit
import AVFoundation

public class MetalImageView: MTKView {
    
    public var image: CIImage? {
        didSet {
            if let image = self.image {
                texture = MetalDevice.share.makeTexture(width: Int(image.extent.size.width), height: Int(image.extent.size.height)).unsafelyUnwrapped
                context.render(image, to: texture.unsafelyUnwrapped, commandBuffer: nil, bounds: image.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
            } else {
                texture = nil
            }
            let mode = self.contentMode
            self.contentMode = mode
        }
    }
    
    lazy var context: CIContext = {
        var context: CIContext
        if #available(iOS 13.0, *), let queue = MetalDevice.share.commandQueue {
            context = CIContext(mtlCommandQueue: queue)
        } else if let device = MetalDevice.share.device {
            context = CIContext(mtlDevice: device)
        } else {
            context = CIContext.share
        }
        return context
    }()
    
    lazy var imageVertexs: [ImageVertex] = {
        var imageVertexs: [ImageVertex] = []
        imageVertexs.append(ImageVertex(position: simd_float2(1.0, 1.0), textureCoordinate: simd_float2(1.0, 1.0)))
        imageVertexs.append(ImageVertex(position: simd_float2(-1.0, 1.0), textureCoordinate: simd_float2(0.0, 1.0)))
        imageVertexs.append(ImageVertex(position: simd_float2(-1.0, -1.0), textureCoordinate: simd_float2(0.0, 0.0)))
        imageVertexs.append(ImageVertex(position: simd_float2(1.0, 1.0), textureCoordinate: simd_float2(1.0, 1.0)))
        imageVertexs.append(ImageVertex(position: simd_float2(-1.0, -1.0), textureCoordinate: simd_float2(0.0, 0.0)))
        imageVertexs.append(ImageVertex(position: simd_float2(1.0, -1.0), textureCoordinate: simd_float2(1.0, 0.0)))
        return imageVertexs
    }()
    
    var vertexBuffer: MTLBuffer?
    
    var pipelineState: MTLRenderPipelineState?
    
    var texture: MTLTexture?
    
    public override var contentMode: UIView.ContentMode {
        didSet {
            if let texture = self.texture {
                switch contentMode {
                case .scaleAspectFit:
                    fit(imageSize: CGSize(width: CGFloat(texture.width), height: CGFloat(texture.height)))
                    self.draw(in: self)
                default:
                    break
                }
            }
        }
    }
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: MetalDevice.share.device)
        backgroundColor = .clear
        initPipelineState()
        makeVertexBuffer()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPipelineState() {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Image Render Pipeline"
        pipelineStateDescriptor.sampleCount = self.sampleCount
        pipelineStateDescriptor.vertexFunction = MetalDevice.share.makeFunction(name: "imageVertexShader")
        pipelineStateDescriptor.fragmentFunction = MetalDevice.share.makeFunction(name: "imageFragmentShader")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = self.depthStencilPixelFormat
        if #available(iOS 11.0, *) {
            pipelineStateDescriptor.vertexBuffers[0].mutability = .immutable
        }
        do {
            pipelineState = try MetalDevice.share.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            log.error(error)
        }
    }
    
    func fit(imageSize: CGSize) {
        let viewportSize = self.bounds.size
        let textureCoordinateBounds = CGRect(x: -1, y: -1, width: 2, height: 2)
        let t = CGAffineTransform(scaleX: viewportSize.height / viewportSize.width, y: 1.0)
        let aspectSize = imageSize.applying(t)
        let aspectRect = AVMakeRect(aspectRatio: aspectSize, insideRect: textureCoordinateBounds)
        let topLeft = simd_float2(Float(aspectRect.origin.x), Float(aspectRect.origin.y + aspectRect.size.height))
        let topRight = simd_float2(Float(aspectRect.origin.x + aspectRect.size.width), Float(aspectRect.origin.y + aspectRect.size.height))
        let bottomLeft = simd_float2(Float(aspectRect.origin.x), Float(aspectRect.origin.y))
        let bottomRight = simd_float2(Float(aspectRect.origin.x + aspectRect.size.width), Float(aspectRect.origin.y))
        imageVertexs = []
        imageVertexs.append(ImageVertex(position: topRight, textureCoordinate: simd_float2(1.0, 1.0)))
        imageVertexs.append(ImageVertex(position: topLeft, textureCoordinate: simd_float2(0.0, 1.0)))
        imageVertexs.append(ImageVertex(position: bottomLeft, textureCoordinate: simd_float2(0.0, 0.0)))
        imageVertexs.append(ImageVertex(position: topRight, textureCoordinate: simd_float2(1.0, 1.0)))
        imageVertexs.append(ImageVertex(position: bottomLeft, textureCoordinate: simd_float2(0.0, 0.0)))
        imageVertexs.append(ImageVertex(position: bottomRight, textureCoordinate: simd_float2(1.0, 0.0)))
        makeVertexBuffer()
    }
    
    func makeVertexBuffer() {
        guard imageVertexs.count != 0 else {
            return
        }
        vertexBuffer = MetalDevice.share.makeBuffer(bytes: imageVertexs,
                                                    length: imageVertexs.count * MemoryLayout<ImageVertex>.size,
                                                    options: [])
    }
    
}

extension MetalImageView: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        guard let commandBuffer = MetalDevice.share.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        guard let pipelineState = pipelineState else { return }
        
        defer {
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0,
                                     vertexCount: imageVertexs.count,
                                     instanceCount: imageVertexs.count / 3)
    }
    
}
