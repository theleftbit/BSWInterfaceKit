//
//  Created by Michele Restuccia on 12/9/22.
//

import SwiftUI
import NukeUI

public struct LazyPhotoView: View {
    
    private enum Constants {
        static let NormalSpacing: CGFloat = 8
    }
    
    public struct Configuration {
        let aspectRatio: CGFloat
        let shape: Shape
        let backgroundColor: UIColor
        
        public enum Shape: Equatable {
            case rectangular
            case circular
            
            var isCircular: Bool {
                self == .circular
            }
        }
        
        public init(shape: Shape, aspectRatio: CGFloat, backgroundColor: UIColor) {
            self.shape = shape
            self.aspectRatio = aspectRatio
            self.backgroundColor = backgroundColor
        }
    }
    let configuration: Configuration
    let url: URL
    
    public init(url: URL, configuration: Configuration = .init(shape: .rectangular, aspectRatio: 100/80, backgroundColor: .systemGray3)) {
        self.url = url
        self.configuration = configuration
    }
    
    public var body: some View {
        HStack {
            if configuration.shape.isCircular {
                Spacer(minLength: Constants.NormalSpacing)
            }
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizingMode(.aspectFit)
                        .aspectRatio(configuration.aspectRatio, contentMode: .fit)
                } else if state.error != nil {
                    EmptyView()
                } else {
                    if configuration.shape.isCircular {
                        Circle()
                            .foregroundColor(Color(configuration.backgroundColor))
                            .aspectRatio(configuration.aspectRatio, contentMode: .fit)
                    } else {
                        Rectangle()
                            .foregroundColor(Color(configuration.backgroundColor))
                            .aspectRatio(configuration.aspectRatio, contentMode: .fit)
                    }
                }
            }
            if configuration.shape.isCircular {
                Spacer(minLength: Constants.NormalSpacing)
            }
        }
    }
}
