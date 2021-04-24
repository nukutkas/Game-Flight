//
//  GameViewController.swift
//  Game Flight
//
//  Created by Татьяна Кочетова on 21.04.2021.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    /// Label with the score
    let scoreLabel = UILabel()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ship: SCNNode?
    
    func addShip() {
        
        // Get a scene with the ship
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
        // Find ship in the scene
        ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // Set ship coordinates
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -100
        ship?.position = SCNVector3(x, y, z)
        
        // set ship orientation
        ship?.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
        
        // Make the ship fly to the origin
        ship?.runAction(SCNAction.move(to: SCNVector3(), duration: 5)) {
            DispatchQueue.main.async {
                self.scoreLabel.text = "GAME OVER\nFinal Score: \(self.score)"
            }
            self.ship?.removeFromParentNode()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.score = 0
                self.addShip()
            }
        }
        
        // Get the scene
        let scnView = self.view as! SCNView
        
        // Add ship to the scene
        if let ship = ship {
            scnView.scene?.rootNode.addChildNode(ship)
        }
    }
    
    func setupUI() {
        score = 0
        scoreLabel.font = UIFont.systemFont(ofSize: 30)
        scoreLabel.frame = CGRect (x: 0, y: 0, width: view.frame.width, height: 100)
        scoreLabel.numberOfLines = 0
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white
        
        view.addSubview(scoreLabel )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        ship.removeFromParentNode()
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        //Add the ship to the scene
        addShip()
        
        //Setup UI
        setupUI()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.score += 1
                self.ship?.removeFromParentNode()
                self.addShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
}
