//
//  BannerModel.swift
//  SurebetCalculatorPackage
//
//  Created by BELDIN Yaroslav on 23.11.2025.
//

import Foundation

struct BannerModel: Codable, Sendable {
    let id: String
    let title: String
    let body: String
    let partnerCode: String?
    let imageURL: URL
    let actionURL: URL
}
