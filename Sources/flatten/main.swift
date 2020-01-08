import topic_workflow
import FileKit
import Foundation

let args = CommandLine.arguments

var workingPath: Path = .current
if args.count > 1 {
    workingPath = Path(rawValue: CommandLine.arguments[1])
}
do {
    try Generate.run(workingPath)
} catch let error as FileKitError {
    print("\(error) \(String(describing: error.error))")
    exit(1)
} catch {
    print("\(error)")
    exit(2)
}
