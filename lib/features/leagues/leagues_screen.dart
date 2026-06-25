import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/leagues/bots.dart';
import '../../core/leagues/leaderboard.dart';
import '../../core/models/enums.dart';

const _divisionLabels = {
  'bronze': 'Bronce',
  'silver': 'Plata',
  'gold': 'Oro',
  'platinum': 'Platino',
  'diamond': 'Diamante',
  'legend': 'Leyenda',
};

class LeaguesScreen extends ConsumerStatefulWidget {
  const LeaguesScreen({super.key});

  @override
  ConsumerState<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends ConsumerState<LeaguesScreen> {
  LeagueStateRow? _state;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s =
        await ref.read(leaguesServiceProvider).ensureCurrentWeek(DateTime.now());
    if (mounted) setState(() => _state = s);
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;
    return Scaffold(
      appBar: AppBar(title: const Text('Liga')),
      body:
          s == null ? const Center(child: CircularProgressIndicator()) : _body(s),
    );
  }

  Widget _body(LeagueStateRow s) {
    final division = Division.values
        .firstWhere((d) => d.name == s.division, orElse: () => Division.bronze);
    final cohort = generateCohort(weekId: s.weekId, division: division);
    final board = buildLeaderboard(bots: cohort, userXp: s.weeklyXp);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('División: ${_divisionLabels[s.division] ?? s.division}',
                  style: Theme.of(context).textTheme.titleLarge),
              Text('🔥 Racha: ${s.streakCurrent} días (récord ${s.streakRecord})'),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: board.length,
            itemBuilder: (context, i) {
              final e = board[i];
              final zone = zoneFor(
                  rank: e.rank, cohortSize: board.length, division: division);
              final color = zone == LeagueZone.promote
                  ? Colors.green
                  : zone == LeagueZone.relegate
                      ? Colors.red
                      : null;
              return ListTile(
                leading: CircleAvatar(child: Text('${e.rank}')),
                title: Text(e.name,
                    style: TextStyle(
                        fontWeight:
                            e.isUser ? FontWeight.bold : FontWeight.normal)),
                trailing: Text('${e.xp} XP', style: TextStyle(color: color)),
                tileColor: e.isUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
