// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_featurebase/otel_featurebase.dart';
import 'package:test/test.dart';

void main() {
  group('otel_featurebase', () {
    test('suppression toggles in zone', () async {
      expect(featurebaseInstrumentationSuppressed(), isFalse);
      await runWithoutFeaturebaseInstrumentationAsync(() async {
        expect(featurebaseInstrumentationSuppressed(), isTrue);
      });
      expect(featurebaseInstrumentationSuppressed(), isFalse);
    });

    test('FeaturebaseResult fields default null', () {
      const r = FeaturebaseResult();
      expect(r.statusCode, isNull);
    });
  });
}
