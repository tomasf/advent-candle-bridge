import Foundation
import Cadova
import Helical

struct Body: Shape3D {
    let isSplit: Bool

    static var outline: any Geometry2D {
        @Environment(\.configuration) var config

        return Polygon(BezierPath2D(from: [0, config.heightWithoutFeet]) {
            line(x: config.topPlatformWidth / 2)
            for index in 0..<config.candlesPerLeg {
                let outerPoint = config.platformTransform(index: index).apply(to: [config.platformWidth / 2, 0, 0])
                curve(controlX: .unchanged, controlY: outerPoint.z, endX: outerPoint.x - 10, endY: outerPoint.z)
                line(x: outerPoint.x)
            }
            curve(controlX: .unchanged, controlY: 10, endX: config.halfTriangleWidth, endY: 0)
            line(x: config.halfTriangleWidth - config.legBaseWidth)
            line(x: 0, y: config.heightWithoutFeet - config.topPlatformElevation - config.zThickness)
        })
        .symmetry(over: .x)
        .whileMasked(y: (config.platformCornerRadius + 10)...) {
            $0.rounded(outsideRadius: config.platformCornerRadius)
        }
    }

    @GeometryBuilder3D
    var assembledBody: any Geometry3D {
        @Environment(\.tolerance) var tolerance
        @Environment(\.configuration) var config

        Self.outline
            .offset(amount: -config.wallThickness, style: .miter) { original, offset in
                Stack(.z) {
                    original.extruded(height: config.wallThickness)
                    original.subtracting { offset }
                        .extruded(height: config.depth -  config.wallThickness * 2)
                    original.extruded(height: config.wallThickness)
                }
                .aligned(at: .centerZ)
            }
            .rotated(x: 90°)
            .subtracting {
                Box(x: config.legLength, y: config.depth - 2 * config.wallThickness, z: config.thickness)
                    .aligned(at: .centerY, .maxZ)
                    .translated(x: config.platformDiagonal / 2 + config.wallThickness, z: -config.wallThickness - 3)
                    .transformed(config.apexTransform)
                    .symmetry(over: .x)
            }
            .replaced {
                config.allPlatformTransforms.reduce($0) {
                    Platform.add(to: $0, at: $1)
                }
            }
            .adding {
                // Panel mount rails
                let panelExtension = 100.0
                let railWidth = 1.2

                Rectangle(x: config.innerLegLength + 2 * panelExtension, y: config.bottomPanelInset - tolerance)
                    .clonedAt(y: config.bottomPanelInset + config.bottomPanelThickness)
                    .translated(x: -panelExtension)
                    .translated(x: config.innerLegStart, y: -config.thickness)
                    .transformed(config.apexTransform2D)
                    .within(x: 0..., y: (-config.wallThickness)...)
                    .extruded(height: railWidth)
                    .rotated(x: 90°)
                    .translated(y: config.depth / 2 - config.wallThickness)
                    .symmetry(over: .xy)

                // Panel mount screw
                let screwMountSize = Vector3D(10.0, config.depth - config.wallThickness * 2, 10.0)
                let supportPosition = config.innerLegLength / 2

                Box(screwMountSize)
                    .aligned(at: .centerXY)
                    .cuttingEdgeProfile(.fillet(radius: 4), on: .top, along: .y)
                    .subtracting {
                        ThreadedHole(thread: config.mountBolt.thread, depth: config.mountBolt.length)
                    }
                    .translated(
                        x: config.innerLegStart + config.bottomPanelScrewPosition,
                        z: -config.thickness + config.bottomPanelInset + config.bottomPanelThickness
                    )
                    .transformed(config.apexTransform)
                    .distributed(at: [0°, 180°], around: .z)

                Box(screwMountSize)
                    .aligned(at: .centerXY)
                    .cuttingEdgeProfile(.fillet(radius: 4), on: .top, along: .y)
                    .translated(
                        x: config.innerLegStart + supportPosition,
                        z: -config.thickness + config.bottomPanelInset + config.bottomPanelThickness
                    )
                    .transformed(config.apexTransform)
                    .distributed(at: [0°, 180°], around: .z)

                if !isSplit {
                    let supportInset = 12.0
                    Cylinder(diameter: 8, height: config.depth - config.wallThickness * 2)
                        .rotated(x: 90°)
                        .aligned(at: .centerY)
                        .translated(z: config.heightWithoutFeet - config.topPlatformElevation - config.zThickness + supportInset)
                }

                Self.bottomPanelInternal
                    .symmetry(over: .x)
                    .colored(.white)
                    .inPart(named: "Bottom Covers")
            }
            .translated(z: config.footSize.z)
            .adding {
                Foot.feet
            }
            .subtracting {
                // Foot open roof
                Box(
                    x: config.legLength + config.wallThickness * 1.5,
                    y: config.depth - config.wallThickness * 2,
                    z: config.thickness - config.bottomPanelInset - config.wallThickness + tolerance
                )
                .aligned(at: .centerY, .maxZ)
                .translated(z: -config.wallThickness)
                .transformed(config.apexTransform)
                .within(z: (-config.wallThickness)...config.wallThickness)
                .translated(z: config.footSize.z)
                .symmetry(over: .x)
            }
            .colored(DisplayColors.body)
    }

    var body: any Geometry3D {
        assembledBody.removingParts()
    }

    @GeometryBuilder3D
    private static var bottomPanelInternal: any Geometry3D {
        @Environment(\.tolerance) var tolerance
        @Environment(\.configuration) var config
        let panelExtension = 10.0

        Box(
            x: config.innerLegLength + 2 * panelExtension,
            y: config.depth - 2 * config.wallThickness - tolerance * 2,
            z: config.bottomPanelThickness - tolerance
        )
        .aligned(at: .centerY)
        .translated(x: -panelExtension)
        .subtracting {
            config.mountBolt.clearanceHole(depth: config.bottomPanelThickness, recessedHead: true)
                .withCircularOverhangMethod(.none)
                .translated(x: config.bottomPanelScrewPosition, z: 0.6)
        }
        .translated(x: config.innerLegStart, z: -config.thickness + config.bottomPanelInset)
        .transformed(config.apexTransform)
        .within(x: (tolerance / 2)..., z: (-config.wallThickness)...)
        .colored(DisplayColors.bottomPanel)
    }

    @GeometryBuilder3D
    static var bottomPanel: any Geometry3D {
        @Environment(\.configuration) var config

        bottomPanelInternal
            .transformed(config.apexTransform.inverse)
            .aligned(at: .min)
    }
}

extension Body {
    private static let splitOffset = 10.0

    @GeometryBuilder3D
    private static var splitMask: any Geometry3D { Union {
        @Environment(\.tolerance) var tolerance
        @Environment(\.configuration) var config

        let fullSize = Vector3D(
            x: config.halfTriangleWidth * 2,
            y: config.footSize.y + 1,
            z: config.height + config.platformThreadsHeight + 1
        )
        let wallOffset = 1.0

        Box(fullSize)
            .translated(x: tolerance / 2)
            .aligned(at: .centerY)
            .adding {
                Box(
                    x: config.legLength,
                    y: config.depth - 2 * config.wallThickness + 2 * wallOffset - tolerance,
                    z: config.thickness * 2
                )
                .aligned(at: .centerXY)
                .translated(z: -config.thickness)
                .transformed(config.apexTransform)
                .translated(z: config.footSize.z + splitOffset)
            }
            .subtracting {
                Box(fullSize)
                    .aligned(at: .maxX, .centerY)
                    .translated(x: -config.topPlatformWidth / 2 + config.platformCornerRadius + tolerance / 2)
            }
    }}

    @GeometryBuilder3D
    private var bodyWithConnector: any Geometry3D {
        @Environment(\.configuration) var config

        let holeOffsetRadius = 6.0
        let holeXOffset = 0.5
        let connectorSize = Vector3D(x: 20.0, y: config.depth - 2 * config.wallThickness, z: 10.0)
        let xOffset = 1.5
        let frontThickness = 3.0

        self.adding {
            Box(connectorSize)
                .cuttingEdgeProfile(.fillet(radius: 3), on: [.topLeft, .bottomLeft])
                .aligned(at: .centerXY)
                .subtracting {
                    let clearanceInset = 0.6
                    config.mountBolt.clearanceHole(depth: frontThickness - clearanceInset + 0.001, recessedHead: true)
                        .translated(z: clearanceInset)
                        .adding {
                            ThreadedHole(thread: config.mountBolt.thread, depth: connectorSize.z - frontThickness)
                                .translated(z: frontThickness)
                        }
                        .translated(x: holeOffsetRadius)
                        .repeated(around: .z, count: 3)
                        .rotated(z: 60°)
                        .aligned(at: .centerX)
                        .translated(x: holeXOffset)
                }
                .aligned(at: .maxX, .centerY)
                .translated(x: config.innerLegStart + xOffset, z: -config.thickness - frontThickness)
                .transformed(config.apexTransform)
                .translated(z: config.footSize.z + Self.splitOffset)
        }
    }

    @GeometryBuilder3D
    var rightHalf: any Geometry3D {
        bodyWithConnector
            .intersecting { Self.splitMask }
            .colored(DisplayColors.body)
    }

    @GeometryBuilder3D
    var leftHalf: any Geometry3D {
        bodyWithConnector
            .subtracting { Self.splitMask.withTolerance(0) }
            .colored(DisplayColors.body)
    }
}

