//
//  SettingsView.swift
//  zuhao002
//
//  Created by andy 正道 on 2026/5/20.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var securityManager = SecurityManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSettingPassword = false
    @State private var showSecuritySetup = false
    @State private var showingAlert = false
    @State private var alertMsg = ""
    
    var body: some View {
        Form {
            Section(header: Text("安全锁(仅本地存储保护)"), footer: Text("锁定后，打开本记事本将必须要通过正确的密码验证才可进入，离线保护您的隐私数据。")) {
                Toggle(isOn: $showSecuritySetup) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.accentColor)
                        Text("启用密码保护")
                    }
                }
                .onReceive(Just(showSecuritySetup)) { enabled in
                    if enabled {
                        if !securityManager.isPasswordEnabled {
                            isSettingPassword = true
                        }
                    } else {
                        if securityManager.isPasswordEnabled {
                            isSettingPassword = false
                            securityManager.disablePassword()
                            alertMsg = "密码锁已成功禁用"
                            showingAlert = true
                        }
                    }
                }
                
                if securityManager.isPasswordEnabled {
                    Button(action: {
                        isSettingPassword = true
                    }) {
                        Text("重新设置手势图案")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            Section(header: Text("数据与存储规约")) {
                HStack {
                    Text("存储状态")
                    Spacer()
                    Text("100% 纯本地离线存储")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("云端同步")
                    Spacer()
                    Text("无云端服务器/完全不上传")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("隐私数据收集")
                    Spacer()
                    Text("零收集/安全合规")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("关于记事本"), footer: Text("本应用遵循苹果 App Store 所有审核指南开发，致力于提供极简、纯粹且安全的用户体验。无任何后台隐藏行为，无第三方 SDK，无广告、无内购。")) {
                HStack {
                    Text("应用名称")
                    Spacer()
                    Text("离线安全记事本")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("当前版本")
                    Spacer()
                    Text("1.0.0 (纯净精简版)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("兼容适配")
                    Spacer()
                    Text("iOS 13.0 + / 完美支持深色模式")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationBarTitle("应用设置", displayMode: .inline)
        .onAppear {
            self.showSecuritySetup = securityManager.isPasswordEnabled
        }
        .sheet(isPresented: $isSettingPassword) {
            PatternSetupView(isPresented: $isSettingPassword) { success, msg in
                if success {
                    self.showSecuritySetup = true
                } else {
                    self.showSecuritySetup = securityManager.isPasswordEnabled
                }
                if let msg = msg {
                    self.alertMsg = msg
                    self.showingAlert = true
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("安全管理"), message: Text(alertMsg), dismissButton: .default(Text("确认")))
        }
    }
}

// Gesture pattern setup view (two-step: draw then confirm)
struct PatternSetupView: View {
    @Binding var isPresented: Bool
    var completion: (Bool, String?) -> Void

    enum SetupPhase { case draw, confirm }

    @State private var phase: SetupPhase = .draw
    @State private var firstPattern: [Int] = []
    @State private var currentPattern: [Int] = []
    @State private var isError: Bool = false
    @State private var hintMessage: String = ""
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer()

                // Header
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 72, height: 72)
                        Image(systemName: phase == .confirm ? "checkmark.shield.fill" : "hand.draw.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentColor)
                    }
                    Text(phase == .draw ? "绘制您的解锁图案" : "再次绘制以确认")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    if !hintMessage.isEmpty {
                        Text(hintMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isError ? .red : .secondary)
                    } else {
                        Text(phase == .draw ? "至少连接 4 个点，手指离开屏幕即确认" : "请绘制相同的图案进行确认")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .offset(x: shakeOffset)
                .padding(.bottom, 40)

                // Pattern grid
                PatternLockView(pattern: $currentPattern, isError: isError) { completed in
                    handleComplete(completed)
                }
                .padding(.horizontal, 52)

                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: Button("取消") {
                completion(false, nil)
                isPresented = false
            })
        }
    }

    private func handleComplete(_ completed: [Int]) {
        guard completed.count >= 4 else {
            hintMessage = "至少要连接 4 个点"
            isError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentPattern = []
                isError = false
                hintMessage = ""
            }
            return
        }
        switch phase {
        case .draw:
            firstPattern = completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentPattern = []
                phase = .confirm
                hintMessage = ""
                isError = false
            }
        case .confirm:
            if completed == firstPattern {
                if SecurityManager.shared.setPattern(completed) {
                    completion(true, "手势密码设置成功！")
                    isPresented = false
                }
            } else {
                isError = true
                hintMessage = "两次图案不一致，请重新设置"
                triggerShake()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    currentPattern = []
                    firstPattern = []
                    phase = .draw
                    isError = false
                    hintMessage = ""
                }
            }
        }
    }

    private func triggerShake() {
        withAnimation(.default) { shakeOffset = 12 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.default) { self.shakeOffset = -10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.default) { self.shakeOffset = 0 }
            }
        }
    }
}
