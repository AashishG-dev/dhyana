// lib/widgets/common/tts_controls.dart
import 'package:dhyana/providers/tts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TtsControls extends ConsumerWidget {
  const TtsControls({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsPlayerState = ref.watch(ttsProvider);
    final ttsNotifier = ref.read(ttsProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Playback Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const Divider(),
            _buildSlider(
              context: context,
              label: 'Speed',
              value: ttsPlayerState.rate,
              onChanged: (value) => ttsNotifier.setRate(value),
              min: 0.0,
              max: 1.0,
            ),
            _buildSlider(
              context: context,
              label: 'Pitch',
              value: ttsPlayerState.pitch,
              onChanged: (value) => ttsNotifier.setPitch(value),
              min: 0.5,
              max: 2.0,
            ),
            _buildSlider(
              context: context,
              label: 'Volume',
              value: ttsPlayerState.volume,
              onChanged: (value) => ttsNotifier.setVolume(value),
              min: 0.0,
              max: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
  }) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}