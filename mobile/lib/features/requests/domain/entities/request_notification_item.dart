import 'submission_kind.dart';
import 'submission_status.dart';

/// Model item notifikasi pembaruan pengajuan
class RequestNotificationItem {
  final String id;
  final String requestId;
  final SubmissionKind kind;
  final String requestTitle;
  final SubmissionStatus status;
  final String headline;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final String? reviewerName;
  final String? reviewNote;
  final Map<String, dynamic>? rawRequest;
  final DateTime? createdAt;

  const RequestNotificationItem({
    required this.id,
    required this.requestId,
    required this.kind,
    required this.requestTitle,
    required this.status,
    required this.headline,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
    this.reviewerName,
    this.reviewNote,
    this.rawRequest,
    this.createdAt,
  });

  RequestNotificationItem copyWith({
    bool? isUnread,
    DateTime? createdAt,
  }) {
    return RequestNotificationItem(
      id: id,
      requestId: requestId,
      kind: kind,
      requestTitle: requestTitle,
      status: status,
      headline: headline,
      message: message,
      timeAgo: timeAgo,
      isUnread: isUnread ?? this.isUnread,
      reviewerName: reviewerName,
      reviewNote: reviewNote,
      rawRequest: rawRequest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
