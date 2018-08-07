//
//  MapView.swift
//  BSWInterfaceKit
//
//  Created by Pierluigi Cifani on 21/07/2018.
//

import UIKit
import MapKit

@objc(BSWMapView)
@available (iOS 10, *)
public class MapView: UIImageView {
    public init() {
        super.init(image: UIImage.interfaceKitImageNamed("grid-placeholder"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureFor(lat: Double, long: Double) {
        let options = MKMapSnapshotter.Options()
        let location = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        options.region = region
        options.scale = UIScreen.main.scale
        options.size = self.frame.size
        options.showsBuildings = true
        options.showsPointsOfInterest = true
        let snapshotter = MKMapSnapshotter(options: options)
        let rect = self.bounds
        snapshotter.start { (snapshot, error) in
            guard error == nil, let snapshot = snapshot else { return }
            
            let renderer = UIGraphicsImageRenderer(size: options.size)
            let image = renderer.image(actions: { (context) in
                snapshot.image.draw(at: .zero)
                
                let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                let pinImage = pinView.image
                
                var point = snapshot.point(for: location)
                
                if rect.contains(point) {
                    let pinCenterOffset = pinView.centerOffset
                    point.x -= pinView.bounds.size.width / 2
                    point.y -= pinView.bounds.size.height / 2
                    point.x += pinCenterOffset.x
                    point.y += pinCenterOffset.y
                    pinImage?.draw(at: point)
                }
            })
            
            self.image = image
        }
    }
}

