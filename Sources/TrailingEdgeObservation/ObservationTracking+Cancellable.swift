import Combine

public func withCancellableDidSetObservationTracking<T>(
    _ apply: @escaping () -> T
) -> AnyCancellable {
    var tracking: ObservationTracking?
    track(apply) {
        tracking = $0
    }
    return AnyCancellable {
        tracking?.cancel()
    }
}

private func track<T>(
    _ apply: @escaping () -> T,
    trackingUpdate: @escaping (ObservationTracking) -> Void
) {
    let (_, accessList) = generateAccessList(apply)
    let tracking = ObservationTracking(accessList)
    trackingUpdate(tracking)
    ObservationTracking._installTracking(tracking, willSet: nil, didSet: { tracking in
        tracking.cancel()
        track(apply, trackingUpdate: trackingUpdate)
    })
}
