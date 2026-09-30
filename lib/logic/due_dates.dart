/// Pure helpers for target (due) dates. Only the calendar date matters: the
/// time of day on either side is ignored.
library;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// `Oct 5` for dates in [today]'s year, `Jan 5, 2028` otherwise, so a goal
/// due years from now (the picker allows ten) is not mistaken for this year.
String formatDueDate(DateTime due, DateTime today) {
  final base = '${_months[due.month - 1]} ${due.day}';
  return due.year == today.year ? base : '$base, ${due.year}';
}

/// Whole calendar days from [today] until [due]; negative when overdue.
/// Computed on UTC dates so daylight-saving shifts never cause off-by-one.
int daysUntil(DateTime due, DateTime today) =>
    _dateOnly(due).difference(_dateOnly(today)).inDays;

/// An unfinished goal is overdue once its due date is before [today].
bool isOverdue({
  required DateTime? due,
  required bool complete,
  required DateTime today,
}) =>
    !complete && due != null && daysUntil(due, today) < 0;

/// Short status for a due date: `Overdue · Oct 5`, `Due today`,
/// `Due tomorrow` or the formatted date.
String dueLabel({
  required DateTime due,
  required bool complete,
  required DateTime today,
}) {
  final days = daysUntil(due, today);
  final date = formatDueDate(due, today);
  if (complete) return date;
  if (days < 0) return 'Overdue · $date';
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  return date;
}
