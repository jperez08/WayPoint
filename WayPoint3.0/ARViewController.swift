//
//  ARViewController.swift
//  WayPoint3.0
//
//

import Foundation
import MapKit
import CoreLocation
import UIKit
import SceneKit
import ARKit
import AVFoundation
import ARCL

@available(iOS 11.0, *)

class ARViewController: UIViewController ,ARSCNViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var removePlanes: UIButton!
  
    
    var steps = [MKRoute.Step]() //array for directions
    var currentCoordinate: CLLocationCoordinate2D!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var stepCounter = 0
    
    
    var dest: POIs?
    var currentLocation = CLLocation()
    let locationManager = CLLocationManager()
    
    
    var showMap = true
    
    @IBOutlet var contentView: UIView!

    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    var routes: [MKRoute]?
    var centerMapOnUserLocation: Bool = true

    let displayDebugging = false
    let sceneLocationView = SceneLocationView()
    
    
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
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = locations.last else {return}
        currentLocation = location
        mapView.userTrackingMode = .followWithHeading
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
              let viewController = storyboard?.instantiateViewController(withIdentifier : "mainView")as! ARViewController
              let secondsToDelay = 1.0
              DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                 self.present(viewController, animated: true)
               
              }
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
      createAlert()
      print( "latitude = ", currentLocation.coordinate.latitude, "   longitude = " , currentLocation.coordinate.longitude)
 
       
        let heading = locationManager.headingOrientation.rawValue
      
        print("  current orientation: " , heading);
 
        
    //------directions right here
        let request = createDirectionRequest()
        let directions = MKDirections(request:request)
        directions.calculate{ (response, error) in
        print("got directions")
            guard let response = response else {return}
            guard let primaryRoute = response.routes.first else {return}
            self.routes = response.routes
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
            let initMessage = "In \(self.steps[1].distance) meters, \(self.steps[1].instructions)."
            self.directionLabel.text = initMessage
            let speechUtterance = AVSpeechUtterance(string: initMessage)
            self.speechSynthesizer.speak(speechUtterance)
            self.stepCounter += 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        //show the user's current location
        //mapView.userTrackingMode = .followWithHeading
        
        mapView.delegate = self as MKMapViewDelegate
        mapView.addAnnotation(dest!)
        mapView.showsCompass = true
        checkLocationAuthorizationStatus()
        

                NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                                       object: nil,
                                                       queue: nil) { [weak self] _ in
                                                        self?.pauseAnimation()
                }
                // swiftlint:disable:next discarded_notification_center_observer
                NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                       object: nil,
                                                       queue: nil) { [weak self] _ in
                                                        self?.restartAnimation()
                }

                sceneLocationView.showFeaturePoints = displayDebugging
                sceneLocationView.arViewDelegate = self
                
                addSceneModels()
                
                contentView.addSubview(sceneLocationView)
                contentView.addSubview(self.mapView)
                sceneLocationView.frame = contentView.bounds
    
        
    }
    
    func createAlert(){
        let alert = UIAlertController(title: "Exercise User Discretion", message: "This application may lead you through walls, ponds, fountains, and new construction zones. Please be careful when following the highlighted path", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion:nil)
    }

    func pauseAnimation() {
        print("pause")
        sceneLocationView.pause()
    }

    func restartAnimation() {
        print("run")
        sceneLocationView.run()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = contentView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseAnimation() // added this function
    }
       
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

//Project Dent
extension ARViewController {

    // Adds ARKit models to the scene
    func addSceneModels() {
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }

        let box1 = SCNBox(width: 1, height: 0.2, length: 5, chamferRadius: 0.25)
        box1.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(1.0)

        //Show route if it exists
        if let routes = routes {
            print("There's a route!")
            sceneLocationView.addRoutes(routes: routes) { distance -> SCNBox in
                let box1 = SCNBox(width: 1.75, height: 0.5, length: distance, chamferRadius: 0.25)

                box1.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.6)
                return box1
            }
        } else {
            print("Theres nooooo route!!!!")
          
            }

        //helps improve the appearance of 3D line
        sceneLocationView.autoenablesDefaultLighting = true
    }

}


let locationManager: CLLocationManager = {
  $0.requestWhenInUseAuthorization()
  $0.startUpdatingLocation()
  $0.startUpdatingHeading()
  return $0
}(CLLocationManager())


