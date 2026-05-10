/// Curva de nível: XP acumulado para alcançar o nível \(L\) é \(100 \times \frac{(L-1)L}{2}\)
/// (100 + 200 + … + 100(L-1)).
int xpThresholdForLevel(int level) {
  if (level <= 1) return 0;
  return 50 * (level - 1) * level;
}

int computeLevelFromTotalXp(int totalXp) {
  var l = 1;
  while (xpThresholdForLevel(l + 1) <= totalXp) {
    l++;
  }
  return l;
}

int xpIntoCurrentLevel(int totalXp) {
  final l = computeLevelFromTotalXp(totalXp);
  return totalXp - xpThresholdForLevel(l);
}

int xpToReachNextLevel(int totalXp) {
  final l = computeLevelFromTotalXp(totalXp);
  return xpThresholdForLevel(l + 1) - totalXp;
}
