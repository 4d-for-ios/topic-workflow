import Foundation
import FileKit
import SwiftyJSON

struct Topic {
    var name: String
}

extension Topic {

    public func jsonItems(at workingPath: Path) throws -> JSON {
        let path: Path = workingPath + "\(name).json"
        let content = try TextFile(path: path).read()
        let json = JSON(parseJSON: content)
        // XXX if incomplete, get pagination files?
        return json
    }

}
