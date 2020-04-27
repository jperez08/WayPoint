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
import AVFoundation

//  ,ARSCNViewDelegate
class ARViewController: UIViewController ,ARSCNViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var removePlanes: UIButton!
    
    var steps = [MKRoute.Step]() // empty array ADDED
    var currentCoordinate: CLLocationCoordinate2D!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var stepCounter = 0
    
    //var dest = POIs(coordinate: CLLocationCoordinate2D(latitude: Double("")!, longitude: Double("")! ))
    
    var dest: POIs?
    var currentLocation = CLLocation()
    let locationManager = CLLocationManager()
    
    
    func checkLocationAuthorizationStatus() {
      if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
      } else {
        locationManager.requestWhenInUseAuthorization()
      }
    }
    
    //modify
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = locations.last else {return}
        currentLocation = location
        mapView.userTrackingMode = .followWithHeading //added -----
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
          print("ENTERED")
          stepCounter += 1
          if stepCounter < steps.count {
              let currentStep = steps[stepCounter]
              let message = "In \(currentStep.distance) meters, \(currentStep.instructions)"
              directionLabel.text = message
              let speechUtterance = AVSpeechUtterance(string: message)
              speechSynthesizer.speak(speechUtterance)
          } else {
              let message = "Arrived at destination"
              directionLabel.text = message
              let speechUtterance = AVSpeechUtterance(string: message)
              speechSynthesizer.speak(speechUtterance)
              stepCounter = 0
              locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
              
          }
      }
    
    
    
    func createDirectionRequest() -> MKDirections.Request {
           let destinationCoordinate = dest!.coordinate
           let startinglocation = MKPlacemark(coordinate: currentLocation.coordinate)
           let destinationlocation = MKPlacemark(coordinate: destinationCoordinate)
           
           let request = MKDirections.Request()
           request.source = MKMapItem(placemark: startinglocation)
           request.destination = MKMapItem(placemark: destinationlocation)
           request.transportType = .automobile
           request.requestsAlternateRoutes = false
           return request
       }
    
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      checkLocationAuthorizationStatus()
      print( "latitude = ", currentLocation.coordinate.latitude, "   longitude = " , currentLocation.coordinate.longitude)
     //got user's current coordinates.
        
        // ******* TEST FOR GETTING ORIENTATION FOR TRUE NORTH ******* //
       
        let heading = locationManager.headingOrientation.rawValue
        //heading.startUpdatingHeadin
        //Jose Please look at the headingOrientation/heading in locationManager (CLLocationManager). It is supposed to give a value that determines what orientation the phone is facing.
        //let heading =
        print("  current orientation: " , heading);
        //******* END TEST *********//
        
    //------directions right here
        let request = createDirectionRequest()
        let directions = MKDirections(request:request)
        directions.calculate{ (response, error) in
        print("got directions")
            guard let response = response else {return}
            guard let primaryRoute = response.routes.first else {return}
            self.steps = primaryRoute.steps //saved steps to access outside ADDED!!!
            self.mapView.addOverlay(primaryRoute.polyline)
            self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
        print("got route")
            for i in 0 ..< primaryRoute.steps.count{

                let step = primaryRoute.steps[i]
                print(step.instructions)
                print(step.distance)
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
            }
            let initMessage = "In \(self.steps[0].distance) meters, \(self.steps[0].instructions) then in \(self.steps[1].distance) meters, \(self.steps[1].instructions)."
            self.directionLabel.text = initMessage
            let speechUtterance = AVSpeechUtterance(string: initMessage)
            self.speechSynthesizer.speak(speechUtterance)
            self.stepCounter += 1
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //show the user's current location
        //mapView.userTrackingMode = .followWithHeading
        
        mapView.delegate = self as MKMapViewDelegate
        mapView.addAnnotation(dest!)
        mapView.showsCompass = true
        checkLocationAuthorizationStatus()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
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
        //----comment out setUpSceneView() //don't think this is necessary
    }
    //--Added
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }

    
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
     }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
             let planeNode = node.childNodes.first,
             let plane = planeNode.geometry as? SCNPlane
             else { return }
          
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
    
      
}

//modify
extension ARViewController: MKMapViewDelegate{
    func mapView(_ mapView:MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
            renderer.strokeColor = .blue
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay:overlay)
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
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
  $0.startUpdatingLocation()
  $0.startUpdatingHeading()
  return $0
}(CLLocationManager())


