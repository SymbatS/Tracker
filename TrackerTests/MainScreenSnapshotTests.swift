import XCTest
import SnapshotTesting
@testable import Tracker

final class MainScreenSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        isRecording = false
        UIView.setAnimationsEnabled(false)
    }
    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }
    
    // MARK: - Helpers
    private func makeSUT() -> UIViewController {
        let vm = makeSnapshotViewModel()
        let vc = TrackersViewController(viewModel: vm)
        vc.loadViewIfNeeded()
        return UINavigationController(rootViewController: vc)
    }
    
    func test_main_light() {
        let nav = makeSUT()
        assertSnapshot(
            matching: nav,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)),
            named: "main_light"
        )
    }
    
    func test_main_dark() {
        let nav = makeSUT()
        assertSnapshot(
            matching: nav,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "main_dark"
        )
    }
}
