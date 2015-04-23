import Quick
import Nimble
import UIKit
import MaterialKit

class LocationCardSpec: QuickSpec {
    override func spec() {
        var subject : LocationCard! = nil

        beforeEach {
            subject = LocationCard()
        }

        it("should have two cells") {
            expect(subject.numberOfCells()).to(equal(2))
        }

        it("should add a tableHeader on -configure:") {
            let tableView = UITableView()
            subject.configure(tableView)

            if let view = tableView.tableHeaderView?.subviews.first as? MKLabel {
                expect(view.text).to(equal("Location"))
            } else {
                expect(false).to(beTruthy())
            }
        }

        describe("Calculating card height") {
            it("be 120") {
                expect(subject.cardHeight()).to(equal(120))
            }

            context("with a selected cell") {
                it("should be 280") {
                    subject.didTapCell(0)
                    expect(subject.cardHeight()).to(equal(280))
                }
            }
        }

        describe("the first cell") {
            var cell: UITableViewCell! = nil
            beforeEach {
                cell = subject.cellAtIndex(0) as? UITableViewCell
            }

            it("should be a UITableViewCell") {
                expect(cell).toNot(beNil())
            }

            it("should say 'Arriving'") {
                expect(cell.textLabel?.text).to(equal("Arriving"))
            }
        }

        describe("the second cell") {
            var cell: UITableViewCell! = nil
            beforeEach {
                cell = subject.cellAtIndex(1) as? UITableViewCell
            }

            it("should be a UITableViewCell") {
                expect(cell).toNot(beNil())
            }

            it("should say 'Leaving'") {
                expect(cell.textLabel?.text).to(equal("Leaving"))
            }
        }

        describe("tapping on a cell") {
            beforeEach {
                subject.didTapCell(0)
            }

            it("should expand the cell") {
                expect(subject.heightForCell(0)).to(equal(200))
            }
        }
    }
}
