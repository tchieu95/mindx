//
//  NetworkService.swift
//  Covid-19-Tracker
//
//  Created by HieuTC on 6/25/21.
//

import Foundation

struct Cases: Decodable {
    let confirmed: Int
    let recovered: Int
    let deaths: Int
    let population: Int?
    
    func deathRate() -> Int {
        return deaths/confirmed
    }
}

struct AllCases: DynamicDecodable {
    let All: Cases
    var key: String?
}

protocol DynamicDecodable: Decodable {
    var key: String? { get set }
}

struct DecodedArray<T: DynamicDecodable>: Decodable {
    var array: [T]
    
    // Define DynamicCodingKeys type needed for creating
    // decoding container from JSONDecoder
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    init(from decoder: Decoder) throws {

        // 1
        // Create a decoding container using DynamicCodingKeys
        // The container will contain all the JSON first level key
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var tempArray = [T]()

        // 2
        // Loop through each key (student ID) in container
        for key in container.allKeys {

            // Decode Student using key & keep decoded Student object in tempArray
            var decodedObject = try container.decode(T.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            decodedObject.key = key.stringValue
            tempArray.append(decodedObject)
        }

        // 3
        // Finish decoding all Student objects. Thus assign tempArray to array.
        array = tempArray
    }
}


struct Vaccine: Codable {
    let people_vaccinated: Int
    let administered: Int
    let people_partially_vaccinated: Int
}

struct AllVaccine: Codable {
    let All: Vaccine
}

class NetworkService {
    let baseURL = "https://covid-api.mmediagroup.fr/v1"
    let session = URLSession(configuration: .default)
    
    func vietnamCases(completion: @escaping ((Result<Cases, Error>) -> Void)) {
        cases(country: "Vietnam", completion: completion)
    }
    
    func cases(country: String = "Global", completion: @escaping ((Result<Cases, Error>) -> Void))  {
        var request = URLRequest(url: URL(string: baseURL + "/cases?country=\(country)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request) { (data, response, _) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        print("Response API request ", json)
                    }
                completion(.failure(NSError()))
                return
            }
            
            let decoder = JSONDecoder()
            let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            print("Response API request ", json)
            let result = try! decoder.decode(AllCases.self, from: data!)
            
            completion(.success(result.All))
        }
        
        dataTask.resume()
    }
    
    func global(completion: @escaping ((Result<[AllCases], Error>) -> Void))  {
        var request = URLRequest(url: URL(string: baseURL + "/cases")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request) { (data, response, _) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        print("Response API request ", json)
                    }
                completion(.failure(NSError()))
                return
            }
            
            let decoder = JSONDecoder()
            let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            print("Response API request ", json)
            let result = try! decoder.decode(DecodedArray<AllCases>.self, from: data!)
            completion(.success(result.array))
        }
        
        dataTask.resume()
    }
    
    func vaccines(country: String = "Vietnam", completion: @escaping ((Result<Vaccine, Error>) -> Void))  {
        var request = URLRequest(url: URL(string: baseURL + "/vaccines?country=\(country)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request) { (data, response, _) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        print("Response API request ", json)
                    }
                completion(.failure(NSError()))
                return
            }
            
            let decoder = JSONDecoder()
            let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            print("Response API request ", json)
            let result = try! decoder.decode(AllVaccine.self, from: data!)
            
            completion(.success(result.All))
        }
        
        dataTask.resume()
    }
}
