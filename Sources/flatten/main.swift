import topic_workflow
import FileKit

let workingPath: Path = "/Users/phimage/topic-workflow/"
do {
    try Generate.run(workingPath)
} catch let error as FileKitError {
    print("\(error) \(String(describing: error.error))")
} catch {
    print("\(error)")
}
