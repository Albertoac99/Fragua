import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/models/plan.dart';
import '../../core/session/guided_session.dart';
import 'guided_session_controller.dart';

class GuidedSessionScreen extends ConsumerStatefulWidget {
  const GuidedSessionScreen({super.key, required this.day});
  final PlanDay day;

  @override
  ConsumerState<GuidedSessionScreen> createState() =>
      _GuidedSessionScreenState();
}

class _GuidedSessionScreenState extends ConsumerState<GuidedSessionScreen> {
  GuidedSessionController? _c;
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = ref.read(databaseProvider);
    final voice = ref.read(voiceProvider);
    final gs = await db.guidedState(widget.day.name);
    final defaultWork = widget.day.exercises.isNotEmpty
        ? (widget.day.exercises.first.workSeconds ?? 40)
        : 40;
    final work = gs?.workSeconds ?? defaultWork;
    final rounds = gs?.rounds ?? widget.day.rounds;
    final timeline = buildGuidedTimeline(
      widget.day,
      workSecondsOverride: work,
      roundsOverride: rounds,
    );
    if (!mounted) return;
    final c = GuidedSessionController(
      db: db,
      voice: voice,
      day: widget.day,
      timeline: timeline,
      initialWorkSeconds: work,
      initialRounds: rounds,
    );
    c.addListener(_onState);
    setState(() => _c = c);
    c.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => c.tick());
  }

  void _onState() {
    if (_c != null && _c!.state.finished && !_leaving) {
      _leaving = true;
      _timer?.cancel();
      _finishAndLeave();
    }
  }

  Future<void> _finishAndLeave() async {
    await _c!.finish();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _finishEarly() async {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    await _finishAndLeave();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c?.removeListener(_onState);
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _c;
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.day.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.day.name)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final st = controller.state;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: st.isAmrap
                ? _amrapBody(controller, st)
                : _timelineBody(controller, st),
          );
        },
      ),
    );
  }

  Widget _timelineBody(GuidedSessionController c, GuidedSessionState st) {
    final step = st.currentStep;
    final next = st.nextStep;
    final isRest = step?.kind == StepKind.rest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (step != null)
          Text('Ronda ${step.round} de ${step.totalRounds}',
              style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(isRest ? 'Descanso' : (step?.label ?? ''),
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('${st.remainingSeconds}',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: st.progress),
        const SizedBox(height: 16),
        if (next != null)
          Text('Siguiente: ${next.kind == StepKind.rest ? 'Descanso' : next.label}'),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: st.running ? c.pause : c.start,
              child: Text(st.running ? 'Pausa' : 'Reanudar'),
            ),
            FilledButton(
              key: const Key('finish-guided'),
              onPressed: _finishEarly,
              child: const Text('Terminar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _amrapBody(GuidedSessionController c, GuidedSessionState st) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('AMRAP', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('${st.remainingSeconds}',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: st.progress),
        const SizedBox(height: 16),
        Text('Rondas: ${st.completedRounds}',
            style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        FilledButton(
          key: const Key('amrap-round'),
          onPressed: c.addRound,
          child: const Text('+1 ronda'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('finish-guided'),
          onPressed: _finishEarly,
          child: const Text('Terminar'),
        ),
      ],
    );
  }
}
