import Foundation
import Cadova
import Helical

struct Configuration {
    let name: String
    let hasSplitBodyVariant: Bool

    let candlesPerLeg: Int
    let legAngle: Angle
    let height: Double // From bottom to top platform
    let wallThickness: Double

    let depth: Double
    let thickness: Double
    let mountBolt: Bolt

    let bottomPanelInset: Double
    let bottomPanelThickness: Double

    let platformWidth: Double
    let topPlatformWidth: Double
    let topPlatformElevation: Double
    let lastPlatformMarginFactor: Double
    let platformCornerRadius: Double

    let platformSquareSize: Double
    let socketMountThread: ScrewThread
    let candleThread: ScrewThread
    let platformThreadsHeight: Double

    let candleHeight: Double
    let candleWallThickness: Double
    let candleOuterDiameter: Double

    let footSurfaceMargin: Double
    let footHeight: Double
    let footPanelThickness: Double
    let powerInletHoleDiameter: Double
}


extension Configuration {
    var outerTriangleHalf: RightTriangle {
        RightTriangle(leftLeg: heightWithoutFeet - topPlatformElevation, topAngle: legAngle / 2)
    }

    var heightWithoutFeet: Double {
        height - footHeight
    }

    var bottomAngle: Angle { 90° - legAngle / 2 }

    var legLength: Double { outerTriangleHalf.hypotenuse }
    var legBaseWidth: Double { RightTriangle(leftLeg: thickness, bottomAngle: bottomAngle).hypotenuse }
    var zThickness: Double { RightTriangle(leftLeg: thickness, bottomAngle: legAngle / 2).hypotenuse }
    var innerLegLength: Double { (heightWithoutFeet - topPlatformElevation - zThickness) / sin(bottomAngle) }
    var innerLegStart: Double { thickness / tan(legAngle / 2) }

    var halfTriangleWidth: Double { outerTriangleHalf.bottomLeg }

    var platformHoleDiameter: Double { socketMountThread.minorDiameter - 1.0 }
    var bottomPanelScrewPosition: Double { innerLegLength - 9.0 }

    var footSize: Vector3D {
        Vector3D(
            legBaseWidth + footSurfaceMargin * 2,
            depth + footSurfaceMargin * 2,
            footHeight
        )
    }
}

extension Configuration {
    var platformDiagonal: Double { platformWidth / cos(bottomAngle) }

    var platformSpacing: Double {
        (legLength - platformDiagonal / 2 - Double(candlesPerLeg) * platformDiagonal) / (Double(candlesPerLeg) + lastPlatformMarginFactor)
    }

    var platformPositions: [Double] {
        Array(stride(from: platformDiagonal / 2 + platformSpacing, to: legLength, by: platformSpacing + platformDiagonal))
    }

    func platformTransform(index: Int) -> Transform3D {
        .translation(x: platformWidth / 2 - 0.5, z: -0.001)
        .rotated(y: -bottomAngle)
        .translated(x: platformPositions[index])
        .concatenated(with: apexTransform)
    }

    var topPlatformTransform: Transform3D {
        .translation(z: heightWithoutFeet)
    }

    var allPlatformTransforms: [Transform3D] {
        [topPlatformTransform] + (0..<candlesPerLeg).flatMap {
            [platformTransform(index: $0), platformTransform(index: $0).rotated(z: 180°)]
        }
    }

    var apexTransform: Transform3D {
        .rotation(y: 90° - legAngle / 2)
        .translated(z: heightWithoutFeet - topPlatformElevation)
    }

    var apexTransform2D: Transform2D {
        .rotation(-90° + legAngle / 2)
        .translated(y: heightWithoutFeet - topPlatformElevation)
    }
}

extension EnvironmentValues {
    private static let key = Key("AdventCandleBridge.Configuration")

    var configuration: Configuration {
        get { self[Self.key] as! Configuration }
        set { self[Self.key] = newValue }
    }
}
