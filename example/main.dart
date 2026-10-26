// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_featurebase/otel_featurebase.dart';

/// Traces Featurebase calls with OpenTelemetry.
///
/// `otel_featurebase` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Featurebase call in
/// [tracedFeaturebase]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'featurebase-example');

  // Traces a Featurebase call.
  final featurebaseId = await tracedFeaturebase<String>(
    operation: 'create',
    invoke: () async {
      // Make the Featurebase call here, then report what it returned.
      const id = 'featurebase_8f3a2c';
      return const FeaturebaseCallResult(
          value: id,
          result: FeaturebaseResult(
              organizationId: 'organization_8f3a2c',
              boardId: 'board_8f3a2c',
              postId: 'post_8f3a2c',
              postStatus: 'succeeded',
              upvotes: 1,
              commentsCount: 3,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedFeaturebase create returned $featurebaseId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutFeaturebaseInstrumentationAsync.
  await runWithoutFeaturebaseInstrumentationAsync(
    () => tracedFeaturebase<String>(
      operation: 'create',
      invoke: () async {
        const id = 'featurebase_8f3a2c';
        return const FeaturebaseCallResult(
            value: id,
            result: FeaturebaseResult(
                organizationId: 'organization_8f3a2c',
                boardId: 'board_8f3a2c',
                postId: 'post_8f3a2c',
                postStatus: 'succeeded',
                upvotes: 1,
                commentsCount: 3,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
