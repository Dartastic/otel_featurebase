// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_featurebase_suppression.dart';

class FeaturebaseResult {
  /// Creates a result.
  const FeaturebaseResult({
    this.organizationId,
    this.boardId,
    this.postId,
    this.postStatus,
    this.upvotes,
    this.commentsCount,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? organizationId;
  final String? boardId;
  final String? postId;
  final String? postStatus;
  final int? upvotes;
  final int? commentsCount;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class FeaturebaseCallResult<T> {
  /// Creates a call result.
  const FeaturebaseCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final FeaturebaseResult? result;
}

Future<T> tracedFeaturebase<T>({
  required String operation,
  required Future<FeaturebaseCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (featurebaseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_featurebase');
  final span = t.startSpan('featurebase $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'featurebase')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.organizationId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('featurebase.org.id', res.organizationId!)
        ]));
      }
      if (res.boardId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('featurebase.board.id', res.boardId!)]));
      }
      if (res.postId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('featurebase.post.id', res.postId!)]));
      }
      if (res.postStatus != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('featurebase.post.status', res.postStatus!)
        ]));
      }
      if (res.upvotes != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('featurebase.post.upvotes', res.upvotes!)]));
      }
      if (res.commentsCount != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('featurebase.post.comments', res.commentsCount!)
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('featurebase.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'featurebase.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
