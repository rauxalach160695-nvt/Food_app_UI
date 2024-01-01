import '../models/food_info_model.dart';

class Message {
  final String text;
  final DateTime date;
  final bool isSentByMe;
  final List<FoodInfo> listFood;

  const Message(
      {required this.text,
      required this.date,
      required this.isSentByMe,
      required this.listFood});
}
