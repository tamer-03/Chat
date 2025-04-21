class BaseResponseModel<T> {
  final String message;
  final int status;
  final List<T>? data;

  BaseResponseModel({
    required this.message,
    required this.status,
    this.data,
  });

  factory BaseResponseModel.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final dynamic value = json['value'];

    return BaseResponseModel<T>(
      message: json['message'],
      status: json['status'],
      data: (value is List)
          ? value
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
