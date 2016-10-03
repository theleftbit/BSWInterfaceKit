import Foundation

public struct Song {
    public let title: String
    public let songLenght: TimeInterval
    public let artWorkURL: String
    
    public init(title: String, songLenght: TimeInterval, artWorkURL: String) {
        self.title = title
        self.songLenght = songLenght
        self.artWorkURL = artWorkURL
    }
}
