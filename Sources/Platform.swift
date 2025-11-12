import Foundation
import Cadova
import Helical

enum Platform {
    @GeometryBuilder3D
    static func add(to base: any Geometry3D, at transform: Transform3D) -> any Geometry3D {
        @Environment(\.tolerance) var tolerance
        @Environment(\.configuration) var config

        base.subtracting {
            Cylinder(diameter: config.candleOuterDiameter + tolerance, height: config.platformThreadsHeight)
                .transformed(transform)
        }
        .adding {
            Box(x: config.candleThread.majorDiameter + 5, y: config.depth - 2 * config.wallThickness, z: config.wallThickness)
                .cuttingEdgeProfile(.chamfer(depth: config.wallThickness), on: .bottomLeft)
                .aligned(at: .centerXY, .maxZ)
                .adding {
                    Screw(thread: config.candleThread, length: config.platformThreadsHeight)
                        .cuttingEdgeProfile(.chamfer(depth: 1), on: .top) {
                            Circle(diameter: config.candleThread.majorDiameter)
                        }
                }
                .subtracting {
                    ThreadedHole(thread: config.socketMountThread, depth: config.platformThreadsHeight, entryEnds: [.positive])
                }
                .adding {
                    SocketMount()
                        .inPart(named: "Socket Holders")
                    Candle()
                        .inPart(named: "Candle Sleeves")
                }
                .transformed(transform)
        }
        .subtracting {
            let holeDiameter = config.socketMountThread.minorDiameter - 1.0
            let layerHeight = 0.4
            Cylinder(diameter: holeDiameter, height: config.platformThreadsHeight)
                .adding {
                    Cylinder(diameter: holeDiameter, height: 0.01)
                        .adding {
                            Box(x: config.platformSquareSize, y: config.platformSquareSize, z: 0.001)
                                .aligned(at: .centerXY)
                                .translated(z: -config.wallThickness + layerHeight)
                        }
                        .convexHull()

                    Box(x: config.platformSquareSize, y: config.depth - 2 * config.wallThickness, z: layerHeight)
                        .aligned(at: .centerXY)
                        .translated(z: -config.wallThickness)
                }
                .transformed(transform)
        }
    }
}
