import 'package:freezed_annotation/freezed_annotation.dart';

part 'mastra_response_model.freezed.dart';
part 'mastra_response_model.g.dart';

@freezed
class MastraResponseModel with _$MastraResponseModel {
  const factory MastraResponseModel({
    String? text,
    MastraToolOutput? toolOutput,
  }) = _MastraResponseModel;

  factory MastraResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MastraResponseModelFromJson(json);
}

@freezed
class MastraToolOutput with _$MastraToolOutput {
  const factory MastraToolOutput({
    List<MastraFormattedResult>? formattedResults,
    MastraSearchResults? searchResults,
  }) = _MastraToolOutput;

  factory MastraToolOutput.fromJson(Map<String, dynamic> json) =>
      _$MastraToolOutputFromJson(json);
}

@freezed
class MastraFormattedResult with _$MastraFormattedResult {
  const factory MastraFormattedResult({
    required String videoPath,
    String? title,
    required double ptsTime,
    String? transcript,
  }) = _MastraFormattedResult;

  factory MastraFormattedResult.fromJson(Map<String, dynamic> json) =>
      _$MastraFormattedResultFromJson(json);
}

@freezed
class MastraSearchResults with _$MastraSearchResults {
  const factory MastraSearchResults({
    List<String>? imagePaths,
    List<String>? videoPaths,
    List<double>? scores,
    List<double>? ptsTimes,
  }) = _MastraSearchResults;

  factory MastraSearchResults.fromJson(Map<String, dynamic> json) =>
      _$MastraSearchResultsFromJson(json);
}

@freezed
class ConversationMessage with _$ConversationMessage {
  const factory ConversationMessage({
    required String role, // 'user' | 'assistant' | 'system'
    required String content,
  }) = _ConversationMessage;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageFromJson(json);
}
