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


// MARK: - UIViewController

class ViewController: UIViewController {

  // MARK: - Properties


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

  // Add code here...

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

  // Add code here...

}

// MARK: - Focus Node Management
extension ViewController {

  // Add code here...

}
