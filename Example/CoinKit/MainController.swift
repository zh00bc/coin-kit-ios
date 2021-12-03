import UIKit
import CoinKit

class MainController: UITabBarController {
    private let coinKit: Kit

    init() {
        coinKit = try! Kit.instance()

        super.init(nibName: nil, bundle: nil)

        let coinController = CoinController(coinKit: coinKit, type: .coins)
        coinController.tabBarItem = UITabBarItem(title: "Coins", image: UIImage(systemName: "dollarsign.circle"), tag: 0)
        
        let mappingController = CoinController(coinKit: coinKit, type: .mappings)
        mappingController.tabBarItem = UITabBarItem(title: "Mappings", image: UIImage(systemName: "dollarsign.circle"), tag: 0)


        viewControllers = [
            UINavigationController(rootViewController: coinController),
            UINavigationController(rootViewController: mappingController)
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
