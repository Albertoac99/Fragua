import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/media/exercise_media.dart';

class ExerciseDemo extends ConsumerWidget {
  const ExerciseDemo({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(exerciseMediaProvider(exerciseId));
    return SizedBox(
      height: 180,
      child: media.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (m) {
          switch (m.kind) {
            case MediaKind.gif:
              return Image.file(m.files.first,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _instructions(context, m));
            case MediaKind.frames:
              return _FrameAnimation(frames: m.files);
            case MediaKind.text:
              return _instructions(context, m);
          }
        },
      ),
    );
  }

  Widget _instructions(BuildContext context, ResolvedMedia m) {
    if (m.instructions.isEmpty) {
      return const Center(child: Icon(Icons.fitness_center, size: 48));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final s in m.instructions) Text('• $s')],
      ),
    );
  }
}

/// Anima alternando 2 (o más) fotogramas estáticos start/finish.
class _FrameAnimation extends StatefulWidget {
  const _FrameAnimation({required this.frames});
  final List<File> frames;

  @override
  State<_FrameAnimation> createState() => _FrameAnimationState();
}

class _FrameAnimationState extends State<_FrameAnimation> {
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.frames.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
        setState(() => _i = (_i + 1) % widget.frames.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Image.file(
        widget.frames[_i],
        key: ValueKey(_i),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Icons.fitness_center, size: 48)),
      ),
    );
  }
}
