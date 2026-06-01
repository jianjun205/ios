//
//  PatternLockView.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import SwiftUI

private struct ConnectingLine: Shape {
    var from: CGPoint
    var to: CGPoint

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        return p
    }
}

struct PatternLockView: View {
    @Binding var pattern: [Int]
    var isError: Bool = false
    var onComplete: (([Int]) -> Void)?

    @State private var fingerPoint: CGPoint = .zero
    @State private var isDragging: Bool = false

    private let dotDiameter: CGFloat = 52

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let centers = dotCenters(side: side)
            let activeColor: Color = isError ? .red : .accentColor

            ZStack {
                // Lines between already-connected dots
                if pattern.count >= 2 {
                    ForEach(0..<pattern.count - 1, id: \.self) { i in
                        ConnectingLine(
                            from: centers[pattern[i]],
                            to: centers[pattern[i + 1]]
                        )
                        .stroke(
                            activeColor.opacity(0.5),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                    }
                }

                // Live trailing line from last dot to current finger position
                if isDragging, let last = pattern.last {
                    ConnectingLine(from: centers[last], to: fingerPoint)
                        .stroke(
                            activeColor.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [6, 4])
                        )
                }

                // The 9 dots (3×3 grid)
                ForEach(0..<9, id: \.self) { i in
                    let isSelected = pattern.contains(i)
                    ZStack {
                        Circle()
                            .fill(isSelected
                                  ? activeColor.opacity(0.15)
                                  : Color(.tertiarySystemBackground))
                        Circle()
                            .stroke(activeColor, lineWidth: isSelected ? 2.5 : 1.5)
                        if isSelected {
                            Circle()
                                .fill(activeColor)
                                .frame(width: 14, height: 14)
                        }
                    }
                    .frame(width: dotDiameter, height: dotDiameter)
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                    .animation(.spring(response: 0.18, dampingFraction: 0.5))
                    .position(centers[i])
                }
            }
            .frame(width: side, height: side)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        isDragging = true
                        fingerPoint = value.location
                        for (i, center) in centers.enumerated() {
                            guard !pattern.contains(i) else { continue }
                            let dx = value.location.x - center.x
                            let dy = value.location.y - center.y
                            if sqrt(dx * dx + dy * dy) < dotDiameter * 0.7 {
                                pattern.append(i)
                            }
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        onComplete?(pattern)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func dotCenters(side: CGFloat) -> [CGPoint] {
        let step = side / 3.0
        return (0..<9).map { i in
            CGPoint(
                x: step * (CGFloat(i % 3) + 0.5),
                y: step * (CGFloat(i / 3) + 0.5)
            )
        }
    }
}
