//
//  AppCoordinator.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Observation

protocol AppCoordinatorProtocol: AnyObject {
    func pushTo(_ destination: Route)
    func present(_ destination: Route)
    func dismissSheet()
}

@Observable
final class AppCoordinator: AppCoordinatorProtocol {
    var path: [Route] = []
    var presentedSheet: Route?

    func pushTo(_ destination: Route) {
        path.append(destination)
    }

    func present(_ destination: Route) {
        presentedSheet = destination
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}
