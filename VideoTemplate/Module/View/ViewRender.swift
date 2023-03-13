//
//  ViewRender.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import MetalKit

final class ViewRender: MTKView {
    
    private var dataFrame = DataFrame(type: .image, overlayStyle: OverlayStyle.none, size: vector_float2.zero)
    
    var modelFrame: ModelFrame? {
        willSet {
            guard let texture = newValue?.image else { return }
            drawableSize = CGSize(width: texture.image?.texture.width ?? 0, height: texture.image?.texture.height ?? 0)
            
            if let dataFrame = modelFrame?.data {
                self.dataFrame = dataFrame
            }
        }
    }
    
    private var pipelineState: MTLRenderPipelineState!
    private var renderTargetVertex: MTLBuffer!
    private var renderTargetUniform: MTLBuffer!


    required init(coder aDecoder: NSCoder) { fatalError(#function) }
    
    convenience init(frame: CGRect) {
        let device = MTLCreateSystemDefaultDevice()
        self.init(frame: frame, device: device)
    }

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        guard let device = device else { fatalError() }
        super.init(frame: frameRect, device: device)

        setup()
    }

    private func setup() {
        device = RenderDevice.device

        isOpaque = false
        framebufferOnly = false
        isPaused = true
        enableSetNeedsDisplay = false

        setupTargetUniforms()

        do {
            try setupPiplineState()
        } catch {
            fatalError("Metal initialize failed")
        }
    }

    func setupTargetUniforms() {
        let size = drawableSize
        renderTargetVertex = RenderDevice.makeRenderVertexBuffer(size: size)
        renderTargetUniform = RenderDevice.makeRenderUniformBuffer(size)
    }

    private func setupPiplineState() throws {
        if let render = try RenderDevice.generateRenderPipelineDescriptor("vertex_render", "image_render") {
            pipelineState = try RenderDevice.device.makeRenderPipelineState(descriptor: render)
        }
    }

    override func draw(_ rect: CGRect) {
        drawTexture(dataFrame: &dataFrame)
    }
    
    private func drawTexture(dataFrame: inout DataFrame) {
        if let currentDrawable = self.currentDrawable, let modelFrame = modelFrame, let image = modelFrame.image {
            let renderPassDescriptor = MTLRenderPassDescriptor()
            let colorAttachment = renderPassDescriptor.colorAttachments[0]

            colorAttachment?.texture = currentDrawable.texture
            colorAttachment?.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
            colorAttachment?.loadAction = .clear
            colorAttachment?.storeAction = .store

            let commandBuffer = RenderDevice.commandQueue.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

            commandEncoder?.setRenderPipelineState(pipelineState)
            commandEncoder?.setVertexBuffer(renderTargetVertex, offset: 0, index: 0)
            commandEncoder?.setVertexBuffer(renderTargetUniform, offset: 0, index: 1)
            
            commandEncoder?.setFragmentTexture(image.last?.texture, index: 0)
            commandEncoder?.setFragmentTexture(image.image?.texture, index: 1)
            commandEncoder?.setFragmentTexture(image.mask?.texture, index: 2)
            
            commandEncoder?.setFragmentBytes(&dataFrame, length: MemoryLayout.size(ofValue: dataFrame), index: 0)
            commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)

            commandEncoder?.endEncoding()
            commandBuffer?.present(currentDrawable)
            commandBuffer?.commit()
        }
    }
}
