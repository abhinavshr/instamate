import 'dart:convert';
import 'package:http/http.dart' as http;

class ReelApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';

  static Future<http.Response> fetchReels(String token) {
    return http.get(
      Uri.parse('$_baseUrl/reels'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> toggleReelLike(String token, String reelId) {
    return http.post(
      Uri.parse('$_baseUrl/reels/$reelId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getReelLikeStatus(String token, String reelId) {
    return http.get(
      Uri.parse('$_baseUrl/reels/$reelId/like-status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getReelComments(String token, String reelId) {
    return http.get(
      Uri.parse('$_baseUrl/$reelId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> postReelComment(
      String token,
      String reelId,
      String comment,
      ) {
    return http.post(
      Uri.parse('$_baseUrl/reels/$reelId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'comment': comment}),
    );
  }

  static Future<http.Response> postReelCommentReply(
      String token,
      String reelId,
      String commentId,
      String comment,
      ) {
    return http.post(
      Uri.parse('$_baseUrl/reels/$reelId/comments/$commentId/reply'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'comment': comment}),
    );
  }

  static Future<http.Response> deleteReelComment(
      String token,
      String reelId,
      String commentId,
      ) {
    return http.delete(
      Uri.parse('$_baseUrl/reels/$reelId/comments/$commentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}