import 'package:flutter/material.dart';
import '../data/phone_country_codes.dart';
import '../theme/app_colors.dart';

/// Phone number field with a tappable country-dial-code selector on the
/// left (opens a searchable picker) and the local number field on the right.
class PhoneCountryCodeField extends StatelessWidget {
  const PhoneCountryCodeField({
    super.key,
    required this.dialCode,
    required this.onDialCodeChanged,
    required this.numberController,
  });

  final String dialCode;
  final ValueChanged<String> onDialCodeChanged;
  final TextEditingController numberController;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => const _CodePickerSheet(),
    );
    if (selected != null) {
      onDialCodeChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dialCode, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Phone number (optional)',
                labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.backgroundElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodePickerSheet extends StatefulWidget {
  const _CodePickerSheet();

  @override
  State<_CodePickerSheet> createState() => _CodePickerSheetState();
}

class _CodePickerSheetState extends State<_CodePickerSheet> {
  final _searchController = TextEditingController();
  List<PhoneCountryCode> _filtered = phoneCountryCodes;

  void _onSearchChanged(String query) {
    setState(() {
      final q = query.toLowerCase();
      _filtered = phoneCountryCodes
          .where((c) => c.country.toLowerCase().contains(q) || c.dialCode.contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hairlineStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search country or code',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                filled: true,
                fillColor: AppColors.backgroundElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(item.dialCode),
                    title: Text(
                      item.country,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                    trailing: Text(
                      item.dialCode,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
