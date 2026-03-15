// lib/core/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:http/http.dart' hide MultipartFile, Response;
import 'package:tripwise/data/config/tripwise.dart';

import 'cache_service.dart';

/// ApiService: Dio wrapper with token injection, refresh-on-401 with queueing,
/// standard request helpers, multipart upload & presigned put support.
class ApiService {
  final Dio dio;
  final CacheService cache;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _queue = [];

  ApiService._(this.dio, this.cache) {
    _setup();
  }

  /// Construct with defaults (pass custom baseUrl if needed)
  factory ApiService({String baseUrl = Tripwise.baseUrl, CacheService? cacheService}) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    final cache = cacheService ?? Get.find<CacheService>();
    return ApiService._(dio, cache);
  }

  void _setup() {
    // timeouts
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.sendTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    // logging
    dio.interceptors.add(
      LogInterceptor(requestHeader: true, requestBody: false, responseBody: false, error: true),
    );

    // main interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async {
        try {
          final token = await cache.readAccessToken();
          if (token != null && token.isNotEmpty) {
            opts.headers['Authorization'] = 'Bearer $token';
          }
          // default content-type, can be overridden
          opts.headers.putIfAbsent('Content-Type', () => 'application/json');
        } catch (e) {
          // swallow; let request continue
        }
        return handler.next(opts);
      },
      onError: (err, handler) async {
        final res = err.response;
        final reqOptions = err.requestOptions;

        // Only try refresh for 401 responses
        if (res != null && res.statusCode == 401) {
          // Avoid infinite loops: if this request was already retried, forward error
          if (reqOptions.extra['retry'] == true) {
            return handler.next(err);
          }

          // If refresh is in progress, queue this request
          if (_isRefreshing) {
            final completer = Completer<Response>();
            _queue.add(_QueuedRequest(reqOptions, completer));
            try {
              final r = await completer.future;
              return handler.resolve(r);
            } catch (e) {
              return handler.next(err);
            }
          }

          _isRefreshing = true;
          final refreshed = await _tryRefreshToken();

          _isRefreshing = false;

          if (!refreshed) {
            // token refresh failed: clear tokens and forward error
            await cache.clearAll();
            // Optionally: redirect to login using Get.offAllNamed('/login');
            return handler.next(err);
          }

          // Retry original request with new token
          try {
            final access = await cache.readAccessToken();
            if (access != null) {
              reqOptions.headers['Authorization'] = 'Bearer $access';
            }
            reqOptions.extra = {...reqOptions.extra, 'retry': true};

            final response = await dio.fetch(reqOptions);
            // resolve queued requests
            _resolveQueue();
            return handler.resolve(response);
          } catch (retryErr) {
            _rejectQueue(retryErr);
            return handler.next(err);
          }
        }

        // non-401 or no response
        return handler.next(err);
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    final refresh = await cache.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final resp = await dio.post(
        '/auth/refresh',
        data: {},
        options: Options(
          headers: {'Authorization': 'Bearer $refresh'},
          extra: {'isRefreshCall': true},
        ),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        // Expecting {access_token, refresh_token}
        final newAccess = _readTokenFromResponse(data, 'access_token');
        final newRefresh = _readTokenFromResponse(data, 'refresh_token');
        if (newAccess != null) await cache.saveAccessToken(newAccess);
        if (newRefresh != null) await cache.saveRefreshToken(newRefresh);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String? _readTokenFromResponse(dynamic data, String key) {
    try {
      if (data is Map) {
        if (data.containsKey(key)) return data[key]?.toString();
        if (data.containsKey('data') && data['data'] is Map && data['data'].containsKey(key)) {
          return data['data'][key]?.toString();
        }
      } else if (data is String) {
        // maybe body is a JSON string
        final parsed = jsonDecode(data);
        if (parsed is Map && parsed.containsKey(key)) return parsed[key]?.toString();
      }
    } catch (_) {}
    return null;
  }

  void _resolveQueue() async {
    while (_queue.isNotEmpty) {
      final q = _queue.removeAt(0);
      try {
        final access = await cache.readAccessToken();
        if (access != null) q.requestOptions.headers['Authorization'] = 'Bearer $access';
        final r = await dio.fetch(q.requestOptions);
        q.completer.complete(r);
      } catch (e) {
        q.completer.completeError(e);
      }
    }
  }

  void _rejectQueue(Object err) {
    for (final q in _queue) {
      q.completer.completeError(err);
    }
    _queue.clear();
  }

  // -----------------------
  // Public Generic Request Helpers
  // -----------------------

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool raw = false,
    Duration? timeout,
  }) async {
    final options = Options(headers: headers);
    try {
      final resp = await dio.get(path, queryParameters: queryParameters, options: options);
      return _handleResponse<T>(resp, raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool raw = false,
    Duration? timeout,
  }) async {
    final options = Options(headers: headers);
    try {
      final resp = await dio.post(path, data: body, options: options);
      return _handleResponse<T>(resp, raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool raw = false,
  }) async {
    final options = Options(headers: headers);
    try {
      final resp = await dio.put(path, data: body, options: options);
      return _handleResponse<T>(resp, raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool raw = false,
  }) async {
    final options = Options(headers: headers);
    try {
      final resp = await dio.patch(path, data: body, options: options);
      return _handleResponse<T>(resp, raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool raw = false,
  }) async {
    final options = Options(headers: headers);
    try {
      final resp = await dio.delete(path, data: body, options: options);
      return _handleResponse<T>(resp, raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // -----------------------
  // Multipart & Presigned Uploads
  // -----------------------

  /// Multi-file multipart upload. fieldName is the API field expected for files.
  Future<T> multipart<T>({
    required String path,
    required String fieldName,
    required List<File> files,
    Map<String, dynamic>? fields,
    Map<String, String>? headers,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final form = FormData();
    fields?.forEach((k, v) => form.fields.add(MapEntry(k, v.toString())));

    for (final f in files) {
      final filename = f.path.split(Platform.pathSeparator).last;
      final mime = _mimeFromFilename(filename) ?? 'application/octet-stream';
      final parts = mime.split('/');
      final m = MediaType(parts[0], parts[1]);
      final bytes = await f.readAsBytes();
      form.files.add(MapEntry(
        fieldName,
        MultipartFile.fromBytes(bytes, filename: filename, contentType: m),
      ));
    }
    try {
      final resp = await dio.post(path, data: form, options: Options(headers: headers), onSendProgress: onSendProgress);
      return _handleResponse<T>(resp, false);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Request presigned URL from your backend and upload using a separate PUT (binary)
  // Future<bool> uploadToPresignedUrl({
  //   required String presignPath, // backend endpoint to create presigned URL
  //   required String filename,
  //   required File file,
  //   Map<String, String>? extraHeaders,
  // }) async {
  //   try {
  //     // 1) Get presigned url & key from backend
  //     final presignResp = await post<Map<String, dynamic>>(presignPath, body: {'filename': filename});
  //     final uploadUrl = presignResp['uploadUrl'] as String?;
  //     if (uploadUrl == null) throw ApiException('No uploadUrl returned');
  //     // 2) Upload binary using plain Dio (no auth header usually)
  //     final bytes = await file.readAsBytes();
  //     final putResp = await Dio().put(uploadUrl,
  //         data: Stream.fromIterable([bytes]),
  //         options: Options(headers: {'Content-Type': _mimeFromFilename(filename) ?? 'application/octet-stream'}));
  //     return putResp.statusCode == 200 || putResp.statusCode == 201;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // -----------------------
  // Helpers
  // -----------------------
  T _handleResponse<T>(Response resp, bool raw) {
    final status = resp.statusCode ?? 0;
    if (raw) return resp.data as T;
    if (status >= 200 && status < 300) {
      return resp.data as T;
    } else {
      throw ApiException('HTTP $status', resp.requestOptions.path, resp.data);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
      return ApiNotRespondingException('API not responding', e.requestOptions.path);
    } else if (e.error is SocketException) {
      return FetchDataException('No internet connection', e.requestOptions.path);
    } else if (e.response != null) {
      final status = e.response?.statusCode ?? 0;
      final data = e.response?.data;
      if (status == 401) return UnAuthorizedException(data?.toString() ?? 'Unauthorized', e.requestOptions.path);
      if (status == 404) return NotFoundException(data?.toString() ?? 'Not found', e.requestOptions.path);
      if (status >= 500) return ServerErrorException(data?.toString() ?? 'Server error', e.requestOptions.path);
      return ApiException('HTTP $status', e.requestOptions.path, data);
    } else {
      return ApiException(e.message ?? 'Unknown Dio error', e.requestOptions.path, null);
    }
  }

  String? _mimeFromFilename(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }
}

/// Internal queue holder
class _QueuedRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;
  _QueuedRequest(this.requestOptions, this.completer);
}

/// Exceptions
class ApiException implements Exception {
  final String message;
  final String path;
  final dynamic data;
  ApiException(this.message, this.path, [this.data]);
  @override
  String toString() => 'ApiException: $message (path: $path) data: $data';
}
class FetchDataException extends ApiException { FetchDataException(super.m, super.p); }
class ApiNotRespondingException extends ApiException { ApiNotRespondingException(super.m, super.p); }
class UnAuthorizedException extends ApiException { UnAuthorizedException(super.m, super.p); }
class NotFoundException extends ApiException { NotFoundException(super.m, super.p); }
class ServerErrorException extends ApiException { ServerErrorException(super.m, super.p); }
