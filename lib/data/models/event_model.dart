class EventModel {
  final String id;
  final String title;
  final String venue;
  final DateTime eventDate;
  final String timeRemaining;
  
  EventModel({
    required this.id,
    required this.title,
    required this.venue,
    required this.eventDate,
    required this.timeRemaining,
  });
  
  // Mock data generation
  static List<EventModel> getDummyEvents() {
    return [
      EventModel(
        id: '1',
        title: "PM Cup Men's National Cricket...",
        venue: "Extratech Oval International Cricket Stadium",
        eventDate: DateTime.now().add(Duration(days: 2)),
        timeRemaining: "2 Days left",
      ),
      EventModel(
        id: '2',
        title: "Gandaki vs Koshi Men's PM Cup",
        venue: "Friday, 03-12-2081",
        eventDate: DateTime.now().add(Duration(hours: 8)),
        timeRemaining: "8 Hours left",
      ),
      EventModel(
        id: '3',
        title: "Gandaki vs Koshi Men's PM Cup",
        venue: "Friday, 03-12-2081",
        eventDate: DateTime.now().add(Duration(hours: 8)),
        timeRemaining: "8 Hours left",
      ),
    ];
  }
  
  // This method will help when we integrate with real API
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      venue: json['venue'],
      eventDate: DateTime.parse(json['event_date']),
      timeRemaining: json['time_remaining'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'venue': venue,
      'event_date': eventDate.toIso8601String(),
      'time_remaining': timeRemaining,
    };
  }
}