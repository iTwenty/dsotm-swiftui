//
//  DarkSideView.swift
//  dsotm-switfui
//
//  Created by Jaydeep Joshi on 01/10/23.
//

import SwiftUI

private func point(atFraction fraction: Double, start: CGPoint, end: CGPoint) -> CGPoint {
    let x = (end.x - start.x) * fraction + start.x
    let y = (end.y - start.y) * fraction + start.y
    return CGPoint(x: x, y: y)
}

private struct PrismPoints {
    let bottomLeft, bottomRight, top: CGPoint

    init(_ size: CGSize) {
        let prismSideLength = size.width / 3
        let prismHeight = prismSideLength * sin(Double.pi / 3)
        let prismBottomY = (size.height + prismHeight) / 2
        self.bottomLeft = CGPoint(x: prismSideLength, y:  prismBottomY)
        self.bottomRight = CGPoint(x: 2 * prismSideLength, y: prismBottomY)
        self.top = CGPoint(x: size.width / 2, y: prismBottomY - prismHeight)
    }
}

private struct Prism: Shape {
    let prism: PrismPoints

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: prism.bottomLeft)
            path.addLine(to: prism.bottomRight)
            path.addLine(to: prism.top)
            path.closeSubpath()
        }
    }
}

private struct WhiteLight: Shape {
    let prism: PrismPoints
    let params: Params

    func path(in rect: CGRect) -> Path {
        Path { path in
            let lightStart = CGPoint(x: .zero, y: rect.height * params.lightFraction)
            let lightEnd = point(atFraction: params.prismFraction, start: prism.top, end: prism.bottomLeft)

            path.move(to: lightStart)
            path.addLine(to: lightEnd)
        }
    }
}

private struct Dispersion: Shape {
    let prism: PrismPoints
    let params: Params
    var drawnFraction: Double

    func path(in rect: CGRect) -> Path {
        Path { path in
            let left = point(atFraction: params.prismFraction, start: prism.top, end: prism.bottomLeft)
            let topRight = point(atFraction: params.prismFraction - params.dispersionSize / 2,
                                 start: prism.top, end: prism.bottomRight)
            let bottomRight = point(atFraction: params.prismFraction + params.dispersionSize / 2,
                                    start: prism.top, end: prism.bottomRight)

            let topRightPartial = point(atFraction: drawnFraction, start: left, end: topRight)
            let bottomRightPartial = point(atFraction: drawnFraction, start: left, end: bottomRight)

            path.move(to: left)
            path.addLine(to: topRightPartial)
            path.addLine(to: bottomRightPartial)
            path.closeSubpath()
        }
    }
}

private struct RainbowSlice: Shape {
    let prism: PrismPoints
    let params: Params
    let index: Int
    let colorCount: Int
    var drawnFraction: Double

    func path(in rect: CGRect) -> Path {
        Path { path in
            let leftFractionStart = params.prismFraction - params.dispersionSize / 2
            let leftFractionStep = params.dispersionSize / Double(self.colorCount)
            let topLeftFraction = leftFractionStart + (Double(index) * leftFractionStep)
            let bottomLeftFraction = topLeftFraction + leftFractionStep

            let rightFractionStart = params.lightFraction - params.rainbowSize / 2
            let rightFractionStep = params.rainbowSize / Double(self.colorCount)
            let topRightFraction = rightFractionStart + (Double(index) * rightFractionStep)
            let bottomRightFraction = topRightFraction + rightFractionStep

            let topLeft = point(atFraction: topLeftFraction, start: prism.top, end: prism.bottomRight)
            let topRight = CGPoint(x: rect.maxX, y: rect.maxY * topRightFraction)
            let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY * bottomRightFraction)
            let bottomLeft = point(atFraction: bottomLeftFraction, start: prism.top,  end: prism.bottomRight)

            let topRightPartial = point(atFraction: drawnFraction, start: topLeft, end: topRight)
            let bottomRightPartial = point(atFraction: drawnFraction, start: bottomLeft, end: bottomRight)

            path.move(to: topLeft)
            path.addLine(to: topRightPartial)
            path.addLine(to: bottomRightPartial)
            path.addLine(to: bottomLeft)
            path.closeSubpath()
        }
    }
}

struct DarkSideView: View, Animatable {

    private static let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    let params: Params
    var drawnFraction: Double

    var animatableData: Double {
        get { drawnFraction }
        set { drawnFraction = newValue }
    }

    var body: some View {
        GeometryReader { proxy in
            let prism = PrismPoints(proxy.size)
            WhiteLight(prism: prism, params: params)
                .trim(from: 0, to: (max(0.25, min(drawnFraction, 0.5)) - 0.25) * 4)
                .stroke(Color.white, lineWidth: 2)
            Dispersion(prism: prism, params: params,
                       drawnFraction: (max(0.5, min(drawnFraction, 0.75)) - 0.5) * 4)
            .trim(from: 0, to: 1)
            .fill(.linearGradient(colors: [.white, .black],
                                  startPoint: UnitPoint(x: 0.45, y: 0.5),
                                  endPoint: UnitPoint(x: 0.55, y: 0.5)))
            ForEach(0..<Self.colors.count, id: \.self) { index in
                RainbowSlice(prism: prism,
                             params: params,
                             index: index,
                             colorCount: Self.colors.count,
                             drawnFraction: (max(0.75, min(drawnFraction, 1)) - 0.75) * 4)
                .fill(Self.colors[index % Self.colors.count])
            }
            Prism(prism: prism)
                .trim(from: 0, to: min(drawnFraction, 0.25) * 4)
                .stroke(Color.white, lineWidth: 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .background {
            Color.black
        }
    }
}

struct DarkSideView_Previews: PreviewProvider {
    static var previews: some View {
        DarkSideView(params: Params(), drawnFraction: 1)
    }
}
