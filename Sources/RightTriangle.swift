import Foundation
import Cadova

/// A helper for working with right triangles.
///
/// Coordinate convention:
/// - The right angle is at the origin (0, 0).
/// - `bottomLeg` lies along the positive X axis.
/// - `leftLeg` lies along the positive Y axis.
/// - The hypotenuse connects (bottomLeg, 0) to (0, leftLeg).
///
/// You can initialize using any two independent values that include at least one side
/// (two sides, or one side and one acute angle). The remaining properties are solved.
///
public struct RightTriangle: Sendable, Hashable, Codable {
    /// The leg along the positive X axis (adjacent to the bottom edge).
    public let bottomLeg: Double

    /// The leg along the positive Y axis (adjacent to the left edge).
    public let leftLeg: Double

    /// The side opposite the right angle (the longest side).
    public let hypotenuse: Double

    /// The acute angle at the top-left vertex (opposite `bottomLeg`).
    public let topAngle: Angle

    /// The acute angle at the bottom-right vertex (opposite `leftLeg`).
    public let bottomAngle: Angle

    private init(bottomLeg: Double, leftLeg: Double, hypotenuse: Double, topAngle: Angle, bottomAngle: Angle) {
        self.bottomLeg = bottomLeg
        self.leftLeg = leftLeg
        self.hypotenuse = hypotenuse
        self.topAngle = topAngle
        self.bottomAngle = bottomAngle
    }
}

public extension RightTriangle {
    /// Initialize a right triangle from both legs.
    ///
    /// - Parameters:
    ///   - bottomLeg: Length of the horizontal leg along the +X axis. Must be positive and finite.
    ///   - leftLeg: Length of the vertical leg along the +Y axis. Must be positive and finite.
    ///
    init(bottomLeg: Double, leftLeg: Double) {
        precondition(bottomLeg.isFinite && bottomLeg > 0, "bottomLeg must be a positive, finite number")
        precondition(leftLeg.isFinite && leftLeg > 0, "leftLeg must be a positive, finite number")
        let hypotenuse = hypot(bottomLeg, leftLeg)

        self.init(
            bottomLeg: bottomLeg,
            leftLeg: leftLeg,
            hypotenuse: hypotenuse,
            topAngle: asin(bottomLeg / hypotenuse),
            bottomAngle: asin(leftLeg / hypotenuse)
        )
    }

    /// Initialize a right triangle from the bottom leg and the hypotenuse.
    ///
    /// - Parameters:
    ///   - bottomLeg: Length of the horizontal leg along the +X axis. Must be positive and finite.
    ///   - hypotenuse: Length of the hypotenuse (longest side). Must be positive, finite, and greater than `bottomLeg`.
    ///
    init(bottomLeg: Double, hypotenuse: Double) {
        precondition(bottomLeg.isFinite && bottomLeg > 0, "bottomLeg must be a positive, finite number")
        precondition(hypotenuse.isFinite && hypotenuse > 0, "hypotenuse must be a positive, finite number")
        precondition(hypotenuse > bottomLeg, "Hypotenuse must be greater than bottomLeg")

        self.init(
            bottomLeg: bottomLeg,
            leftLeg: sqrt(hypotenuse * hypotenuse - bottomLeg * bottomLeg),
            hypotenuse: hypotenuse,
            topAngle: asin(bottomLeg / hypotenuse),
            bottomAngle: 90° - asin(bottomLeg / hypotenuse)
        )
    }

    /// Initialize a right triangle from the left leg and the hypotenuse.
    ///
    /// - Parameters:
    ///   - leftLeg: Length of the vertical leg along the +Y axis. Must be positive and finite.
    ///   - hypotenuse: Length of the hypotenuse (longest side). Must be positive, finite, and greater than `leftLeg`.
    ///
    init(leftLeg: Double, hypotenuse: Double) {
        precondition(leftLeg.isFinite && leftLeg > 0, "leftLeg must be a positive, finite number")
        precondition(hypotenuse.isFinite && hypotenuse > 0, "hypotenuse must be a positive, finite number")
        precondition(hypotenuse > leftLeg, "Hypotenuse must be greater than leftLeg")

        self.init(
            bottomLeg: sqrt(hypotenuse * hypotenuse - leftLeg * leftLeg),
            leftLeg: leftLeg,
            hypotenuse: hypotenuse,
            topAngle: 90° - asin(leftLeg / hypotenuse),
            bottomAngle: asin(leftLeg / hypotenuse)
        )
    }

    /// Initialize a right triangle from the bottom leg and the top angle.
    ///
    /// - Parameters:
    ///   - bottomLeg: Length of the horizontal leg along the +X axis. Must be positive and finite.
    ///   - topAngle: Acute angle at the top-left vertex (opposite `bottomLeg`). Must be in (0°, 90°).
    ///
    init(bottomLeg: Double, topAngle: Angle) {
        precondition(bottomLeg.isFinite && bottomLeg > 0, "bottomLeg must be a positive, finite number")
        precondition(topAngle.degrees.isFinite, "topAngle must be finite")
        precondition(topAngle > 0° && topAngle < 90°, "topAngle must be in (0°, 90°)")

        let s = sin(topAngle)
        precondition(s > 0, "Invalid topAngle leads to zero/negative sine")
        let hypotenuse = bottomLeg / s

        self.init(
            bottomLeg: bottomLeg,
            leftLeg: sqrt(max(0, hypotenuse * hypotenuse - bottomLeg * bottomLeg)),
            hypotenuse: hypotenuse,
            topAngle: topAngle,
            bottomAngle: 90° - topAngle
        )
    }

    /// Initialize a right triangle from the bottom leg and the bottom angle.
    ///
    /// - Parameters:
    ///   - bottomLeg: Length of the horizontal leg along the +X axis. Must be positive and finite.
    ///   - bottomAngle: Acute angle at the bottom-right vertex (opposite `leftLeg`). Must be in (0°, 90°).
    ///
    init(bottomLeg: Double, bottomAngle: Angle) {
        precondition(bottomLeg.isFinite && bottomLeg > 0, "bottomLeg must be a positive, finite number")
        precondition(bottomAngle.degrees.isFinite, "bottomAngle must be finite")
        precondition(bottomAngle > 0° && bottomAngle < 90°, "bottomAngle must be in (0°, 90°)")

        self.init(bottomLeg: bottomLeg, topAngle: 90° - bottomAngle)
    }

    /// Initialize a right triangle from the left leg and the top angle.
    ///
    /// - Parameters:
    ///   - leftLeg: Length of the vertical leg along the +Y axis. Must be positive and finite.
    ///   - topAngle: Acute angle at the top-left vertex (opposite `bottomLeg`). Must be in (0°, 90°).
    ///
    init(leftLeg: Double, topAngle: Angle) {
        precondition(leftLeg.isFinite && leftLeg > 0, "leftLeg must be a positive, finite number")
        precondition(topAngle.degrees.isFinite, "topAngle must be finite")
        precondition(topAngle > 0° && topAngle < 90°, "topAngle must be in (0°, 90°)")

        self.init(leftLeg: leftLeg, bottomAngle: 90° - topAngle)
    }

    /// Initialize a right triangle from the left leg and the bottom angle.
    ///
    /// - Parameters:
    ///   - leftLeg: Length of the vertical leg along the +Y axis. Must be positive and finite.
    ///   - bottomAngle: Acute angle at the bottom-right vertex (opposite `leftLeg`). Must be in (0°, 90°).
    ///
    init(leftLeg: Double, bottomAngle: Angle) {
        precondition(leftLeg.isFinite && leftLeg > 0, "leftLeg must be a positive, finite number")
        precondition(bottomAngle.degrees.isFinite, "bottomAngle must be finite")
        precondition(bottomAngle > 0° && bottomAngle < 90°, "bottomAngle must be in (0°, 90°)")
        let hypotenuse = leftLeg / sin(bottomAngle)

        self.init(
            bottomLeg: sqrt(max(0, hypotenuse * hypotenuse - leftLeg * leftLeg)),
            leftLeg: leftLeg,
            hypotenuse: hypotenuse,
            topAngle: 90° - bottomAngle,
            bottomAngle: bottomAngle
        )
    }

    /// Initialize a right triangle from the hypotenuse and the top angle.
    ///
    /// - Parameters:
    ///   - hypotenuse: Length of the hypotenuse (longest side). Must be positive and finite.
    ///   - topAngle: Acute angle at the top-left vertex (opposite `bottomLeg`). Must be in (0°, 90°).
    ///
    init(hypotenuse: Double, topAngle: Angle) {
        precondition(hypotenuse.isFinite && hypotenuse > 0, "hypotenuse must be a positive, finite number")
        precondition(topAngle.degrees.isFinite, "topAngle must be finite")
        precondition(topAngle > 0° && topAngle < 90°, "topAngle must be in (0°, 90°)")

        self.init(
            bottomLeg: hypotenuse * sin(topAngle),
            leftLeg: hypotenuse * cos(topAngle),
            hypotenuse: hypotenuse,
            topAngle: topAngle,
            bottomAngle: 90° - topAngle
        )
    }

    /// Initialize a right triangle from the hypotenuse and the bottom angle.
    ///
    /// - Parameters:
    ///   - hypotenuse: Length of the hypotenuse (longest side). Must be positive and finite.
    ///   - bottomAngle: Acute angle at the bottom-right vertex (opposite `leftLeg`). Must be in (0°, 90°).
    ///
    init(hypotenuse: Double, bottomAngle: Angle) {
        precondition(hypotenuse.isFinite && hypotenuse > 0, "hypotenuse must be a positive, finite number")
        precondition(bottomAngle.degrees.isFinite, "bottomAngle must be finite")
        precondition(bottomAngle > 0° && bottomAngle < 90°, "bottomAngle must be in (0°, 90°)")

        self.init(
            bottomLeg: hypotenuse * cos(bottomAngle),
            leftLeg: hypotenuse * sin(bottomAngle),
            hypotenuse: hypotenuse,
            topAngle: 90° - bottomAngle,
            bottomAngle: bottomAngle
        )
    }
}

extension RightTriangle: Area, Perimeter {
    /// The area of the triangle: 0.5 × `bottomLeg` × `leftLeg`.
    public var area: Double { 0.5 * bottomLeg * leftLeg }

    /// The perimeter of the triangle: `bottomLeg` + `leftLeg` + `hypotenuse`.
    public var perimeter: Double { bottomLeg + leftLeg + hypotenuse }

    /// The inradius (radius of the inscribed circle): (`bottomLeg` + `leftLeg` − `hypotenuse`) / 2.
    public var inradius: Double { (bottomLeg + leftLeg - hypotenuse) / 2 }

    /// The circumradius (radius of the circumscribed circle): `hypotenuse` / 2.
    public var circumradius: Double { hypotenuse / 2 }
}

public extension RightTriangle {
    /// Returns a new triangle where `bottomLeg` is set to `newBottomLeg`,
    /// uniformly scaling all sides so that the acute angles remain unchanged.
    ///
    /// - Parameter newBottomLeg: The desired length for the bottom leg. Must be positive and finite.
    /// - Returns: A new `RightTriangle` with the same angles and scaled side lengths.
    func withBottomLeg(_ newBottomLeg: Double) -> RightTriangle {
        precondition(newBottomLeg.isFinite && newBottomLeg > 0, "newBottomLeg must be a positive, finite number")
        let scale = newBottomLeg / bottomLeg
        return RightTriangle(
            bottomLeg: newBottomLeg,
            leftLeg: leftLeg * scale,
            hypotenuse: hypotenuse * scale,
            topAngle: topAngle,
            bottomAngle: bottomAngle
        )
    }

    /// Returns a new triangle where `leftLeg` is set to `newLeftLeg`,
    /// uniformly scaling all sides so that the acute angles remain unchanged.
    ///
    /// - Parameter newLeftLeg: The desired length for the left leg. Must be positive and finite.
    /// - Returns: A new `RightTriangle` with the same angles and scaled side lengths.
    func withLeftLeg(_ newLeftLeg: Double) -> RightTriangle {
        precondition(newLeftLeg.isFinite && newLeftLeg > 0, "newLeftLeg must be a positive, finite number")
        let scale = newLeftLeg / leftLeg
        return RightTriangle(
            bottomLeg: bottomLeg * scale,
            leftLeg: newLeftLeg,
            hypotenuse: hypotenuse * scale,
            topAngle: topAngle,
            bottomAngle: bottomAngle
        )
    }

    /// Returns a new triangle where `hypotenuse` is set to `newHypotenuse`,
    /// uniformly scaling all sides so that the acute angles remain unchanged.
    ///
    /// - Parameter newHypotenuse: The desired length for the hypotenuse. Must be positive and finite.
    /// - Returns: A new `RightTriangle` with the same angles and scaled side lengths.
    func withHypotenuse(_ newHypotenuse: Double) -> RightTriangle {
        precondition(newHypotenuse.isFinite && newHypotenuse > 0, "newHypotenuse must be a positive, finite number")
        let scale = newHypotenuse / hypotenuse
        return RightTriangle(
            bottomLeg: bottomLeg * scale,
            leftLeg: leftLeg * scale,
            hypotenuse: newHypotenuse,
            topAngle: topAngle,
            bottomAngle: bottomAngle
        )
    }
}
