//
//  AuxiliaryViews.swift
//  zuping001
//

import SwiftUI

// MARK: - 毛玻璃背景
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - 读取 App 图标
extension UIImage {
    /// 从应用 Bundle 中读取主图标，用于在“关于我们”等页面展示
    static var appIcon: UIImage? {
        guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let files = primary["CFBundleIconFiles"] as? [String],
              let lastName = files.last else {
            return UIImage(named: "app_icon_1024")
        }
        return UIImage(named: lastName) ?? UIImage(named: "app_icon_1024")
    }
}

// MARK: - 常见问题页
struct FAQView: View {
    var body: some View {
        List {
            Section(header: Text("关于租损和赔偿").font(.caption).foregroundColor(.secondary)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("1. 设备在使用期间发生损坏怎么办？")
                        .font(.headline)
                        .padding(.top, 4)
                    Text("数码设备正常使用产生的轻微划痕折旧属于正常范畴，不予收费。若遇到严重跌落、砸损、外观破裂或电池进水等由于主观疏忽造成的物理伤害，我们将根据专业检测机构（如官方品牌售后）评估结果收取相应配件成本或折旧款。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("2. 我是否可以自行拆卸或维修设备？")
                        .font(.headline)
                        .padding(.top, 4)
                    Text("严禁对租赁设备进行任何拆卸、更换零部件或前往非官方认可渠道进行维修的操作。否则将视为整机损毁处理，需照价折旧支付。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("关于配送和退还").font(.caption).foregroundColor(.secondary)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("3. 设备是如何配送的？")
                        .font(.headline)
                        .padding(.top, 4)
                    Text("我们在确认支付金额和收货信息无误后，同城设备将在 1-4 小时内由闪送/美团专送寄出；跨城订单则会默认采用顺丰速运（包裹全保额寄出），确保设备一路安稳无虞。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("4. 如何发起设备归还？")
                        .font(.headline)
                        .padding(.top, 4)
                    Text("在租赁期满当日，通过订单列表页面，点击对应的“发起退还/归还”，系统会自动为您生成退还物流预约或者归还寄送地址，您只需将设备放回原厂寄送托运箱中，通过顺丰到付/自寄发回。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("常见问题", displayMode: .inline)
    }
}

// MARK: - 租赁须知页
struct RentalGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("数码智租服务指南")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 6)
                
                Text("尊贵的租户用户，在您通过本平台租赁手机、平板、相机或无人机等高新数码电子产品前，请谨记审阅并充分理解下述指导手册：")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Group {
                    Text("一、 凭证及租金计算条款")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("1. 起租时长：单笔订单的最低起租周期为 1 天。租金自物流妥投签收日的次日 00:00 起计，避免将途中运输时间转嫁给用户。\n2. 周期计费：所有设备按自然日标准资费结算。若中途申请延长租约，应当提前 24 小时在 App 个人订单里申请并支付展期租金。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Group {
                    Text("二、 信用及免押额度明细")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("本服务接入了用户信用综合判定体系，评级优良的用户可享受全程零押金、零担保额度的便捷租物服务，轻量享受数码新品。未能达成免押评级的部分商品将按规定冻结部分租赁担保金，归还检修无虞后立刻退款。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Group {
                    Text("三、 设备日常养护责任")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("从您本人或代收人签收日起，即视为您对该设备的持有和看管期。请务必保留出厂原包装，以防归还时包装颠簸碰撞受损。使用时请严防液体泼溅，多风沙天气请慎重在户外拔插传感器或拆装照相机镜头。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationBarTitle("租用指南", displayMode: .inline)
    }
}

// MARK: - 关于我们页
struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 应用图标与名称
                VStack(spacing: 12) {
                    if let appIcon = UIImage.appIcon {
                        Image(uiImage: appIcon)
                            .resizable()
                            .frame(width: 88, height: 88)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                            .padding(.top, 24)
                    } else {
                        Image(systemName: "iphone.gen3.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.blue)
                            .padding(.top, 24)
                    }

                    Text("数码智租")
                        .font(.system(size: 22, weight: .bold))
                        .fontWeight(.bold)

                    Text("版本 1.0.0")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // 平台简介
                VStack(alignment: .leading, spacing: 12) {
                    Text("平台简介")
                        .font(.headline)
                    Text("数码智租是一家专注于高新数码电子产品租赁的服务平台，致力于让每一位用户都能以更轻盈的方式体验最新潮的手机、平板、相机及无人机等智能设备。我们提供正品保障、安全配送与贴心售后，让数码生活触手可及。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 协议入口
                VStack(spacing: 0) {
                    NavigationLink(destination: UserAgreementView()) {
                        AboutLinkRow(title: "《用户协议》")
                    }
                    .buttonStyle(PlainButtonStyle())

                    Divider().padding(.leading, 16)

                    NavigationLink(destination: PrivacyPolicyView()) {
                        AboutLinkRow(title: "《隐私政策》")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("© 2026 数码智租 版权所有")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("关于我们", displayMode: .inline)
    }
}

// MARK: - 关于我们 - 协议入口行
struct AboutLinkRow: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

// MARK: - 用户协议页
struct UserAgreementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("用户协议")
                    .font(.system(size: 22, weight: .bold))
                    .fontWeight(.bold)
                    .padding(.bottom, 4)

                Text("欢迎您使用数码智租平台服务。在使用本平台前，请您仔细阅读并充分理解本协议的全部条款。当您注册、登录或使用本平台服务时，即表示您已阅读并同意接受本协议的约束。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)

                Group {
                    Text("一、 服务内容")
                        .font(.headline)
                    Text("本平台为用户提供数码电子产品的在线租赁、订单管理、物流配送及售后等相关服务。平台有权根据运营需要对服务内容进行调整、变更或终止，并将以适当方式予以公告。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Group {
                    Text("二、 用户行为规范")
                        .font(.headline)
                    Text("用户应当如实提供注册信息并妥善保管账户。用户在租赁期间应合法、合规地使用所租设备，不得用于任何违法犯罪活动，不得擅自拆解、转租或转让所租设备。如因用户原因造成设备损坏或灭失，用户应承担相应赔偿责任。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Group {
                    Text("三、 租金与支付")
                        .font(.headline)
                    Text("用户应按照订单约定的租金标准及支付方式按时足额支付费用。逾期未归还设备的，平台有权按照约定收取逾期租金及违约金。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Group {
                    Text("四、 协议变更")
                        .font(.headline)
                    Text("平台有权在必要时修改本协议条款，修改后的协议一经公布即生效。若您继续使用本平台服务，即视为接受修改后的协议。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            .padding()
        }
        .navigationBarTitle("用户协议", displayMode: .inline)
    }
}

// MARK: - 隐私政策页
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("隐私政策")
                    .font(.system(size: 22, weight: .bold))
                    .fontWeight(.bold)
                    .padding(.bottom, 4)

                Text("数码智租非常重视用户的隐私和个人信息保护。本政策旨在向您说明我们如何收集、使用、存储和保护您的个人信息。请您在使用本平台服务前仔细阅读并理解本政策。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)

                Group {
                    Text("一、 信息收集")
                        .font(.headline)
                    Text("为向您提供租赁服务，我们可能收集您的姓名、联系电话、收货地址等必要信息。我们仅在为您提供服务所必需的范围内收集和使用上述信息。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Group {
                    Text("二、 信息使用")
                        .font(.headline)
                    Text("我们收集的信息将用于订单处理、物流配送、客户服务及风险控制等用途。未经您的同意，我们不会将您的个人信息用于上述目的以外的其他用途。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Group {
                    Text("三、 信息保护")
                        .font(.headline)
                    Text("我们采用符合行业标准的安全防护措施保护您的个人信息，防止信息遭到未经授权的访问、泄露、篡改或损毁。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Group {
                    Text("四、 信息共享")
                        .font(.headline)
                    Text("除为完成配送等服务所必需，或依据法律法规要求外，我们不会向任何第三方共享、转让您的个人信息。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }

                Group {
                    Text("五、 您的权利")
                        .font(.headline)
                    Text("您有权随时查询、更正或删除您的个人信息。如您对本隐私政策有任何疑问，可通过“关于我们”页面提供的联系方式与我们取得联系。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            .padding()
        }
        .navigationBarTitle("隐私政策", displayMode: .inline)
    }
}
