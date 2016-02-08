import UIKit
import ApartKit
import SwiftCharts

public class GraphViewController: UIViewController {
    public var entity: State? {
        didSet {
            self.title = entity?.displayName
            self.chart = nil
            self.retrieveHistory()
        }
    }

    private lazy var homeRepository: HomeRepository = {
        return self.injector!.create(HomeRepository)!
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
    }

    public private(set) var chart: Chart? {
        didSet {
            if let old = oldValue {
                old.view.removeFromSuperview()
            }
            if let new = chart {
                self.view.addSubview(new.view)
            }
        }
    }

    private func retrieveHistory() {
        if let entity = self.entity {
            self.homeRepository.history(entity) { states in
                if states.isEmpty {
                    self.unableToRetrieveHistory()
                } else {
                    let states = states.sort {
                        return $0.lastChanged.timeIntervalSinceReferenceDate < $1.lastChanged.timeIntervalSinceReferenceDate
                        }.reduce([State]()) { array, state in
                            if let last = array.last {
                                if last == state {
                                    return array
                                }
                            }
                            return array + [state]
                    }
                    let isNumericalData = states.filter({ $0.sensorState == nil }).isEmpty

                    let frame = self.view.bounds.insetBy(dx: 10, dy: 40).offsetBy(dx: 0, dy: 40)

                    if isNumericalData {
                        self.chart = self.plotLineGraph(states, frame: frame)
                    } else {
                        self.chart = self.plotHistogram(states, frame: frame)
                    }
                }
            }
        }
    }

    private func plotLineGraph(states: [State], frame: CGRect) -> LineChart {
        let initialDate: Double
        let mostRecentDate: Double

        let pointData: [(Double, Double)]
        if states.isEmpty {
            initialDate = 0
            mostRecentDate = 1
            pointData = [(0, 1), (1, 1)]
        } else if states.count == 1 {
            initialDate = 0
            mostRecentDate = 1
            let sensorData = states[0].sensorState!
            pointData = [
                (0, sensorData),
                (1, sensorData),
            ]
        } else {
            initialDate = (states.first?.lastChanged.timeIntervalSinceReferenceDate ?? 0) / 3600
            mostRecentDate = (states.last?.lastChanged.timeIntervalSinceReferenceDate ?? 3600) / 3600
            pointData = states.map {
                let changeDate = ($0.lastChanged.timeIntervalSinceReferenceDate ?? 0) / 3600
                return (changeDate - initialDate, $0.sensorState!)
            }
        }

        let axisData: (min: Double, max: Double) = pointData.reduce((min: Double.infinity, max: -Double.infinity)) {
            let lowest = min($0.min, $1.1)
            let highest = max($0.max, $1.1)
            return (min: lowest, max: highest)
        }

        let step = max((axisData.max - axisData.min) / 10.0, 0.1)

        let chartConfig = ChartConfigXY(
            xAxisConfig: ChartAxisConfig(from: 0, to: mostRecentDate - initialDate, by: 1),
            yAxisConfig: ChartAxisConfig(from: axisData.min - (step / 2), to: axisData.max + (step / 2), by: step)
        )

        return LineChart(frame: frame,
            chartConfig: chartConfig,
            xTitle: "Time (Hours)",
            yTitle: self.entity?.sensorUnitOfMeasurement ?? "Unit",
            line: (chartPoints: pointData, color: UIColor.blueColor()))
    }

    private func plotHistogram(states: [State], frame: CGRect) -> BarsChart {
        var data: [String: Double] = [:]
        for (idx, state) in states.enumerate() {
            guard (idx + 1) != states.count else { break }

            let nextState = states[idx+1]
            let timeUntilNextState = nextState.lastChanged.timeIntervalSinceReferenceDate - state.lastChanged.timeIntervalSinceReferenceDate

            if let value = data[state.state] {
                data[state.state] = value + timeUntilNextState
            } else {
                data[state.state] = timeUntilNextState
            }
        }

        let barData = data.map { ($0.desnake, $1 / 3600) }
        let axisMax = barData.reduce(Double(0)) {
            return max($0, $1.1)
        }
        let step = max(axisMax / 10.0, 0.1)

        let chartConfig = BarsChartConfig(valsAxisConfig: ChartAxisConfig(from: 0, to: axisMax + step, by: step))
        return BarsChart(frame: frame,
            chartConfig: chartConfig,
            xTitle: self.entity?.displayName ?? "States",
            yTitle: "Time (Hours)",
            bars: barData,
            color: UIColor.blueColor(),
            barWidth: 10)
    }

    private func unableToRetrieveHistory() {
        let alert = UIAlertController(title: "Unable to retrieve history", message: nil, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "Try again", style: .Default) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.retrieveHistory()
        })

        alert.addAction(UIAlertAction(title: "Oh well", style: .Cancel) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        })

        self.presentViewController(alert, animated: true, completion: nil)
    }
}
