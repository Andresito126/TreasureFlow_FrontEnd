class SignedUpload {
  final String signature;
  final int timestamp;
  final String apiKey;
  final String cloudName;
  final String folder;

  const SignedUpload({
    required this.signature,
    required this.timestamp,
    required this.apiKey,
    required this.cloudName,
    required this.folder,
  });

  factory SignedUpload.fromJson(Map<String, dynamic> json) {
    return SignedUpload(
      signature: json['signature'] as String,
      timestamp: json['timestamp'] as int,
      apiKey: json['apiKey'] as String,
      cloudName: json['cloudName'] as String,
      folder: json['folder'] as String,
    );
  }
}