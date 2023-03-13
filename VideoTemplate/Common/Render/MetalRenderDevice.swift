//
//  MetalRenderDevice.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import Metal
import CoreGraphics

let RenderDevice = MetalRenderDevice()

final class MetalRenderDevice {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    public init() {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError() }
        self.device = device

        guard let queue = self.device.makeCommandQueue() else { fatalError() }
        self.commandQueue = queue
    }

    func generateRenderPipelineDescriptor(_ vertex: String, _ fragment: String) throws -> MTLRenderPipelineDescriptor? {
        guard let resource = Bundle.main.path(forResource: "default", ofType: "metallib") else {return nil}
        let library = try device.makeLibrary(URL: URL(string: resource)!)

        let vertexName = library.makeFunction(name: vertex)
        let fragmentName = library.makeFunction(name: fragment)
        let render = MTLRenderPipelineDescriptor()
        render.vertexFunction = vertexName
        render.fragmentFunction = fragmentName
        render.colorAttachments[0].pixelFormat = .bgra8Unorm

        return render
    }

    func makeRenderVertexBuffer(_ origin: CGPoint = .zero, size: CGSize) -> MTLBuffer? {
        let w = size.width, h = size.height
        let vertices = [
            Vertex(position: CGPoint(x: origin.x , y: origin.y), textCoord: CGPoint(x: 0, y: 0)),
            Vertex(position: CGPoint(x: origin.x + w , y: origin.y), textCoord: CGPoint(x: 1, y: 0)),
            Vertex(position: CGPoint(x: origin.x + 0 , y: origin.y + h), textCoord: CGPoint(x: 0, y: 1)),
            Vertex(position: CGPoint(x: origin.x + w , y: origin.y + h), textCoord: CGPoint(x: 1, y: 1)),
        ]
        return makeRenderVertexBuffer(vertices)
    }

    private func makeRenderVertexBuffer(_ vertices: [Vertex]) -> MTLBuffer? {
        device.makeBuffer(bytes: vertices,
                          length: MemoryLayout<Vertex>.stride * vertices.count,
                          options: .cpuCacheModeWriteCombined)
    }

    func makeRenderUniformBuffer(_ size: CGSize) -> MTLBuffer? {
        let metrix = Matrix.identity
        metrix.scaling(x: 2 / Float(size.width), y: -2 / Float(size.height), z: 1)
        metrix.translation(x: -1, y: 1, z: 0)
        return device.makeBuffer(bytes: metrix.m, length: MemoryLayout<Float>.size * 16, options: [])
    }
}

