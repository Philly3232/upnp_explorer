import 'package:flutter/material.dart';

import '../../../application/l10n/generated/l10n.dart';

class ScanningIndicator extends StatefulWidget {
  final double height;

  const ScanningIndicator({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  State<ScanningIndicator> createState() => _ScanningIndicatorState();
}

class _ScanningIndicatorState extends State<ScanningIndicator> {
  bool _visible = true;

  void _setVisible(bool visible) {
    setState(() {
      _visible = visible;
    });
  }

  @override
  void didUpdateWidget(covariant ScanningIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(!_visible && widget.height > 0 && widget.height != oldWidget.height) {
      _setVisible(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: S.of(context).scanningForDevices,
      child: Visibility(
        visible: _visible,
        child: AnimatedContainer(
          onEnd: () => _setVisible(false),
          height: widget.height,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 150),
          child: LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
