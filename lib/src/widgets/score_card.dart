import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score, required this.lvl});

  final ValueNotifier<int> score;
  final ValueNotifier<int> lvl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<int>(
            valueListenable: score,
            builder: (context, score, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
                child: Text(
                  'Score: $score'.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
              );
            }),
        ValueListenableBuilder<int>(
            valueListenable: lvl,
            builder: (context, lvl, child) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
                child: Text(
                  'Level: $lvl'.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
              );
            }),
      ],
    );
  }
}
