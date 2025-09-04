import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simple_locale.dart';
import '../services/translations.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

Future<void> showLanguagePicker(BuildContext context) async {
  final langs = supportedLanguages();
  final localeProvider = context.read<SimpleLocale>();

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Row(
        children: [
          const Icon(Icons.language, color: AppColors.primaryGreen),
          const SizedBox(width: AppSpacing.md),
          Text(t(ctx, 'select_language'), style: AppTextStyles.heading3),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final l in langs)
            Builder(
              builder: (context) {
                final currentCode = context.read<SimpleLocale>().code;
                final isSelected = l['code'] == currentCode;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? AppColors.surfaceLight
                        : Colors.transparent,
                  ),
                  child: ListTile(
                    leading:
                        Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(l['name']!, style: AppTextStyles.bodyLarge),
                    onTap: () async {
                      // Close dialog first to prevent UI issues
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }

                      // Change language after dialog is closed
                      if (l['code'] != currentCode) {
                        await localeProvider.setCode(l['code']!);
                      }
                    },
                  ),
                );
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t(ctx, 'cancel')),
        ),
      ],
    ),
  );
}
