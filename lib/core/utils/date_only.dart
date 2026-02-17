DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
