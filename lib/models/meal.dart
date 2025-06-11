class Meal {
  final String id;
  final String image;
  final String title;
  final String meal;
  final String calories;
  final String time;
  final List<String> ingredients;
  final double price;
  final double rating;
  final int reviews;
  final String protein;
  final String fiber;
  final String carbs;
  final String fat;

  Meal({
    required this.id,
    required this.image,
    required this.title,
    required this.meal,
    required this.calories,
    required this.time,
    required this.ingredients,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.protein,
    required this.price,
    this.rating = 0.0,
    this.reviews = 0,
  });

  // Convert Firestore document to Meal object
  factory Meal.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Meal(
      id: documentId,
      image: data['image'] ?? 'assets/images/default_meal.jpg',
      title: data['title'] ?? '',
      meal: data['meal'] ?? '',
      calories: data['calories'] ?? '',
      time: data['time'] ?? '',
      ingredients: data['ingredients'] != null
          ? List<String>.from(data['ingredients'])
          : [],
      price: (data['price'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      carbs: data['carbs'] ?? "0",
      fat: data['fat'] ?? "0",
      fiber: data['fiber'] ?? "0",
      protein: data['protein'] ?? "0",
    );
  }

  // Convert Meal object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'image': image,
      'title': title,
      'meal': meal,
      'calories': calories,
      'time': time,
      'ingredients': ingredients,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      "protein": protein,
      "fat": fat,
      "fiber": fiber,
      "carbs": carbs
    };
  }
}
