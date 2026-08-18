//
//  AppCoordinatorSpy.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
@testable import MLCodeChallenge

final class AppCoordinatorSpy: AppCoordinatorProtocol {
    private(set) var pushToCalls: [Route] = []
    private(set) var presentCalls: [Route] = []
    private(set) var dismissSheetCount = 0

    func pushTo(_ destination: Route) {
        pushToCalls.append(destination)
    }

    func present(_ destination: Route) {
        presentCalls.append(destination)
    }

    func dismissSheet() {
        dismissSheetCount += 1
    }
}
