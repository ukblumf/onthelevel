import Foundation
import CoreMotion
import Combine

class MotionService: ObservableObject {
    private let motionManager = CMMotionManager()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentTilt: Double = 0.0
    @Published var rollAngle: Double = 0.0
    @Published var pitchAngle: Double = 0.0
    @Published var isActive: Bool = false
    
    var tiltPublisher: AnyPublisher<Double, Never> {
        $currentTilt.eraseToAnyPublisher()
    }
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    }
    
    func startMotionUpdates() {
        guard !isActive else { return }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("Motion update error: \(error)")
                }
                return
            }
            
            let roll = motion.attitude.roll
            let pitch = motion.attitude.pitch
            
            let tiltAngle = sqrt(roll * roll + pitch * pitch) * 180.0 / .pi
            
            DispatchQueue.main.async {
                self.currentTilt = tiltAngle
                self.rollAngle = roll * 180.0 / .pi
                self.pitchAngle = pitch * 180.0 / .pi
            }
        }
        
        isActive = true
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        isActive = false
    }
    
    deinit {
        stopMotionUpdates()
    }
}