import Quick
import Nimble
import UIKit

class FakeListCardDelegate : ListCardDelegate {

    var numberCells: Bool = false
    func numberOfCells() -> Int {
        numberCells = true
        return 1
    }

    var lastHeightAskedFor: Int? = nil
    func heightForCell(index: Int) -> CGFloat {
        lastHeightAskedFor = index
        return 40
    }

    var lastIndexAskedFor: Int? = nil
    func cellAtIndex(index: Int) -> UITableViewCell {
        lastIndexAskedFor = index
        return UITableViewCell()
    }

    var tappedIndex : Int? = nil
    func didTapCell(index: Int) {
        tappedIndex = index
    }

    var footerHeightAskedFor: Bool = false
    func heightForFooter() -> CGFloat {
        footerHeightAskedFor = true
        return 40
    }

    var footerAskedFor: Bool = false
    func footerView() -> UIView {
        footerAskedFor = true
        return UIView()
    }
}

class ListCardSpec: QuickSpec {
    override func spec() {
        var subject: ListCard! = nil
        var delegate : FakeListCardDelegate! = nil

        beforeEach {
            subject = ListCard()
            delegate = FakeListCardDelegate()

            subject.configure(delegate)
        }

        describe("appearance") {
            it("should round the corners") {
                expect(subject.layer.cornerRadius).to(equal(5))
            }

            it("should mask to bounds") {
                expect(subject.layer.masksToBounds).to(beTruthy())
            }
        }

        describe("tableView") {
            it("have a cell for each bulb it's configured with") {
                expect(subject.tableView.numberOfRowsInSection(0)).to(equal(1))
                expect(delegate.numberCells).to(beTruthy())
            }

            describe("cells") {
                it("should get height") {
                    expect(subject.tableView(subject.tableView, heightForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0))).to(equal(40))
                    expect(delegate.lastHeightAskedFor).to(equal(0))
                }

                it("should query the delegate") {
                    let cell1 = subject.tableView(subject.tableView, cellForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0))
                    expect(cell1).to(beAnInstanceOf(UITableViewCell.self))
                    expect(delegate.lastIndexAskedFor).to(equal(0))
                }

                describe("Tapping on a cell") {
                    it("should notify the delegate") {
                        subject.tableView(subject.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                        expect(delegate.tappedIndex).to(equal(0))
                    }
                }
            }

            describe("footer") {
                it("should query the delegate") {
                    expect(subject.tableView(subject.tableView, heightForFooterInSection: 0)).to(equal(40))
                    expect(delegate.footerHeightAskedFor).to(beTruthy())

                    expect(subject.tableView(subject.tableView, viewForFooterInSection: 0)).to(beAnInstanceOf(UIView.self))
                    expect(delegate.footerAskedFor).to(beTruthy())
                }
            }
        }
    }
}
