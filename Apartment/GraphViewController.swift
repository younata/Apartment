import UIKit
import ApartKit
import PureLayout
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

    private let scrollView = UIScrollView(forAutoLayout: ())

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.scrollView)

        self.scrollView.autoPinEdgesToSuperviewEdges()
        self.scrollView.contentOffset = CGPoint.zero
        self.scrollView.scrollEnabled = true
        self.scrollView.maximumZoomScale = 4
        self.scrollView.minimumZoomScale = 1
        self.scrollView.delegate = self
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.changeScrollViewSize(self.view.bounds.size)
    }

    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        if let chart = self.chart {
            self.changeScrollViewSize(size)
            self.scrollView.contentOffset = CGPoint.zero
            chart.view.bounds = CGRect(x: 0, y: 0, width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height)
            chart.clearView()
        }
    }

    public private(set) var chart: Chart? {
        didSet {
            if let old = oldValue {
                old.view.removeFromSuperview()
            }
            if let new = chart {
                new.view.clipsToBounds = false
                self.scrollView.addSubview(new.view)
                self.scrollView.setZoomScale(1, animated: true)
            }
        }
    }

    private func changeScrollViewSize(size: CGSize) {
        let height = self.scrollView.contentInset.top + self.scrollView.contentInset.bottom

        self.scrollView.contentSize = CGSizeMake(size.width, size.height - height)
        self.scrollView.setZoomScale(1, animated: true)
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

                    let frame = CGRect(x: 0, y: 0, width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height)

                    if isNumericalData {
                        self.chart = self.plotLineGraph(states, frame: frame)
                    } else {
                        self.chart = self.plotHistogram(states, frame: frame)
                    }
                }
            }
        }
    }

    private let chartSettings: ChartSettings = {
        let chartSettings = ChartSettings()
        chartSettings.top = 10
        chartSettings.trailing = 20
        chartSettings.leading = 10
        chartSettings.bottom = 10
        return chartSettings
    }()

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

        let axisData: (min: Double, max: Double) = pointData.reduce((min: Double.infinity, max: -Double.infinity)) { extreme, point in
            let lowest = min(extreme.min, point.1)
            let highest = max(extreme.max, point.1)
            return (min: lowest, max: highest)
        }

        let range = axisData.max - axisData.min
        let chartMax = ceil(axisData.max + (range / 10))
        let chartMin = floor(axisData.min - (range / 20))
        let step = max((chartMax - chartMin) / 10.0, 0.1)

        let chartConfig = ChartConfigXY(
            chartSettings: self.chartSettings,
            xAxisConfig: ChartAxisConfig(from: 0, to: (mostRecentDate - initialDate) + 1, by: 1),
            yAxisConfig: ChartAxisConfig(from: chartMin, to: chartMax, by: step)
        )

        return LineChart(frame: frame,
            chartConfig: chartConfig,
            xTitle: "Time (Hours since midnight)",
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
        let axisMax = ceil(barData.reduce(Double(0), combine: {  max($0, $1.1) }))
        let step = max(axisMax / 10.0, 0.1)

        let chartConfig = BarsChartConfig(
            chartSettings: self.chartSettings,
            valsAxisConfig: ChartAxisConfig(from: 0, to: axisMax + step, by: step)
        )
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

extension GraphViewController: UIScrollViewDelegate {
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.chart?.view
    }
}
