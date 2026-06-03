//
//  OrderDetailView.swift
//  zuping01
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 订单状态
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.statusDisplayName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text(order.statusDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: order.statusIcon)
                        .font(.system(size: 36))
                        .foregroundColor(Color.blue.opacity(0.6))
                }
                .padding()
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 收货地址
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("收货地址")
                            .fontWeight(.medium)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(order.shippingAddress.name).fontWeight(.medium)
                            Text(order.shippingAddress.phone).foregroundColor(.secondary)
                        }
                        Text(order.shippingAddress.fullAddress)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // 设备信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("设备信息")
                        .fontWeight(.medium)

                    ForEach(order.items) { item in
                        HStack(spacing: 12) {
                            ZStack {
                                if item.product.isRemoteImage {
                                    RemoteImageView(url: item.product.imageUrl)
                                } else if UIImage(named: item.product.imageUrl) != nil {
                                    Image(item.product.imageUrl)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray.opacity(0.15)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(Color.blue.opacity(0.5))
                                        )
                                }
                            }
                            .frame(width: 70, height: 70)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.product.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(2)

                                HStack {
                                    Text("¥\(String(format: "%.0f", item.product.price))/天")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                    Spacer()
                                    Text("×\(item.quantity)天")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                // 订单信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("订单信息")
                        .fontWeight(.medium)

                    VStack(spacing: 0) {
                        InfoRow(label: "订单编号", value: order.id.uuidString.prefix(8).uppercased() + "...")
                        InfoRow(label: "下单时间", value: order.formattedDate)
                        InfoRow(label: "设备数量", value: "\(order.totalQuantity)件")
                        InfoRow(label: "租用费用", value: "¥\(String(format: "%.0f", order.totalAmount))", isLast: true)
                    }
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationBarTitle("订单详情", displayMode: .inline)
    }
}

// MARK: - 信息行
struct InfoRow: View {
    let label: String
    let value: String
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            if !isLast {
                Divider()
                    .padding(.leading, 12)
            }
        }
    }
}
