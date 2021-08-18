import 'package:signalr_core/signalr_core.dart';

class IntervalRetryPolicy extends RetryPolicy {
  final List<Duration> _intervals;

  IntervalRetryPolicy(this._intervals);

  @override
  int? nextRetryDelayInMilliseconds(RetryContext retryContext) {
    int previousRetries = retryContext.previousRetryCount ?? 0;

    if (previousRetries < _intervals.length) {
      return _intervals[previousRetries].inMilliseconds;
    }

    return _intervals.last.inMilliseconds;
  }
}
