import SwiftUI
import UIKit

enum InkBlobShape {
    static let pointCount = 12

    static func bezierPath(
        center: CGPoint,
        radii: [CGFloat],
        handleScales: [CGFloat]
    ) -> UIBezierPath {
        let count = radii.count
        let circleHandle = (4.0 / 3.0) * tan(.pi / (2 * CGFloat(count)))
        let vertices = (0..<count).map { index -> (point: CGPoint, tangent: CGPoint, handle: CGFloat) in
            let theta = angle(index, count: count)
            let radius = radii[index]
            return (
                CGPoint(x: center.x + cos(theta) * radius, y: center.y + sin(theta) * radius),
                CGPoint(x: -sin(theta), y: cos(theta)),
                radius * circleHandle * handleScales[index]
            )
        }

        let path = UIBezierPath()
        path.move(to: vertices[0].point)
        for index in 0..<count {
            let current = vertices[index]
            let next = vertices[(index + 1) % count]
            path.addCurve(
                to: next.point,
                controlPoint1: CGPoint(
                    x: current.point.x + current.tangent.x * current.handle,
                    y: current.point.y + current.tangent.y * current.handle
                ),
                controlPoint2: CGPoint(
                    x: next.point.x - next.tangent.x * next.handle,
                    y: next.point.y - next.tangent.y * next.handle
                )
            )
        }
        path.close()
        return path
    }

    static func holePath(
        bounds: CGRect,
        center: CGPoint,
        radii: [CGFloat],
        handleScales: [CGFloat]
    ) -> CGPath {
        let path = UIBezierPath(rect: bounds)
        path.append(bezierPath(center: center, radii: radii, handleScales: handleScales))
        path.usesEvenOddFillRule = true
        return path.cgPath
    }

    private static func angle(_ index: Int, count: Int) -> CGFloat {
        CGFloat(index) * (.pi * 2 / CGFloat(count)) - .pi / 2
    }
}

struct InkBlobMotion: Equatable {
    var origin: CGPoint
    var bounds: CGRect
    var startRadii: [CGFloat]
    var endRadii: [CGFloat]
    var durations: [TimeInterval]
    var handleScales: [CGFloat]

    var maxDuration: TimeInterval {
        durations.max() ?? 0
    }

    static func random(
        origin: CGPoint,
        bounds: CGRect,
        using generator: inout some RandomNumberGenerator
    ) -> InkBlobMotion {
        let count = InkBlobShape.pointCount
        let cover = InkThemeReveal.coveringRadius(origin: origin, bounds: bounds)
        return InkBlobMotion(
            origin: origin,
            bounds: bounds,
            startRadii: (0..<count).map { _ in
                InkThemeReveal.startRadius * CGFloat.random(in: 0.96...1.04, using: &generator)
            },
            endRadii: (0..<count).map { _ in
                cover * CGFloat.random(in: 1.04...1.42, using: &generator)
            },
            durations: (0..<count).map { _ in
                TimeInterval.random(in: 0.72...1.08, using: &generator)
            },
            handleScales: (0..<count).map { _ in
                CGFloat.random(in: 0.92...1.08, using: &generator)
            }
        )
    }

    static func random(origin: CGPoint, bounds: CGRect) -> InkBlobMotion {
        var generator = SystemRandomNumberGenerator()
        return random(origin: origin, bounds: bounds, using: &generator)
    }

    func radii(at elapsed: TimeInterval) -> [CGFloat] {
        (0..<startRadii.count).map { index in
            let t = min(1, elapsed / max(durations[index], 0.001))
            let eased = t * t * (3 - 2 * t)
            return startRadii[index] + (endRadii[index] - startRadii[index]) * eased
        }
    }

    func holePath(at elapsed: TimeInterval) -> CGPath {
        InkBlobShape.holePath(
            bounds: bounds,
            center: origin,
            radii: radii(at: elapsed),
            handleScales: handleScales
        )
    }
}

enum InkThemeReveal {
    static let startRadius: CGFloat = 22

    private static var isRevealing = false
    private static var driver: InkThemeRevealDriver?

    static var inProgress: Bool { isRevealing }

    static func play(from origin: CGPoint, apply: () -> Void) {
        guard !isRevealing, let window = keyWindow() else {
            apply()
            return
        }
        guard let snapshot = window.snapshotView(afterScreenUpdates: false) else {
            apply()
            return
        }

        isRevealing = true
        snapshot.frame = window.bounds
        snapshot.isUserInteractionEnabled = false
        window.addSubview(snapshot)
        apply()

        let motion = InkBlobMotion.random(origin: origin, bounds: window.bounds)
        DispatchQueue.main.async {
            let mask = CAShapeLayer()
            mask.fillRule = .evenOdd
            mask.path = motion.holePath(at: 0)
            snapshot.layer.mask = mask
            driver = InkThemeRevealDriver(mask: mask, motion: motion) {
                snapshot.removeFromSuperview()
                driver = nil
                isRevealing = false
            }
            driver?.start()
        }
    }

    static func coveringRadius(origin: CGPoint, bounds: CGRect) -> CGFloat {
        let corners = [
            CGPoint(x: bounds.minX, y: bounds.minY),
            CGPoint(x: bounds.maxX, y: bounds.minY),
            CGPoint(x: bounds.minX, y: bounds.maxY),
            CGPoint(x: bounds.maxX, y: bounds.maxY),
        ]
        return corners.map { hypot($0.x - origin.x, $0.y - origin.y) }.max() ?? bounds.width
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}

private final class InkThemeRevealDriver: NSObject {
    private let mask: CAShapeLayer
    private let motion: InkBlobMotion
    private let completion: () -> Void
    private var link: CADisplayLink?
    private var startTime: CFTimeInterval?

    init(mask: CAShapeLayer, motion: InkBlobMotion, completion: @escaping () -> Void) {
        self.mask = mask
        self.motion = motion
        self.completion = completion
    }

    func start() {
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        self.link = link
        link.add(to: .main, forMode: .common)
    }

    @objc private func tick(_ link: CADisplayLink) {
        if startTime == nil {
            startTime = link.timestamp
        }
        let elapsed = link.timestamp - (startTime ?? link.timestamp)
        mask.path = motion.holePath(at: elapsed)
        if elapsed >= motion.maxDuration {
            link.invalidate()
            self.link = nil
            completion()
        }
    }
}

enum InkAppearanceTransition {
    static func shouldReveal(
        from: InkAppearance,
        to: InkAppearance,
        system: ColorScheme
    ) -> Bool {
        guard from != to else { return false }
        return InkPalette.resolved(appearance: from, system: system)
            != InkPalette.resolved(appearance: to, system: system)
    }

    static func currentSystemColorScheme() -> ColorScheme {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        return scene?.traitCollection.userInterfaceStyle == .dark ? .dark : .light
    }
}
