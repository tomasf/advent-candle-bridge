import Foundation
import Helical

let developmentMode = true
await generateModels(for: .large)
await generateModels(for: .small)
