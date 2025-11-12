import Foundation
import Cadova
import Helical

struct Candle: Shape3D {
    var body: any Geometry3D {
        @Environment(\.tolerance) var tolerance
        @Environment(\.configuration) var config

        let coverThreadInnerHeight = config.platformThreadsHeight + 1
        let innerDiameter = config.candleOuterDiameter - 2 * config.candleWallThickness
        let topHeight = 12.0
        let topInnerDiameter = 11.0
        let topOuterDiameter = topInnerDiameter + 1
        let topInnerHeight = 15.0
        let slopeHeight = (innerDiameter - topInnerDiameter) / 2

        Loft {
            layer(z: 0) {
                Circle(diameter: config.candleOuterDiameter)
            }
            layer(z: config.candleHeight - topHeight) {
                Circle(diameter: config.candleOuterDiameter)
            }
            layer(z: config.candleHeight, interpolation: .circularEaseOut) {
                Circle(diameter: topOuterDiameter)
            }
        }
        .subtracting {
            ThreadedHole(
                thread: config.candleThread,
                depth: coverThreadInnerHeight,
                leadinChamferSize: config.candleThread.depth,
                entryEnds: [.negative]
            )
            .cuttingEdgeProfile(.chamfer(depth: config.candleThread.depth), on: .top) {
                Circle(diameter: config.candleThread.majorDiameter + tolerance)
            }

            Loft {
                layer(z: coverThreadInnerHeight) {
                    Circle(diameter: topInnerDiameter)
                }
                layer(z: config.candleHeight - topInnerHeight - slopeHeight) {
                    Circle(diameter: innerDiameter)
                }
                layer(z: config.candleHeight - topInnerHeight) {
                    Circle(diameter: topInnerDiameter)
                }
                layer(z: config.candleHeight) {
                    Circle(diameter: topInnerDiameter)
                }
            }
        }
        .colored(DisplayColors.candle)
    }
}
