//
//  SelfConfiguringCell.swift
//  iChat
//
//  Created by Oleg Chebotarev on 18.10.2020.
//

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}
