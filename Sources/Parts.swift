import Foundation
import Cadova

func generateModels(for configuration: Configuration) async {
    let packageURL = URL(filePath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
    let outputRoot = packageURL.appending(path: "Models", directoryHint: .isDirectory)

    await Project(root: outputRoot.appending(path: configuration.name), options: .metadata(
        title: "Nordic Advent Candle Bridge (\(configuration.name)",
        description: "Classic Nordic-style electric advent candle bridge",
        author: "Tomas Wincent Franzén",
        license: "MIT License"
    )) {
        if developmentMode {
            await Model("dev-assembled") {
                Body(isSplit: false).assembledBody
            }

            await Model("dev-outline") {
                Body.outline
            }
        }

        if configuration.hasSplitBodyVariant {
            await Model("Main Body, Left") {
                Body(isSplit: true).leftHalf
            }

            await Model("Main Body, Right") {
                Body(isSplit: true).rightHalf
            }
        }

        await Model("Main Body") {
            Body(isSplit: false)
        }

        await Model("Candle Sleeve") {
            Candle()
        }

        await Model("Socket Holder") {
            SocketMount()
        }

        await Model("Bottom Cover") {
            Body.bottomPanel
        }

        await Model("Foot Plate") {
            Foot(hasPowerInlet: false).panel
        }
    } environment: {
        $0.tolerance = 0.2
        $0.circularOverhangMethod = .bridge
        $0.configuration = configuration
    }
}
