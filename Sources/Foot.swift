import Foundation
import Cadova
import Helical

struct Foot: Shape3D {
    let hasPowerInlet: Bool

    @GeometryBuilder3D
    static var feet: any Geometry3D {
        @Environment(\.configuration) var config
        
        Foot(hasPowerInlet: true)
            .translated(x: config.halfTriangleWidth - config.legBaseWidth / 2)

        Foot(hasPowerInlet: false)
            .translated(x: config.halfTriangleWidth - config.legBaseWidth / 2)
            .rotated(z: 180°)
    }

    var body: any Geometry3D {
        @Environment(\.tolerance) var tolerance
        @Environment(\.configuration) var config

        let panelMountInset = 5.0
        let panelMountBottomInset = 0.8
        let footChamferDepth = 3.0

        Box(config.footSize)
            .cuttingEdgeProfile(.chamfer(depth: footChamferDepth), on: [.topRight, .topFront, .topBack])
            .aligned(at: .centerXY)
            .subtracting {
                Box(
                    x: config.footSize.x - 2 * config.wallThickness,
                    y: config.depth - 2 * config.wallThickness,
                    z: config.footSize.z - config.wallThickness - config.footPanelThickness
                )
                .aligned(at: .centerXY)
                .translated(z: config.footPanelThickness)

                config.mountBolt
                    .clearanceHole(depth: config.footPanelThickness - panelMountBottomInset, recessedHead: true)
                    .translated(config.footSize.xy / 2 - panelMountInset, z: panelMountBottomInset)
                    .symmetry(over: .xy)

                ThreadedHole(
                    thread: config.mountBolt.thread,
                    depth: config.mountBolt.length - config.footPanelThickness + panelMountBottomInset + 0.4
                )
                .translated(config.footSize.xy / 2 - panelMountInset, z: config.footPanelThickness)
                .symmetry(over: .xy)

                if hasPowerInlet {
                    Cylinder(diameter: config.powerInletHoleDiameter, height: config.wallThickness)
                        .overhangSafe()
                        .rotated(y: -90°)
                        .translated(x: config.footSize.x / 2, z: config.footSize.z / 2)
                }
            }
            .split(along: .z(config.footPanelThickness)) { main, panel in
                main
                panel
                    .colored(DisplayColors.body)
                    .inPart(named: "Foot Plates")
            }
    }

    var panel: any Geometry3D {
        self.detachingPart(named: "Foot Plates") { $1 }
    }
}
