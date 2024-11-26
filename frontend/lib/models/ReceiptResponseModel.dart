class ReceiptResponse {
  final bool isSuccess;
  final String msg;
  final List<Item> items;

  ReceiptResponse({
    required this.isSuccess,
    required this.msg,
    required this.items,
  });

  factory ReceiptResponse.fromJson(Map<String, dynamic> data) {
    return ReceiptResponse(
      isSuccess: data['isSuccess'],
      msg: data['msg'],
      items: (data['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'msg': msg,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class Item {
  final int id;
  final String itemName;
  final String category;
  final double price;
  final int quantity;

  Item({
    required this.id,
    required this.itemName,
    required this.category,
    required this.price,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> data) {
    return Item(
      id: data['id'],
      itemName: data['item_name'],
      category: data['category'],
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'price': price,
      'quantity': quantity,
    };
  }
}