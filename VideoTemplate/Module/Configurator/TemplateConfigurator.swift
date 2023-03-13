//
//  TemplateConfigurator.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import UIKit

protocol TemplateConfiguratorProtocol: AnyObject {
    func configureModule() -> UIViewController
}

final class TemplateConfigurator: TemplateConfiguratorProtocol {
    
    func configureModule() -> UIViewController {
        let viewController = TemplateViewController()
        let presenter = TemplatePresenter(view: viewController,
                                          serviceImageSegmentation: ServicesAssebly.serviceImageSegmentation,
                                          serviceSound: ServicesAssebly.serviceSound)
        viewController.presenter = presenter
        return viewController
    }
}
