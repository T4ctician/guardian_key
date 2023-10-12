import 'package:flutter/material.dart';
import 'package:guardian_key/src/constants/colors.dart';

class ToggleMenuWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  ToggleMenuWidget({
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _ToggleMenuWidgetState createState() => _ToggleMenuWidgetState();
}

class _ToggleMenuWidgetState extends State<ToggleMenuWidget> {
  late bool _currentValue;  // Add 'late' keyword

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: tAccentColor.withOpacity(0.1),
        ),
        child: Icon(widget.icon, color: tAccentColor),
      ),
      title: Text(widget.title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Switch(
        value: _currentValue,
        onChanged: (value) {
          setState(() {
            _currentValue = value;
          });
          widget.onChanged(value);
        },
        inactiveThumbColor: Colors.white,
        activeColor: Colors.green,
      ),
    );
  }
}

