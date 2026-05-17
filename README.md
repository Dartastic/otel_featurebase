# otel_featurebase

Dartastic OpenTelemetry bridge for Featurebase (customer feedback + roadmap).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_featurebase/otel_featurebase.dart';

await tracedFeaturebase<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return FeaturebaseCallResult(value: r, result: FeaturebaseResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutFeaturebaseInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
