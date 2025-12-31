class CompanyConfig {
  final int fullTruckAmount;

  CompanyConfig({required this.fullTruckAmount});

  factory CompanyConfig.fromJson(Map<String, dynamic> json) {
    return CompanyConfig(fullTruckAmount: json["fullTruckAmount"] ?? 80000);
  }
}
