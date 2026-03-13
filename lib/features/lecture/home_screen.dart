import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lecture_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HomeCard(
              icon: Icons.note_add,
              iconColor: AppColors.primary,
              title: 'New Lecture',
              subtitle: 'Open a blank page\nand start a lecture',
              onTap: () => _showNewLectureDialog(context, ref),
            ),
            const SizedBox(width: 32),
            _HomeCard(
              icon: Icons.folder_open,
              iconColor: AppColors.secondary,
              title: 'Lecture File',
              subtitle: 'Open an ICanNote file\n(*.icn) to start',
              onTap: () {
                // TODO: file picker for .icn files
              },
            ),
            const SizedBox(width: 32),
            _HomeCard(
              icon: Icons.description,
              iconColor: const Color(0xFF5BC0DE),
              title: 'Open Textbook',
              subtitle: 'Open documents in\nvarious formats',
              onTap: () {
                // TODO: file picker for PDF/PPT/DOC/HWP
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewLectureDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _NewLectureDialogSimple(ref: ref),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewLectureDialogSimple extends StatefulWidget {
  final WidgetRef ref;
  const _NewLectureDialogSimple({required this.ref});

  @override
  State<_NewLectureDialogSimple> createState() =>
      _NewLectureDialogSimpleState();
}

class _NewLectureDialogSimpleState extends State<_NewLectureDialogSimple> {
  final _widthController = TextEditingController(
    text: AppConstants.defaultPageWidth.toInt().toString(),
  );
  final _heightController = TextEditingController(
    text: AppConstants.defaultPageHeight.toInt().toString(),
  );
  bool _isLandscape = true;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Lecture Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Page Width  '),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Page Height  '),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Orientation  '),
              ChoiceChip(
                label: const Text('Landscape'),
                selected: _isLandscape,
                onSelected: (v) {
                  if (!_isLandscape) {
                    setState(() {
                      _isLandscape = true;
                      final w = _widthController.text;
                      _widthController.text = _heightController.text;
                      _heightController.text = w;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Portrait'),
                selected: !_isLandscape,
                onSelected: (v) {
                  if (_isLandscape) {
                    setState(() {
                      _isLandscape = false;
                      final w = _widthController.text;
                      _widthController.text = _heightController.text;
                      _heightController.text = w;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Page size defaults to A4. When printing, the scale adjusts to fit paper size.',
            style: TextStyle(fontSize: 11, color: Colors.red.shade700),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final w = double.tryParse(_widthController.text) ??
                AppConstants.defaultPageWidth;
            final h = double.tryParse(_heightController.text) ??
                AppConstants.defaultPageHeight;
            widget.ref
                .read(lectureProvider.notifier)
                .createNewLecture(width: w, height: h);
            Navigator.pop(context);
            context.go('/editor');
          },
          child: const Text('Apply'),
        ),
        TextButton(
          onPressed: () {
            widget.ref.read(lectureProvider.notifier).createNewLecture();
            Navigator.pop(context);
            context.go('/editor');
          },
          child: const Text('Use Defaults'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
