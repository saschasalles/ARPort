//
//  ViewController.swift
//  ARPort
//
//  Created by Sascha Sallès on 04/04/2021.
//
import UIKit
import SceneKit
import ARKit

// MARK: - App State Management

enum AppState: Int16 {
  case detectSurface
  case pointAtSurface
  case tapToStart
  case started
}

// MARK: - UIViewController

class ViewController: UIViewController {

  // MARK: - Properties
  var trackingStatus: String = ""
  var statusMessage: String = ""
  var appState: AppState = .detectSurface
  var focusPoint: CGPoint!
  var focusNode: SCNNode!
  var arPortNode: SCNNode!

  // MARK: - IB Outlets

  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var resetButton: UIButton!

  // MARK: - IB Actions
  @IBAction func resetButtonPressed(_ sender: Any) {
    self.resetARSession()
  }

  @IBAction func tapGestureHandler(_ sender: Any) {
    guard appState == .tapToStart else { return }

    self.arPortNode.isHidden = false
    self.focusNode.isHidden = true
    self.arPortNode.position = self.focusNode.position

    appState = .started
  }

  override func viewDidLoad() {
    self.resetButton.layer.cornerRadius = 8
    super.viewDidLoad()
    self.initScene()
    self.initARSession()

    self.initCoachingOverlayView()
    self.initFocusNode()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("*** ViewWillAppear()")
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("*** ViewWillDisappear()")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** DidReceiveMemoryWarning()")
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}

// MARK: - App Management
extension ViewController {
  func startApp() {
    DispatchQueue.main.async {
      self.appState = .detectSurface
    }
  }

  func resetApp() {
    DispatchQueue.main.async {
      self.resetARSession()
      self.appState = .detectSurface
    }
  }

}

// MARK: - AR Coaching Overlay
extension ViewController: ARCoachingOverlayViewDelegate {
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    //
  }

  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    self.startApp()
  }

  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    self.resetApp()
  }


  // Helpers

  func initCoachingOverlayView() {
    let coachingOverlay = ARCoachingOverlayView()
    coachingOverlay.session = self.sceneView.session
    coachingOverlay.delegate = self
    coachingOverlay.activatesAutomatically = true
    coachingOverlay.goal = .horizontalPlane
    self.sceneView.addSubview(coachingOverlay)

    coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: coachingOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: coachingOverlay, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: coachingOverlay, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: coachingOverlay, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
    ])

  }
}



// MARK: - AR Session Management (ARSCNViewDelegate)
extension ViewController: ARSCNViewDelegate {
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      let alert = UIAlertController(title: "Tracking Issue", message: "Damn AR World Tracking Not Supported on your device", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)

      return
    }

    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.planeDetection = .horizontal
    config.isLightEstimationEnabled = true
    config.environmentTexturing = .automatic

    sceneView.session.run(config)
  }

  func resetARSession() {
    let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
    config.planeDetection = .horizontal
    sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
  }

  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .notAvailable:
      self.trackingStatus = "Tracking: not available"
    case .normal:
      self.trackingStatus = ""
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limited due to excessive motion!"
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: Limited due to insufficient features"
      case .relocalizing:
        self.trackingStatus = "Tracking: Relocalizing..."
      case .initializing:
        self.trackingStatus = "Tracking: Initializing..."
      @unknown default:
        self.trackingStatus = "Tracking: Unknown"
      }
    }
  }

  func session(_ session: ARSession, didFailWithError error: Error) {
    self.trackingStatus = "AR Session Failure: \(error)"
  }

  func sessionWasInterrupted(_ session: ARSession) {
    self.trackingStatus = "AR Session was interrupted"
  }

  func sessionInterruptionEnded(_ session: ARSession) {
    self.trackingStatus = "AR Session interruption ended"
  }
}

// MARK: - Scene Management
extension ViewController {
  func initScene() {
    let scene = SCNScene()
    sceneView.scene = scene
    sceneView.delegate = self

    let arPortScene = SCNScene(named: "art.scnassets/Scenes/ARPortScene.scn")!
    arPortNode = arPortScene.rootNode.childNode(withName: "ARPort", recursively: false)!

    arPortNode.isHidden = true
    sceneView.scene.rootNode.addChildNode(arPortNode)
  }

  func updateStatus() {
    switch appState {
    case .detectSurface:
      statusMessage = "Scan available flat surfaces..."
    case .pointAtSurface:
      statusMessage = "Point at designated surface first!"
    case .tapToStart:
      statusMessage = "Tap to start."
    case .started:
      statusMessage = "Tap objects for more info"
    }

    self.statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
  }

  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateStatus()
      self.updateFocusNode()
    }
  }

}

// MARK: - Focus Node Management
extension ViewController {
  func initFocusNode() {
    let focusScene = SCNScene(named: "art.scnassets/Scenes/FocusScene.scn")!

    focusNode = focusScene.rootNode.childNode(withName: "Focus", recursively: false)!
    focusNode.isHidden = true
    sceneView.scene.rootNode.addChildNode(focusNode)

    focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.1)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.orientationChanged),
      name: UIDevice.orientationDidChangeNotification,
      object: nil)
  }

  @objc func orientationChanged() {
    focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.1)
  }

  func updateFocusNode() {
    guard appState != .started else {
      focusNode.isHidden = true
      return
    }

    if let query = self.sceneView.raycastQuery(from: self.focusPoint, allowing: .estimatedPlane, alignment: .horizontal) {
      let results = self.sceneView.session.raycast(query)
      if results.count == 1 {
        if let match = results.first {
          let t = match.worldTransform
          self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
          self.appState = .tapToStart
          focusNode.isHidden = false
        } else {
          self.appState = .pointAtSurface
          focusNode.isHidden = true
        }
      }
    }
  }
}
