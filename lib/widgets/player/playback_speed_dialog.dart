import 'package:flutter/material.dart';

/// Taken from: https://github.com/fluttercommunity/chewie/blob/master/lib/src/material/widgets/playback_speed_dialog.dart
/// The chewie project is licensed unter the MIT license.
/// All credit goes to the authors.
class PlaybackSpeedDialog extends StatelessWidget {
  const PlaybackSpeedDialog({
    Key? key,
    required List<double> speeds,
    required double selected,
  })  : _speeds = speeds,
        _selected = selected,
        super(key: key);

  final List<double> _speeds;
  final double _selected;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).primaryColor;

    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final speed = _speeds[index];
        return ListTile(
          dense: true,
          title: Row(
            children: [
              if (speed == _selected)
                Icon(
                  Icons.check,
                  size: 20.0,
                  color: selectedColor,
                )
              else
                Container(width: 20.0),
              const SizedBox(width: 16.0),
              Text(speed.toString()),
            ],
          ),
          selected: speed == _selected,
          onTap: () {
            Navigator.of(context).pop(speed);
          },
        );
      },
      itemCount: _speeds.length,
    );
  }
}
