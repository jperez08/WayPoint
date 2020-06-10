//
//  ViewController.swift
//  WayPoint3.0
//
//

import UIKit
import MapKit


class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
   
    
    //constant radius
    let regionRadius: CLLocationDistance = 500
    //helper method
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
    }
    
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
        //set default view to SCU
        let initialLocation = CLLocation(latitude:
            37.3490062, longitude: -121.9395670)
        centerMapOnLocation(location: initialLocation)
       
        mapView.delegate = self
        
        //Point of Interest (POI) objects to show on map
        let Benson = POIs(title: "Benson Center",
                           locationName: "SCU",
                           coordinate: CLLocationCoordinate2D(latitude: 37.347726, longitude: -121.939435))
        mapView.addAnnotation(Benson)
        
        let Daly = POIs(title: "Daly Science",
                                  locationName: "SCU",
                                  coordinate: CLLocationCoordinate2D(latitude: 37.350416, longitude: -121.940879))
               mapView.addAnnotation(Daly)
        
        let Heaf = POIs(title: "Heafey/Bergin",
                           locationName: "SCU",
                           coordinate: CLLocationCoordinate2D(latitude: 37.349169, longitude: -121.939637))
        mapView.addAnnotation(Heaf)
        
        let Kenna = POIs(title: "Kenna",
                                  locationName: "SCU",
                                  coordinate: CLLocationCoordinate2D(latitude: 37.348858, longitude: -121.939482))
        mapView.addAnnotation(Kenna)
        
        let Lucas = POIs(title: "Lucas Hall",
                                  locationName: "SCU",
                                  coordinate: CLLocationCoordinate2D(latitude: 37.351107, longitude: -121.939586))
               mapView.addAnnotation(Lucas)
       
        let Mayer = POIs(title: "Mayer Theatre",
                           locationName: "SCU",
                           coordinate: CLLocationCoordinate2D(latitude: 37.3497994, longitude: -121.9424801))
        mapView.addAnnotation(Mayer)
        
        let Mission = POIs(title: "Mission Church",
                                  locationName: "SCU",
                                  coordinate: CLLocationCoordinate2D(latitude: 37.3493061, longitude: -121.9413858))
               mapView.addAnnotation(Mission)
        
        let Music = POIs(title: "Music & Dance",
                           locationName: "SCU",
                           coordinate: CLLocationCoordinate2D(latitude: 37.3501323, longitude: -121.9425096))
        mapView.addAnnotation(Music)
        
        let Nobili = POIs(title: "Nobili Hall",
                           locationName: "SCU",
                           coordinate: CLLocationCoordinate2D(latitude: 37.3490084, longitude: -121.9423413))
        mapView.addAnnotation(Nobili)
        
        let Oconn = POIs(title: "O'Connor Hall",
                                        locationName: "SCU",
                                        coordinate: CLLocationCoordinate2D(latitude: 37.349943, longitude: -121.941604))
                     mapView.addAnnotation(Oconn)
        
        let StJoe = POIs(title: "Saint Joseph's",
                           locationName: "SCU",
                           coordinate: CLLocationCoordinate2D(latitude: 37.3488224, longitude: -121.9409667))
        mapView.addAnnotation(StJoe)
        
        
        let Vari = POIs(title: "Vari Hall",
                           locationName: "SCU",
                           coordinate: CLLocationCoordinate2D(latitude: 37.350438, longitude: -121.939261))
        mapView.addAnnotation(Vari)
        
        //annotation for testing purposes
        let Corner = POIs(title: "Corner Business",
                           locationName: "Sj",
                           coordinate: CLLocationCoordinate2D(latitude: 37.2975493, longitude: -121.8382150))
        mapView.addAnnotation(Corner)
       
    }
}


func directionsRequest(to mapLocation: MKMapItem) -> MKDirections.Request {

    let request = MKDirections.Request()
    request.source = MKMapItem.forCurrentLocation()
    request.destination = mapLocation
    request.requestsAlternateRoutes = false

    let directions = MKDirections(request: request)

    directions.calculate(completionHandler: { response, error in
     
        if let error = error {
            return print("Error getting directions: \(error.localizedDescription)")
        }
       
    })
    return request
    
}

extension ViewController: MKMapViewDelegate {
    
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    guard let annotation = annotation as? POIs else { return nil }
    
    
    let identifier = "marker"
    var view: MKMarkerAnnotationView
    
    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      as? MKMarkerAnnotationView {
      dequeuedView.annotation = annotation
      view = dequeuedView
    } else {
      
      view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      view.canShowCallout = true
      view.calloutOffset = CGPoint(x: -5, y: 5)
      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    return view
  }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
        
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier : "ARV")as! ARViewController
        
        
        
        viewController.dest = view.annotation as? POIs
        
        var dest2: POIs?
        dest2 = view.annotation as? POIs
        let destinationCoordinate = dest2!.coordinate
        let destinationlocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: destinationlocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request:request)
        directions.calculate{ (response, error) in
        print("got directions")
            guard let response = response else {return}
            //guard let primaryRoute = response.routes.first else {return}
            viewController.routes = response.routes
        }
        
        self.present(viewController, animated: true)

    }
    
}


