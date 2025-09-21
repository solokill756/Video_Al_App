class Unit {
  const Unit._();
  static const Unit unit = Unit._();

  @override
  String toString() => 'Unit';

  @override
  bool operator ==(Object other) => other is Unit;

  @override
  int get hashCode => 0;
}
