//
//  ViewController.swift
//  ARKitPlanes
//
//  Created by Maxim Spiridonov on 07/05/2019.
//  Copyright © 2019 Maxim Spiridonov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    var planes = [Plane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        setupGestures()
    }
    
    func setupGestures() {
        let tapGestureRecognaizer = UITapGestureRecognizer(target: self, action: #selector(placeBox))
        tapGestureRecognaizer.numberOfTapsRequired = 1
        self.sceneView.addGestureRecognizer(tapGestureRecognaizer)
    }
    
    @objc func placeBox(tapGesture: UITapGestureRecognizer) {
        let sceneView = tapGesture.view as! ARSCNView
        let location = tapGesture.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        guard !hitTestResult.isEmpty, let hitResult = hitTestResult.first else { return }
        
        createBox(hitResult: hitResult)
        
    }
    
    func createBox(hitResult: ARHitTestResult) {
        
        //        особо не вникай почему так
        //        0.05 это половина кубика в реальном проекте так не делать
        //        0.5 высота откуда падать будет
        let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                  hitResult.worldTransform.columns.3.y + 0.5,
                                  hitResult.worldTransform.columns.3.z)
        
        let box = Box(atPosition: position)
        sceneView.scene.rootNode.addChildNode(box)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //        let configuration = ARWorldTrackingConfiguration.isSupported ? ARWorldTrackingConfiguration() : AROrientationTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        let plane = Plane(anchor: anchor as! ARPlaneAnchor)
        
        self.planes.append(plane)
        node.addChildNode(plane)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        guard plane != nil else { return }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}


extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeB.physicsBody?.contactTestBitMask == BitMaskCategory.box {
            nodeA.geometry?.materials.first?.diffuse.contents = UIColor.red
            return
        }
        nodeB.geometry?.materials.first?.diffuse.contents = UIColor.red
        
    }
}
