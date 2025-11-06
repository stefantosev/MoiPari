import 'package:json_annotation/json_annotation.dart';


part 'user.g.dart';

@JsonSerializable()
class User{
  late String email, password, name, currency;

  late DateTime createdAt;

  User(this.email, this.password, this.name, this.currency, this.createdAt);



  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // @OneToMany(mappedBy = "user", cascade = [CascadeType.ALL], orphanRemoval = true)
  // val categories: MutableList<Category> = mutableListOf(),
  //
  // @OneToMany(mappedBy = "user", cascade = [CascadeType.ALL], orphanRemoval = true)
  // val expenses: MutableList<Expense> = mutableListOf(),
  //
  // @OneToMany(mappedBy = "user", cascade = [CascadeType.ALL], fetch = FetchType.LAZY)
  // val budget: MutableList<Budget> = mutableListOf()
}
