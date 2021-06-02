//
//  SearchTrainPresenterTests.swift
//  MyTravelHelperTests
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainPresenterTests: XCTestCase {
    var presenter: SearchTrainPresenter!
    var view = SearchTrainMockView()
    var interactor = SearchTrainInteractorMock()
    
    override func setUp() {
        presenter = SearchTrainPresenter()
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter
    }

    func testfetchallStations() {
        presenter.fetchallStations()

        XCTAssertTrue(view.isSaveFetchedStatinsCalled)
    }
    
    func testFetchLatestTrains() {
        presenter.searchTapped(source: "BFSTC", destination: "LURGN")
        XCTAssertTrue(view.isFetchedUpdatedTrainList)
    }

    override func tearDown() {
        presenter = nil
    }
}


class SearchTrainMockView:PresenterToViewProtocol {
    var isSaveFetchedStatinsCalled = false
    var isFetchedUpdatedTrainList = false
    func saveFetchedStations(stations: [Station]?) {
        isSaveFetchedStatinsCalled = true
    }

    func showInvalidSourceOrDestinationAlert() {

    }
    
    func updateLatestTrainList(trainsList: [StationTrain]) {
        isFetchedUpdatedTrainList = trainsList.isEmpty ? false : true
    }
    
    func showNoTrainsFoundAlert() {

    }
    
    func showNoTrainAvailbilityFromSource() {

    }
    
    func showNoInterNetAvailabilityMessage() {

    }
}

class SearchTrainInteractorMock: PresenterToInteractorProtocol {
    var presenter: InteractorToPresenterProtocol?

    func fetchallStations() {
        let station = Station(desc: "Belfast Central", latitude: 54.6123, longitude: -5.91744, code: "BFSTC", stationId: 228)
        presenter?.stationListFetched(list: [station])
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        let stationTrain = StationTrain(trainCode: "A124", fullName: "Belfast", stationCode: "BFSTC", trainDate: "02 Jun 2021", dueIn: 49, lateBy: 5, expArrival: "11:50", expDeparture: "00:00")
//        let stationData = StationData(trainsList: [stationTrain])
        presenter?.fetchedTrainsList(trainsList: [stationTrain])
    }
}

