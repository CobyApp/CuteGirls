//
//  CameraManager.swift
//  CuteGirls
//
//  Created by Coby Kim on 8/30/24.
//

import AVFoundation
import CoreImage

import ComposableArchitecture

private struct CameraManagerKey: DependencyKey {
    static var liveValue: CameraManager = .shared
}

extension DependencyValues {
    var cameraManager: CameraManager {
        get { self[CameraManagerKey.self] }
        set { self[CameraManagerKey.self] = newValue }
    }
}

class CameraManager: NSObject {
    
    static let shared = CameraManager()
    
    private let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?

    private var sessionQueue = DispatchQueue(label: "video.preview.session")
    private var isSessionRunning = false
    
    private var addToPreviewStream: ((CGImage) -> Void)?
    
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage)
            }
        }
    }()
    
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    override init() {
        super.init()
    }
    
    func configureSession() async {
        guard await isAuthorized else { return }
        
        sessionQueue.sync {
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }
            
            if let deviceInput = deviceInput {
                captureSession.removeInput(deviceInput)
            }
            
            guard let newCamera = camera(with: .front),
                  let newDeviceInput = try? AVCaptureDeviceInput(device: newCamera) else {
                return
            }
            
            deviceInput = newDeviceInput
            
            if let videoOutput = videoOutput {
                captureSession.removeOutput(videoOutput)
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            
            guard captureSession.canAddInput(newDeviceInput),
                  captureSession.canAddOutput(videoOutput) else {
                return
            }
            
            captureSession.addInput(newDeviceInput)
            captureSession.addOutput(videoOutput)
            self.videoOutput = videoOutput
            
            if let connection = videoOutput.connection(with: .video) {
                Task {
                    await MainActor.run {
                        connection.videoRotationAngle = 90
                        connection.isVideoMirrored = true
                    }
                }
            }
        }
    }

    func camera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: position)
        return discoverySession.devices.first { $0.position == position }
    }
    
    func startSession() async {
        guard await isAuthorized else { return }
        await configureSession()
        
        sessionQueue.sync {
            if !isSessionRunning {
                captureSession.startRunning()
                isSessionRunning = true
            }
        }
    }
    
    func stopSession() async {
        sessionQueue.sync {
            if isSessionRunning {
                captureSession.stopRunning()
                isSessionRunning = false
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage else {
            print("Can't translate to CGImage")
            return
        }
        addToPreviewStream?(currentFrame)
    }
}

extension CMSampleBuffer {
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        guard let imagePixelBuffer = pixelBuffer else { return nil }
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
}

extension CIImage {
    var cgImage: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return cgImage
    }
}
