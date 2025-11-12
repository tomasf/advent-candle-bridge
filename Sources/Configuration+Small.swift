import Cadova
import Helical

extension Configuration {
    static let small = Configuration(
        name: "Small",
        hasSplitBodyVariant: false,

        candlesPerLeg: 2,
        legAngle: 90°,
        height: 170,

        wallThickness: 2.5,

        depth: 30,
        thickness: 30,
        mountBolt: .phillipsCountersunk(.m3, length: 16),

        bottomPanelInset: 2.5,
        bottomPanelThickness: 2.5,

        platformWidth: 32,
        topPlatformWidth: 45,
        topPlatformElevation: 8.0,
        lastPlatformMarginFactor: 0.2,
        platformCornerRadius: 4,

        platformSquareSize: 10,
        socketMountThread: ScrewThread(pitch: 1.5, majorDiameter: 14, minorDiameter: 13, form: .trapezoidal(angle: 90°, crestWidth: 0.2)),
        candleThread: ScrewThread(pitch: 1.5, majorDiameter: 18, minorDiameter: 17, form: .trapezoidal(angle: 90°, crestWidth: 0.2)),
        platformThreadsHeight: 7,

        candleHeight: 90,
        candleWallThickness: 1.5,
        candleOuterDiameter: 20,

        footSurfaceMargin: 8,
        footHeight: 18,
        footPanelThickness: 3,
        powerInletHoleDiameter: 8
    )
}
