import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/coach/coach.dart';
import '../../core/models/enums.dart';
import '../../core/models/user_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  Sex _sex = Sex.male;
  Goal _goal = Goal.hypertrophy;
  ExperienceLevel _level = ExperienceLevel.beginner;
  final DateTime _birth = DateTime(2000, 1, 1);
  double _height = 175;
  double _weight = 75;
  int _days = 4;
  int _minutes = 60;
  final Set<Equipment> _equipment = {Equipment.bodyweight};

  Future<void> _save() async {
    final profile = UserProfile(
      sex: _sex,
      birthDate: _birth,
      heightCm: _height,
      weightKg: _weight,
      goal: _goal,
      level: _level,
      daysPerWeek: _days,
      sessionMinutes: _minutes,
      equipment: _equipment.isEmpty ? {Equipment.bodyweight} : _equipment,
    );
    final db = ref.read(databaseProvider);
    await db.saveProfile(profile);
    final catalog = await db.loadExercises();
    await db.savePlan(const Coach().generate(profile, catalog));
    ref.invalidate(profileProvider);
    ref.invalidate(planProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuéntanos sobre ti')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _dropdown<Sex>(
              'Género', _sex, Sex.values, (v) => setState(() => _sex = v)),
          _dropdown<Goal>(
              'Objetivo', _goal, Goal.values, (v) => setState(() => _goal = v)),
          _dropdown<ExperienceLevel>('Nivel', _level, ExperienceLevel.values,
              (v) => setState(() => _level = v)),
          _slider('Altura (cm)', _height, 120, 220,
              (v) => setState(() => _height = v)),
          _slider(
              'Peso (kg)', _weight, 35, 200, (v) => setState(() => _weight = v)),
          _slider('Días/semana', _days.toDouble(), 1, 7,
              (v) => setState(() => _days = v.round())),
          _slider('Minutos/sesión', _minutes.toDouble(), 15, 120,
              (v) => setState(() => _minutes = v.round())),
          const SizedBox(height: 8),
          const Text('Equipo disponible'),
          Wrap(
            spacing: 8,
            children: Equipment.values.map((e) {
              final sel = _equipment.contains(e);
              return FilterChip(
                label: Text(e.name),
                selected: sel,
                onSelected: (s) =>
                    setState(() => s ? _equipment.add(e) : _equipment.remove(e)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            key: const Key('onboarding-save'),
            onPressed: _save,
            child: const Text('Empezar'),
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T extends Enum>(
      String label, T value, List<T> values, ValueChanged<T> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: values
            .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
            .toList(),
        onChanged: (v) => onChanged(v as T),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.round()}'),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }
}
