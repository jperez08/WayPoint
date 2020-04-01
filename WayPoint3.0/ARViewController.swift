//
//  ARViewController.swift
//  WayPoint3.0
//
//  Created by ruby carrasco on 3/5/20.
//  Copyright © 2020 SCU. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import UIKit
import SceneKit
import ARKit

//  ,ARSCNViewDelegate
class ARViewController: UIViewController ,ARSCNViewDelegate  {

   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var removePlanes: UIButton!
    
    
    let locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
      if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        mapView.showsUserLocation = true
      } else {
        locationManager.requestWhenInUseAuthorization()
      }
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      checkLocationAuthorizationStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapView.userTrackingMode = .follow
        
        mapView.delegate = self as? MKMapViewDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        //configuration.worldAlignment = .gravityAndHeading
        //this line would be to orient origin axes with compass (+y is up, -z is north, -x is west)
        //took out for current push because its a fuckton of math to figure out how it changes all the other angles
        //will figure out later
        // Run the view's session
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
  
    @IBAction func resetClicked(_ sender: Any) {
        
        //planeAnchor.removeAll() //need to figure out
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
        node.removeFromParentNode()
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        //configuration.worldAlignment = .gravityAndHeading
        //this line would be to orient origin axes with compass (+y is up, -z is north, -x is west)
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        //----comment out setUpSceneView() //don't think this is necessary
    }
    
    //--Added
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    //    func getUserVector() -> (SCNVector3) { // (direction)
    //        if let frame = self.sceneView.session.currentFrame {
    //            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
    //            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
    ////            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
    //
    //            return (dir)
    //        }
    //        return (SCNVector3(0, 0, -1))
    //    } //found this online
    func getUserVector() -> (simd_float3) {
            return (sceneView.session.currentFrame?.camera.eulerAngles)!
    } //trying to figure out how to use the euler angles (roll pitch and yaw i.e. x,y,z displacement angles) to check current camera angle against worldAlignment when set to gravityAndHeading

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      // 1
      guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
      // if(abs(getUserVector().y) < .pi/3 ){ //not sure where to put this conditional???
      // 2
      let width = CGFloat(planeAnchor.extent.x)
      let height = CGFloat(planeAnchor.extent.z)
      let plane = SCNPlane(width: width, height: height)
      
      // 3
      plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
      
      // 4
      let planeNode = SCNNode(geometry: plane)
      
      // 5
      let x = CGFloat(planeAnchor.center.x)
      let y = CGFloat(planeAnchor.center.y)
      let z = CGFloat(planeAnchor.center.z)
      planeNode.position = SCNVector3(x,y,z)
      planeNode.eulerAngles.x = -.pi / 2
      planeNode.opacity = 0.8
      // 6
      node.addChildNode(planeNode)
    //} close brace for conditional
     }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
             let planeNode = node.childNodes.first,
             let plane = planeNode.geometry as? SCNPlane
             else { return }
         // if(abs(getUserVector().y) < .pi/3 ){ //not sure where to put this conditional???
         // 2
         let width = CGFloat(planeAnchor.extent.x)
         let height = CGFloat(planeAnchor.extent.z)
         plane.width = width
         plane.height = height
          
         // 3
         let x = CGFloat(planeAnchor.center.x)
         let y = CGFloat(planeAnchor.center.y)
         let z = CGFloat(planeAnchor.center.z)
         planeNode.position = SCNVector3(x, y, z)
        }
        //} close brace for conditional
    }

    extension float4x4 {
        var translation: SIMD3<Float> {
            let translation = self.columns.3
            return SIMD3(translation.x, translation.y, translation.z)
        }
    }

    extension UIColor {
        open class var transparentLightBlue: UIColor {
            return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
        }
}

let locationManager: CLLocationManager = {
  $0.requestWhenInUseAuthorization()
  $0.startUpdatingHeading()
  return $0
}(CLLocationManager())


