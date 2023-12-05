import TrailingEdgeObservation

@TrailingEdgeObservable
final class Observed {
    var count = 0
}

let observed = Observed()

withDidSetObservationTracking {
    print("Count is \(observed.count)")
}

observed.count += 1
observed.count += 2
observed.count += 3
