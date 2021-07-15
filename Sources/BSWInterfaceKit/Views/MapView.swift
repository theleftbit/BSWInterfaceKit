//
//  BSWInterfaceKit
//  Created by Pierluigi Cifani on 21/07/2018.
//

#if canImport(UIKit)

import UIKit
import MapKit

@objc(BSWMapView)
@available (iOS 10, *)
@available(iOSApplicationExtension, unavailable)
@available(tvOS, unavailable)
@available(macCatalyst, unavailable)
public class MapView: UIImageView {
    
    private enum Constants {
        static let Distance: CLLocationDistance = 1000
    }
    
    public weak var presenterController: UIViewController? {
        didSet {
            guard presenterController != nil else { return }
            self.isUserInteractionEnabled = true
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        }
    }
    
    public var latitute: Double?
    public var longitude: Double?
    
    public func configureFor(lat: Double, long: Double) {
        self.latitute = lat
        self.longitude = long
        let location = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
        let region = MKCoordinateRegion(center: location, latitudinalMeters: Constants.Distance, longitudinalMeters: Constants.Distance)
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.scale = UIScreen.main.scale
        options.size = self.frame.size
        options.showsBuildings = true
        options.showsPointsOfInterest = true
        let snapshotter = MKMapSnapshotter(options: options)
        let rect = self.bounds
        snapshotter.start { (snapshot, error) in
            guard error == nil, let snapshot = snapshot else { return }
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            let renderer = UIGraphicsImageRenderer(size: options.size, format: format)
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
    
    @objc func onTap() {
        guard let latitude = self.latitute, let longitude = self.longitude,  let presenterController = self.presenterController else {
            return
        }
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let appleMapsAction = UIAlertAction(title: "open-apple-maps".localized, style: .default) { action -> Void in
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: Constants.Distance, longitudinalMeters: Constants.Distance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.openInMaps(launchOptions: options)
        }
        
        actionSheetController.addAction(appleMapsAction)

        let googleMapsURL = URL(string:"comgooglemaps://")!
        if UIApplication.shared.canOpenURL(googleMapsURL) {
            let googleMapsAction = UIAlertAction(title: "open-google-maps".localized, style: .default) { action -> Void in
                let finalURL = URL(string:
                    "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)")!
                UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
            }
            actionSheetController.addAction(googleMapsAction)
        }

        let cancelAction = UIAlertAction(title: "dismiss".localized, style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.popoverPresentationController?.sourceView = self
        presenterController.present(actionSheetController, animated: true) { }
    }
}

#endif
