class UserModel {
  String? userId;
  String? name;
  String? accountNumber;
  String? pin;
  String? balance;
  String? email;  // Add the email field
  bool blocked;

  UserModel({
    this.userId,
    this.name,
    this.accountNumber,
    this.pin,
    this.balance,
    this.email,  // Initialize the email field
    this.blocked = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json["user_id"],
    name: json["name"],
    accountNumber: json["account_number"],
    pin: json["pin"],
    balance: json["balance"],
    email: json["email"],  // Parse the email field
    blocked: json['blocked'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "account_number": accountNumber,
    "pin": pin,
    "balance": balance,
    'email': email,  // Include the email field in the JSON representation
    'blocked': blocked,
  };
}
