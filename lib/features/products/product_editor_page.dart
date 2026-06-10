import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/content_area.dart';
import 'product_editor_cubit.dart';

class ProductEditorPage extends StatefulWidget {
  const ProductEditorPage({super.key});

  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  final _name = TextEditingController();
  final _tagline = TextEditingController();
  final _description = TextEditingController();
  final _category = TextEditingController(text: 'Payments');
  final _version = TextEditingController(text: 'v1.0');
  final _basePath = TextEditingController(text: '/example/v1');
  final _tier = TextEditingController(text: 'Standard');
  final _quota = TextEditingController(text: '100000');
  ProductVisibility _visibility = ProductVisibility.public;

  bool _initialized = false;
  bool _nameError = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _tagline,
      _description,
      _category,
      _version,
      _basePath,
      _tier,
      _quota,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(ApiProduct p) {
    _name.text = p.name;
    _tagline.text = p.tagline;
    _description.text = p.description;
    _category.text = p.category;
    _version.text = p.version;
    _basePath.text = p.basePath;
    _tier.text = p.tierName;
    _quota.text = p.quotaLimit.toString();
    _visibility = p.visibility;
  }

  void _save(EditorState state) {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    final quota = int.tryParse(_quota.text.trim().replaceAll(',', '')) ?? 0;
    final existing = state.existing;
    final draft = existing != null
        ? existing.copyWith(
            name: _name.text.trim(),
            tagline: _tagline.text.trim(),
            description: _description.text.trim(),
            category: _category.text.trim(),
            version: _version.text.trim(),
            visibility: _visibility,
            basePath: _basePath.text.trim(),
            tierName: _tier.text.trim(),
            quotaLimit: quota,
          )
        : ApiProduct(
            id: '',
            name: _name.text.trim(),
            tagline: _tagline.text.trim(),
            description: _description.text.trim(),
            category: _category.text.trim(),
            version: _version.text.trim(),
            colorIndex: _name.text.trim().length % 6,
            visibility: _visibility,
            featured: false,
            specUrl: '',
            basePath: _basePath.text.trim(),
            endpoints: const [],
            docsMarkdown: '## ${_name.text.trim()}\n${_description.text.trim()}',
            tierName: _tier.text.trim(),
            quotaLimit: quota,
            quotaInterval: 'month',
            sampleResponse: '{}',
          );
    context.read<ProductEditorCubit>().save(draft);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductEditorCubit, EditorState>(
      listener: (context, state) {
        if (state.status == EditorStatus.ready &&
            state.existing != null &&
            !_initialized) {
          _hydrate(state.existing!);
          _initialized = true;
        }
        if (state.status == EditorStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceRaised,
              content: Text(state.isEditing
                  ? 'Product updated'
                  : 'Product created'),
            ),
          );
          context.go('/products');
        }
      },
      builder: (context, state) {
        if (state.status == EditorStatus.loading) {
          return const SizedBox(
              height: 600, child: Center(child: CircularProgressIndicator()));
        }
        final saving = state.status == EditorStatus.saving;
        return ContentArea(
          maxWidth: 880,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => context.go('/products'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Products'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMid,
                    padding: EdgeInsets.zero),
              ),
              const SizedBox(height: 14),
              Text(state.isEditing ? 'Edit product' : 'New product',
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                state.isEditing
                    ? 'Update this API product. Changes reflect in the catalog immediately.'
                    : 'Define a new API product. It appears in the catalog as soon as you save.',
                style: const TextStyle(color: AppColors.textLo, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _field('Name', _name,
                  hint: 'e.g. Payment Initiation API',
                  error: _nameError ? 'Name is required' : null,
                  onChanged: () {
                if (_nameError) setState(() => _nameError = false);
              }),
              _field('Tagline', _tagline, hint: 'One-line summary'),
              _field('Description', _description,
                  hint: 'What the product does', maxLines: 3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _field('Category', _category)),
                  const SizedBox(width: 16),
                  Expanded(child: _field('Version', _version)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _visibilityField()),
                  const SizedBox(width: 16),
                  Expanded(child: _field('Tier', _tier)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _field('Base path', _basePath)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _field('Quota / month', _quota,
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  FilledButton(
                    onPressed: saving ? null : () => _save(state),
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(state.isEditing ? 'Save changes' : 'Create product'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/products'),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    String? error,
    TextInputType? keyboardType,
    VoidCallback? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textHi,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged == null ? null : (_) => onChanged(),
            decoration: InputDecoration(hintText: hint, errorText: error),
          ),
        ],
      ),
    );
  }

  Widget _visibilityField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Visibility',
              style: TextStyle(
                  color: AppColors.textHi,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<ProductVisibility>(
            initialValue: _visibility,
            isExpanded: true,
            dropdownColor: AppColors.surfaceRaised,
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(
                  value: ProductVisibility.public, child: Text('Public')),
              DropdownMenuItem(
                  value: ProductVisibility.partner,
                  child: Text('Partner (needs approval)')),
              DropdownMenuItem(
                  value: ProductVisibility.internal, child: Text('Internal')),
            ],
            onChanged: (v) =>
                setState(() => _visibility = v ?? ProductVisibility.public),
          ),
        ],
      ),
    );
  }
}
