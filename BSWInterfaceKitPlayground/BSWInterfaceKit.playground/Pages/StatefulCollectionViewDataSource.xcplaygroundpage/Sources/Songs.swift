import Foundation

public struct Song {
    public let name: String
    public let releaseDate: NSDate
    public let thumbnail: NSURL
    
    init(name: String, year: Int, month: Int, day: Int, youtubeID: String) {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let components = NSDateComponents()
        components.year = year
        components.month = month
        components.day = day
        let date = calendar.dateFromComponents(components)!
        
        self.name = name
        self.releaseDate = date
        self.thumbnail = NSURL(string: "http://img.youtube.com/vi/\(youtubeID)/0.jpg")!
    }
}

public func sampleSongs() -> [Song] {
    
    let shakeItOff = Song(
        name: "Shake It Off",
        year: 2014,
        month: 8,
        day: 18,
        youtubeID: "nfWlot6h_JM"
    )
    
    let neverTogheter = Song(
        name: "We Are Never Ever Getting Back Together",
        year: 2012,
        month: 8,
        day: 31,
        youtubeID: "WA4iX5D9Z64"
    )
    
    let wildestDreams = Song(
        name: "Wildest Dreams",
        year: 2015,
        month: 8,
        day: 30,
        youtubeID: "IdneKLhsWOQ"
    )
    
    let style = Song(
        name: "Style",
        year: 2015,
        month: 2,
        day: 13,
        youtubeID: "CmadmM5cOk"
    )
    
    let blankSpace = Song(
        name: "Blank Space",
        year: 2014,
        month: 11,
        day: 2,
        youtubeID: "ORhEE9VVg"
    )
    
    let badBlood = Song(
        name: "Bad Blood",
        year: 2015,
        month: 5,
        day: 17,
        youtubeID: "QcIy9NiNbmo"
    )
    
    return [shakeItOff, neverTogheter, wildestDreams, style, blankSpace, badBlood]
}
