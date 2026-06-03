//
//  LoginView.swift
//  zuping01
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) private var presentationMode
    @State private var phone = ""
    @State private var code  = ""
    @State private var showError    = false
    @State private var errorMessage = ""
    @State private var countdown = 0
    @State private var timer: Timer?
    @State private var agreed = true

    private let userAgreementURL = "https://static-game.duodian.cn/osZuhao/os/user-agreement.html"
    private let privacyPolicyURL = "https://static-game.duodian.cn/osZuhao/os/privacy-policy.html"

    private var isValidPhone: Bool {
        let pattern = "^1[3-9]\\d{9}$"
        return phone.range(of: pattern, options: .regularExpression) != nil
    }

    private var canSendCode: Bool {
        isValidPhone && countdown == 0
    }

    private var phoneBinding: Binding<String> {
        Binding(get: { phone }, set: { newValue in
            let filtered = newValue.filter { $0.isNumber }
            if filtered.count <= 11 { phone = filtered }
        })
    }

    private var codeBinding: Binding<String> {
        Binding(get: { code }, set: { newValue in
            let filtered = newValue.filter { $0.isNumber }
            if filtered.count <= 6 { code = filtered }
        })
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "laptopcomputer.and.iphone")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("数码租赁平台")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                }

                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        TextField("请输入手机号", text: phoneBinding)
                            .keyboardType(.phonePad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        TextField("请输入验证码", text: codeBinding)
                            .keyboardType(.numberPad)

                        Button {
                            startCountdown()
                        } label: {
                            Text(countdown > 0 ? "\(countdown)s" : "发送验证码")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(canSendCode ? .white : .gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(canSendCode ? Color.blue : Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .disabled(!canSendCode)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                // 用户协议与隐私政策
                HStack(spacing: 6) {
                    Button {
                        agreed.toggle()
                    } label: {
                        Image(systemName: agreed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundColor(agreed ? .blue : Color.gray.opacity(0.6))
                    }
                    .buttonStyle(BorderlessButtonStyle())

                    HStack(spacing: 0) {
                        Text("我已阅读并同意")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Button("《用户协议》") { openURL(userAgreementURL) }
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .buttonStyle(BorderlessButtonStyle())
                        Text("与")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Button("《隐私政策》") { openURL(privacyPolicyURL) }
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .padding(.bottom, -20)

                Button {
                    guard agreed else {
                        errorMessage = "请阅读并同意《用户协议》与《隐私政策》"
                        showError = true
                        return
                    }
                    guard isValidPhone else {
                        errorMessage = "请输入正确的11位手机号"
                        showError = true
                        return
                    }
                    guard code.count == 6 else {
                        errorMessage = "请输入6位验证码"
                        showError = true
                        return
                    }
                    if authManager.loginWithCode(phone: phone, code: code) {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        errorMessage = "验证码错误，请重新输入"
                        showError = true
                    }
                } label: {
                    Text("登录")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            (phone.count < 11 || code.count < 6 || !agreed) ? Color.gray : Color.blue
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(phone.count < 11 || code.count < 6 || !agreed)
                .padding(.horizontal)

                Text("新用户输入手机号验证后即可自动注册")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            })
            .alert(isPresented: $showError) {
                Alert(title: Text("登录失败"),
                      message: Text(errorMessage),
                      dismissButton: .cancel(Text("确定")))
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func startCountdown() {
        countdown = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if countdown > 0 {
                countdown -= 1
            } else {
                t.invalidate()
            }
        }
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
