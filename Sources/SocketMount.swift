import Foundation
import Cadova
import Helical


struct SocketMount: Shape3D {
    var body: any Geometry3D {
        @Environment(\.tolerance) var tolerance
        @Environment(\.configuration) var config

        let wallThickness = 1.0
        let innerDiameter = config.socketMountThread.minorDiameter - 2 * wallThickness
        let sideHoleDiameter = innerDiameter - 3
        let stemDiameter = config.socketMountThread.minorDiameter - tolerance

        let distanceBottomToHole = 13.6
        let holeDiameter = 3.0 + tolerance
        let distanceFromTopToBulbBody = 19.0

        let topSize = Vector3D(4.6, 10, 5.6)
        let mountSize = Vector3D(6.0, 10, (distanceBottomToHole - topSize.z) * 2)

        let fullHeight = config.candleHeight - distanceFromTopToBulbBody
        let baseHeight = fullHeight - topSize.z - mountSize.z
        let roundingRadius = 0.7

        let wingWidth = 0.5
        let wingDepth = 2.0

        Screw(thread: config.socketMountThread, length: config.platformThreadsHeight)
            .adding {
                Loft {
                    layer(z: config.platformThreadsHeight) {
                        Circle(diameter: stemDiameter)
                    }
                    layer(z: 30.0, interpolation: .easeInOut) {
                        Rectangle(x: mountSize.x, y: stemDiameter)
                            .aligned(at: .center)
                            .intersecting {
                                Circle(diameter: stemDiameter)
                            }
                            .rounded(radius: roundingRadius)
                    }
                    layer(z: fullHeight - topSize.z - 1) {
                        Rectangle(mountSize.xy)
                            .aligned(at: .center)
                            .cuttingEdgeProfile(.fillet(radius: roundingRadius))
                    }
                    layer(z: fullHeight - topSize.z, interpolation: .easeInOut) {
                        Rectangle(topSize.xy)
                            .aligned(at: .center)
                            .cuttingEdgeProfile(.fillet(radius: roundingRadius))
                    }
                    layer(z: fullHeight) {
                        Rectangle(topSize.xy)
                            .aligned(at: .center)
                            .cuttingEdgeProfile(.fillet(radius: roundingRadius))
                    }
                }
                .subtracting {
                    Cylinder(diameter: holeDiameter, height: mountSize.y)
                        .overhangSafe()
                        .rotated(y: 90°)
                        .aligned(at: .centerX)
                        .translated(z: baseHeight + mountSize.z / 2)
                }
                .adding {
                    Polygon.rightTriangle(x: wingDepth, y: wingDepth)
                        .adding {
                            Rectangle(x: wingDepth, y: topSize.z - wingDepth)
                                .aligned(at: .maxY)
                        }
                        .aligned(at: .minY)
                        .extruded(height: wingWidth)
                        .rotated(x: -90°)
                        .aligned(at: .centerY)
                        .translated(x: -1)
                        .rotated(z: 45°)
                        .translated(x: topSize.x / 2, y: topSize.y / 2)
                        .symmetry(over: .xy)
                        .translated(z: fullHeight)
                }
            }
            .subtracting {
                Cylinder(diameter: sideHoleDiameter, height: config.candleHeight)
                    .overhangSafe()
                    .rotated(y: 20°)
                    .translated(z: config.platformThreadsHeight)
                    .symmetry(over: .x)

                Loft {
                    layer(z: 0) { Circle(diameter: innerDiameter) }
                    layer(z: config.platformThreadsHeight + 4) { Circle(diameter: innerDiameter) }
                    layer(z: config.platformThreadsHeight + 10) { Circle(diameter: innerDiameter - 8) }
                }
            }
            .colored(DisplayColors.socketMount)
    }
}
