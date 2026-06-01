//
//  LockScreenView.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import SwiftUI

struct LockScreenView: View {
    @ObservedObject var securityManager = SecurityManager.shared
    @State private var pattern: [Int] = []
    @State private var isError: Bool = false
    @State private var shakeOffset: CGFloat = 0

    private var statusText: String {
        if isError { return "图案错误，请重新绘制" }
        if pattern.isEmpty { return "请绘制解锁图案" }
        return "绘制中..."
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon + status header
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                VStack(spacing: 8) {
                    Text("安全离线锁")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(statusText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isError ? .red : .secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .offset(x: shakeOffset)
            .padding(.bottom, 44)

            // Gesture pattern grid
            PatternLockView(pattern: $pattern, isError: isError) { completed in
                handleComplete(completed)
            }
            .padding(.horizontal, 52)

            Spacer()
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }

    private func handleComplete(_ completed: [Int]) {
        guard completed.count >= 4 else {
            // Too short — silently clear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                pattern = []
                isError = false
            }
            return
        }
        if securityManager.verifyPattern(completed) {
            isError = false
        } else {
            isError = true
            triggerShake()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                pattern = []
                isError = false
            }
        }
    }

    private func triggerShake() {
        withAnimation(.default) { shakeOffset = 12 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.default) { self.shakeOffset = -10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.default) { self.shakeOffset = 6 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.default) { self.shakeOffset = 0 }
                }
            }
        }
    }
}
