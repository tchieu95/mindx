//
//  ViewController.swift
//  Covid-19-Tracker
//
//  Created by HieuTC on 6/25/21.
//

import UIKit
import SnapKit

let width = 80
let cw = 120

class Cell: UITableViewCell {
    let country = UILabel()
    let confirmed = UILabel()
    let recovered = UILabel()
    let deaths = UILabel()
    let rate = UILabel()
    let f = UIFont.systemFont(ofSize: 12.5)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(country)
        country.text = "Country"
        country.textColor = .black
        country.font = f
        
        country.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(cw)
        }
        
        addSubview(confirmed)
        confirmed.text = "0"
        confirmed.textColor = .blue
        confirmed.font = f
        
        confirmed.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(country.snp.right)
            make.width.equalTo(width)
        }
        
        addSubview(deaths)
        deaths.text = "0"
        deaths.textColor = .red
        deaths.font = f
        
        deaths.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(width)
            make.left.equalTo(confirmed.snp.right)
        }
        
        addSubview(recovered)
        recovered.text = "0"
        recovered.textColor = .green
        recovered.font = f
        
        recovered.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(width)
            make.left.equalTo(deaths.snp.right)
        }
        
        addSubview(rate)
        rate.text = "0.0"
        rate.textColor = .gray
        rate.font = f
        
        rate.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(width)
            make.left.equalTo(recovered.snp.right)
        }
    }
}

class ViewController: UIViewController {
    let tv = UITableView()
    var source = [AllCases]()
    var data = [AllCases]()
    
    let country = UILabel()
    let confirmed = UILabel()
    let recovered = UILabel()
    let deaths = UILabel()
    let rate = UILabel()
    var textSearch = ""
    
    lazy var searchBar: UISearchBar = UISearchBar()

    let f = UIFont.systemFont(ofSize: 12.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        setupLabels()
        setup()
        // Do any additional setup after loading the view.
        NetworkService().global { (result) in
            switch result {
            case .success(let cases):
                print(cases)
                DispatchQueue.main.async {
                    self.source = cases
                    self.data = cases
                    self.tv.reloadData()
                }
                
            case .failure(let e):
                print(e)
            }
        }
    }
    
    func setup() {
        view.addSubview(tv)
        tv.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.top.equalTo(country.snp.bottom).offset(10)
        }
        tv.register(Cell.self, forCellReuseIdentifier: "cell")
        tv.delegate = self
        tv.dataSource = self
    }
    
    func setupLabels() {
        view.addSubview(country)
        country.text = "Country"
        country.textColor = .black
        country.font = f
        
        country.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalTo(cw)
        }
        
        view.addSubview(confirmed)
        confirmed.text = "confirmed"
        confirmed.textColor = .blue
        confirmed.font = f
        
        confirmed.snp.makeConstraints { (make) in
            make.top.equalTo(country.snp.top)
            make.left.equalTo(country.snp.right)
            make.width.equalTo(width)
        }
        
        view.addSubview(deaths)
        deaths.text = "deaths"
        deaths.textColor = .red
        deaths.font = f
        
        deaths.snp.makeConstraints { (make) in
            make.top.equalTo(country.snp.top)
            make.width.equalTo(width)
            make.left.equalTo(confirmed.snp.right)
        }
        
        view.addSubview(recovered)
        recovered.text = "recovered"
        recovered.textColor = .green
        recovered.font = f
        
        recovered.snp.makeConstraints { (make) in
            make.top.equalTo(country.snp.top)
            make.width.equalTo(width)
            make.left.equalTo(deaths.snp.right)
        }
        
        view.addSubview(rate)
        rate.text = "rate"
        rate.textColor = .gray
        rate.font = f
        rate.textAlignment = .center
        
        rate.snp.makeConstraints { (make) in
            make.top.equalTo(country.snp.top)
            make.width.equalTo(width)
            make.left.equalTo(recovered.snp.right)
        }
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        let cases = data[indexPath.row]
        cell.confirmed.text = "\(cases.All.confirmed)"
        cell.deaths.text = "\(cases.All.deaths)"
        cell.recovered.text = "\(cases.All.recovered)"
        cell.rate.text = "\(round(100 * Double(cases.All.deaths)/Double((cases.All.confirmed)))) %"
        cell.country.text = "\(cases.key ?? "Country")"
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String)
    {
        if textSearched.isEmpty {
            data = source
        } else {
            data = source.filter({ (e) -> Bool in
                (e.key?.lowercased().contains(textSearched.lowercased()) ?? false)
            })
        }

        tv.reloadData()
    }
}

