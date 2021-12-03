import UIKit
import SnapKit
import RxSwift
import CoinKit

enum DataType {
    case coins
    case mappings
}

class CoinController: UIViewController {
    private let disposeBag = DisposeBag()
    private let coinKit: Kit
    private var coins = [Coin]()
    private var mappings = [CoinMapping]()
    let type: DataType

    private let tableView = UITableView(frame: .zero, style: .plain)

    init(coinKit: Kit, type: DataType) {
        self.coinKit = coinKit
        self.type = type

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = type == .coins ? "Coins" : "Mappings"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.separatorInset = .zero
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CoinCell.self, forCellReuseIdentifier: String(describing: CoinCell.self))

        initCoins()
    }

    private func initCoins() {
        coins = Array(coinKit.coins.prefix(100))
        mappings = Array(coinKit.mappings.prefix(100))
        tableView.reloadData()
    }

}

extension CoinController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == .coins {
            return coins.count
        } else {
            return mappings.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CoinCell.self)) {
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CoinCell, coins.count > indexPath.row else {
            return
        }

        if type == .coins {
            let coin = coins[indexPath.row]

            cell.topTitle = coin.id
            cell.middleTitle = coin.title
            cell.bottomTitle = coin.code
        } else {
            let mapping = mappings[indexPath.row]
            cell.topTitle = mapping.name
            cell.middleTitle = mapping.mirrorCoinId
            cell.bottomTitle = mapping.coinId
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

}
