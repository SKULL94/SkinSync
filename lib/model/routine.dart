class Routine {
  final String userId;
  final int streakCount;
  final String lastUpdatedDay;
  final List<RoutineItem> allRoutines;
  final Map completedRoutines;

  Routine( {
    required this.userId,
    required this.streakCount,
    required this.lastUpdatedDay,
    required this.allRoutines,
    required this.completedRoutines,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    List<RoutineItem> routines = [];
    for (var item in json['allRoutines']) {
      routines.add(RoutineItem.fromJson(item));
    }
    return Routine(
      userId: json['userId'],
      streakCount: json['streakCount'],
      lastUpdatedDay: json['lastUpdatedDay'],
      allRoutines: routines,
      completedRoutines: json['completedRoutines'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'streakCount': streakCount,
        'lastUpdatedDay': lastUpdatedDay,
        'allRoutines': allRoutines.map((routine) => routine.toJson()).toList(),
        'completedRoutines': completedRoutines,
      };

  factory Routine.createNew({required String userId, required int streakCount, required lastUpdatedDay,required completedRoutines, required List<RoutineItem> allRoutines}) {
    return Routine(
      userId: userId,
      streakCount: streakCount,
      lastUpdatedDay: lastUpdatedDay,
      completedRoutines: completedRoutines,
      allRoutines: allRoutines,
    );
  }
}

class RoutineItem {
  final String routineId;
  final String completedDate;
  final bool isRoutineDone;
  final String imagePath;

  RoutineItem({
    required this.routineId,
    required this.completedDate,
    required this.isRoutineDone,
    required this.imagePath,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) => RoutineItem(
        routineId: json['routineId'],
        completedDate: json['completedDate'],
        isRoutineDone: json['isRoutineDone'],
        imagePath: json['imagePath'],
      );

  Map<String, dynamic> toJson() => {
        'routineId': routineId,
        'completedDate': completedDate,
        'isRoutineDone': isRoutineDone,
        'imagePath': imagePath,
      };

  factory RoutineItem.createNew({required String routineId, required String completedDate, required bool isRoutineDone, required String imagePath}) {
    return RoutineItem(
      routineId: routineId,
      completedDate: completedDate,
      isRoutineDone: isRoutineDone,
      imagePath: imagePath,
    );
  }
}

  class RoutineStaticData{
    String name = "";
    String desc = "";

    RoutineStaticData({
      required this.name, required this.desc
    });
  }

  
