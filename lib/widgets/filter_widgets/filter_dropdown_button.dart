// widgets/filter_dropdown_button.dart

import 'package:flutter/material.dart';

class FilterDropdownButton extends StatefulWidget {
  final String label;
  final String? selectedValue;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterDropdownButton({
    super.key,
    required this.label,
    required this.onTap,
    this.selectedValue,
    this.isSelected = false,
  });

  @override
  State<FilterDropdownButton> createState() => _FilterDropdownButtonState();
}

class _FilterDropdownButtonState extends State<FilterDropdownButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool active = widget.isSelected || _isPressed || _isHovered;
    final backgroundColor = active ? primaryColor.withOpacity(1) : cs.onSurface;
    final displayLabel = widget.isSelected
        ? (widget.selectedValue ?? widget.label)
        : widget.label;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (v) => setState(() => _isHovered = v),
          onHighlightChanged: (v) => setState(() => _isPressed = v),
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Flexible(
                  child: Text(
                    displayLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Spacer(),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
