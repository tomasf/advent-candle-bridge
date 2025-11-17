import Foundation
import Helical

let developmentMode = false
await generateModels(for: .large)
await generateModels(for: .small)
