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

class ViewController: UIViewController, ARSCNViewDelegate {

  // MARK: - Properties
  var trackingStatus: String = ""
  var statusMessage: String  = ""
  var appState: AppState = .detectSurface

  // MARK: - IB Outlets
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var resetButton: UIButton!

  // MARK: - IB Actions
  @IBAction func resetButtonPressed(_ sender: Any) {
    
  }

  @IBAction func tapGestureHandler(_ sender: Any) {
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.initScene()
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
      //self.resetARSession()
      self.appState = .detectSurface
    }
  }

}

// MARK: - AR Coaching Overlay
extension ViewController {

  // Add code here...

}

// MARK: - AR Session Management (ARSCNViewDelegate)
extension ViewController {

  // Add code here...

}

// MARK: - Scene Management
extension ViewController {
  func initScene() {
    let scene = SCNScene()
    sceneView.scene = scene
    sceneView.delegate = self
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
    }
  }

}

// MARK: - Focus Node Management
extension ViewController {

  // Add code here...

}
