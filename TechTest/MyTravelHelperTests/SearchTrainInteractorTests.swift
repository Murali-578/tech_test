//
//  SearchTrainInteractorTests.swift
//  MyTravelHelperTests
//
//  Created by IT on 02/06/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainInteractorTests: XCTestCase, PresenterToInteractorProtocol {

    var interactor: SearchTrainInteractor?
    var presenter: InteractorToPresenterProtocol?
    private var mockRailClient = MockIrishClient()
    override func setUpWithError() throws {
        interactor = SearchTrainInteractor()
        presenter = SearchTrainPresenterMock()
    }

    override func tearDownWithError() throws {
        interactor = nil
    }
    
    func testfetchallStations() {
        fetchallStations()
    }
    
    func testToFetchTrainsFromSourceAndDestination() {
        fetchTrainsFromSource(sourceCode: "BFSTC", destinationCode: "LURGN")
    }
    
    func fetchallStations() {
        let expectation = XCTestExpectation(description: "response")
        mockRailClient.requestAllStations(from: IrishRailMethod.getAllStations) { (result) in
            switch result {
            case .success(let stations):
                if let stations = stations {
                    XCTAssertEqual(stations.stationsList.count, 167)
                }
                expectation.fulfill()
            case .failure(let error):
                XCTAssert(false, error.localizedDescription)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    
    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        let expectation = XCTestExpectation(description: "response")
        mockRailClient.requestToGetStationDataByCode(from: IrishRailMethod.getStationDataByCode(sourceCode)) { (result) in
            switch result {
            case .success(let stationData):
                if let _trainsList = stationData?.trainsList {
                    XCTAssertEqual(_trainsList.count, 2)
                }
                expectation.fulfill()
            case .failure(let error):
                XCTAssert(false, error.localizedDescription)
                expectation.fulfill()
//                presenter.showNoTrainAvailbilityFromSource()
            }
        }
        wait(for: [expectation], timeout: 60)
    }
}

class SearchTrainPresenterMock: InteractorToPresenterProtocol {
    func stationListFetched(list: [Station]) {
        
    }
    
    func fetchedTrainsList(trainsList: [StationTrain]?) {
        
    }
    
    func showNoTrainAvailbilityFromSource() {
        
    }
    
    func showNoInterNetAvailabilityMessage() {
        
    }
    
}

class MockIrishClient: APIClient {
    func requestAllStations(from kosmosMethod: IrishRailMethod, completion: @escaping (Result<Stations?, APIError>) -> Void) {
        
        let endpoint = kosmosMethod
        let request = endpoint.request
        fetch(with: request, decode: { json -> Stations? in
            guard let response = json as? Stations else { return  nil }
            return response
        }, completion: completion)
    }
    
    func requestToGetStationDataByCode(from kosmosMethod: IrishRailMethod, completion: @escaping (Result<StationData?, APIError>) -> Void) {
        let endpoint = kosmosMethod
        let request = endpoint.request
        fetch(with: request, decode: { json -> StationData? in
            guard let response = json as? StationData else { return  nil }
            return response
        }, completion: completion)
    }
}
