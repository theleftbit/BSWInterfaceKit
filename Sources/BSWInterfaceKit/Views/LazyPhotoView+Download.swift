//
//  Created by Michele Restuccia on 12/9/22.
//

import SwiftUI
import NukeUI

public struct LazyPhotoView: View {
    
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public var body: some View {
        LazyImage(url: url)
    }
}
