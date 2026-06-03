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
