import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Generic text field with type-ahead suggestions drawn from [options] —
/// narrows the dropdown as the user types instead of requiring a scroll
/// through a long list. Used for both country and occupation pickers.
class AutocompleteTextField extends StatefulWidget {
  const AutocompleteTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.options,
  });

  final String label;
  final TextEditingController controller;
  final List<String> options;

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  InputDecoration _decoration() {
    return InputDecoration(
      labelText: widget.label,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.backgroundElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          textEditingController: widget.controller,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) return const Iterable<String>.empty();
            final query = value.text.toLowerCase();
            return widget.options.where((o) => o.toLowerCase().contains(query)).take(8);
          },
          fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: _decoration(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: constraints.maxWidth,
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCardHover,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.hairlineStrong),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: Text(
                            option,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
