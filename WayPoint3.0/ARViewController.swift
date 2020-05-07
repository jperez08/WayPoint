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
import ARCL


//  ,ARSCNViewDelegate
/*
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
*/
let Altitude: CLLocationDistance = 360

//@available(iOS 11.0, *)
class ARViewController: UIViewController {
    
//    let Benson = POIs(title: "Benson Center",
//                        locationName: "SCU",
        let l1 = CLLocationCoordinate2D(latitude: 37.347726, longitude: -121.939435)
//     mapView.addAnnotation(Benson)
//
//     let Daly = POIs(title: "Daly Science",
//                               locationName: "SCU",
        let l2 =  CLLocationCoordinate2D(latitude: 37.350416, longitude: -121.940879)
//            mapView.addAnnotation(Daly)
//
//     let Heaf = POIs(title: "Heafey/Bergin",
//                        locationName: "SCU",
        let l3 = CLLocationCoordinate2D(latitude: 37.349169, longitude: -121.939637)
//     mapView.addAnnotation(Heaf)
//
//     let Kenna = POIs(title: "Kenna",
//                               locationName: "SCU",
        let l4 = CLLocationCoordinate2D(latitude: 37.348858, longitude: -121.939482)
//     mapView.addAnnotation(Kenna)
//
//     let Lucas = POIs(title: "Lucas Hall",
//                               locationName: "SCU",
        let l5 = CLLocationCoordinate2D(latitude: 37.351107, longitude: -121.939586)
//            mapView.addAnnotation(Lucas)
//
//     let Mayer = POIs(title: "Mayer Theatre",
//                        locationName: "SCU",
        let l6 = CLLocationCoordinate2D(latitude: 37.3497994, longitude: -121.9424801)
//     mapView.addAnnotation(Mayer)
//
//     let Mission = POIs(title: "Mission Church",
//                               locationName: "SCU",
      let l7 = CLLocationCoordinate2D(latitude: 37.3493061, longitude: -121.9413858)
//            mapView.addAnnotation(Mission)
//
//     let Music = POIs(title: "Music & Dance",
//                        locationName: "SCU",
      let l8 = CLLocationCoordinate2D(latitude: 37.3501323, longitude: -121.9425096)
//     mapView.addAnnotation(Music)
//
//     let Nobili = POIs(title: "Nobili Hall",
//                        locationName: "SCU",
      let l9 = CLLocationCoordinate2D(latitude: 37.3490084, longitude: -121.9423413)
//     mapView.addAnnotation(Nobili)
//
//     let Oconn = POIs(title: "O'Connor Hall",
//                                     locationName: "SCU",
      let l10 = CLLocationCoordinate2D(latitude: 37.349943, longitude: -121.941604)
//                  mapView.addAnnotation(Oconn)
//
//     let StJoe = POIs(title: "Saint Joseph's",
//                        locationName: "SCU",
      let l11 = CLLocationCoordinate2D(latitude: 37.3488224, longitude: -121.9409667)
//     mapView.addAnnotation(StJoe)
//
//
//     let Vari = POIs(title: "Vari Hall",
//                        locationName: "SCU",
      let l12 = CLLocationCoordinate2D(latitude: 37.350438, longitude: -121.939261)
//     mapView.addAnnotation(Vari)
    
    
    
    // TEMP TESTING VARIABLES
//    let l1 = CLLocationCoordinate2D(latitude: 34.0987346, longitude: -117.7123592)
//    let l2 = CLLocationCoordinate2D(latitude: 34.0990761, longitude: -117.7099627)
//    let l3 = CLLocationCoordinate2D(latitude: 34.0972554, longitude: -117.7093386)
//    let l4 = CLLocationCoordinate2D(latitude: 34.0986692, longitude: -117.7136621)
//    let l5 = CLLocationCoordinate2D(latitude: 34.0996506, longitude: -117.7143718)
//    let l6 = CLLocationCoordinate2D(latitude: 34.1001445, longitude: -117.7129978)
    
    //let sc = CLLocationCoordinate2D(latitude: 34.0195564, longitude: -118.2889155)
    let sc = CLLocationCoordinate2D(latitude: 37.3490062, longitude: -121.9395670)
    
    var sceneLocationView = SceneLocationView()
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    var routeCoordinates = [CLLocationCoordinate2D]()
    // Distance between intermediate nodes between waypoint nodes
    let metersPerNode: CLLocationDistance = 5
    
    var updateUserLocationTimer: Timer?
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = false
    
    var centerMapOnUserLocation: Bool = true
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = false

    var adjustNorthByTappingSidesOfScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
        //        sceneLocationView.orientToTrueNorth = false
        
        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        sceneLocationView.showAxesNode = true
    //    sceneLocationView.sceneLocationManager.locationDelegate = self
        
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }
        
        self.plotARRoute()
        
        view.addSubview(sceneLocationView)
        
        if showMapView {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.alpha = 0.8
            view.addSubview(mapView)
            
            updateUserLocationTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(ARViewController.updateUserLocation),
                userInfo: nil,
                repeats: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func plotARRoute() {
        // First remove all AR nodes previously plotted
       // sceneLocationView.resetLocationNodes()
        sceneLocationView.removeAllNodes()
        
        
        // Add an AR annotation for every coordinate in routeCoordinates
        for coordinate in routeCoordinates {
            // TODO: Change altitude so that it is not hard coded
            let nodeLocation = CLLocation(coordinate: coordinate, altitude: Altitude)
            let locationAnnotation = LocationAnnotationNode(location: nodeLocation, image: UIImage(named: "pin")!)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotation)
            
        }
        
        
        // Use Turf to find the total distance of the polyline
        let distance = Turf.distance(along: routeCoordinates)

        // Walk the route line and add a small AR node and map view annotation every metersPerNode
        for i in stride(from: 0, to: distance, by: metersPerNode) {
            // Use Turf to find the coordinate of each incremented distance along the polyline
            if let nextCoordinate = Turf.coordinate(at: i, fromStartOf: routeCoordinates) {
                let interpolatedStepLocation =                 CLLocation(coordinate: nextCoordinate, altitude: Altitude)
                
                // Add an AR node
                let locationAnnotation = LocationAnnotationNode(location: interpolatedStepLocation, image: UIImage(named: "middleNode")!)
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotation)
            }
        }
        
    }
    
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.sceneLocationManager.currentLocation {
            DispatchQueue.main.async {
                
                if let bestEstimate = self.sceneLocationView.sceneLocationManager.bestLocationEstimate,
                    let position = self.sceneLocationView.currentScenePosition {
                    let translation = bestEstimate.translatedLocation(to: position)
                }
                
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
                
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                        self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                    })
                }
                
                if self.displayDebugging {
                    let bestLocationEstimate = self.sceneLocationView.sceneLocationManager.bestLocationEstimate
                    
                    if bestLocationEstimate != nil {
                        if self.locationEstimateAnnotation == nil {
                            self.locationEstimateAnnotation = MKPointAnnotation()
                            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                        }
                        
                        self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
                    } else {
                        if self.locationEstimateAnnotation != nil {
                            self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                            self.locationEstimateAnnotation = nil
                        }
                    }
                }
                
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
                    centerMapOnUserLocation = false
                } else {
                    
                    let location = touch.location(in: self.view)
                    
                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
                        print("left side of the screen")
                        sceneLocationView.moveSceneHeadingAntiClockwise()
                    } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
                        print("right side of the screen")
                        sceneLocationView.moveSceneHeadingClockwise()
                    } else {
                        let image = UIImage(named: "pin")!
                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
                        annotationNode.scaleRelativeToDistance = true
                        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
                    }
                }
            }
        }
    }
}

//MARK: MKMapViewDelegate
extension ARViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            if pointAnnotation == self.userAnnotation {
                marker.displayPriority = .required
                marker.glyphImage = UIImage(named: "user")
            } else {
                marker.displayPriority = .required
                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "compass")
            }
            
            return marker
        }
        
        return nil
    }
}

//MARK: SceneLocationViewDelegate
extension ARViewController: SceneLocationViewDelegate {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) { }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) { }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) { }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) { }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) { }
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}





