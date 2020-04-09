//
//  POIs.swift
//  WayPoint3.0
//
//  Created by ruby carrasco on 3/3/20.
//  Copyright © 2020 SCU. All rights reserved.
//

import Foundation
import MapKit

class POIs: NSObject, MKAnnotation {
  let title: String?
  let locationName: String?
  let coordinate: CLLocationCoordinate2D
  
  init(title: String? = nil, locationName: String? = nil,  coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.coordinate = coordinate
    super.init()
  }
  
  var subtitle: String? {
    return locationName
  }
}
