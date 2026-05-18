import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lecture.dart';
import '../models/page_data.dart';
import '../models/canvas_element.dart';
import '../core/constants/app_constants.dart';

class LectureState {
  final Lecture? lecture;
  final int currentPageIndex;
  final List<PageData> deletedPages;

  const LectureState({
    this.lecture,
    this.currentPageIndex = 0,
    this.deletedPages = const [],
  });

  PageData? get currentPage {
    if (lecture == null || lecture!.pages.isEmpty) return null;
    if (currentPageIndex >= lecture!.pages.length) return null;
    return lecture!.pages[currentPageIndex];
  }

  LectureState copyWith({
    Lecture? Function()? lecture,
    int? currentPageIndex,
    List<PageData>? deletedPages,
  }) {
    return LectureState(
      lecture: lecture != null ? lecture() : this.lecture,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      deletedPages: deletedPages ?? this.deletedPages,
    );
  }
}

class LectureNotifier extends StateNotifier<LectureState> {
  LectureNotifier() : super(const LectureState());

  void createNewLecture({
    String title = 'Untitled Lecture',
    double width = AppConstants.defaultPageWidth,
    double height = AppConstants.defaultPageHeight,
  }) {
    final lecture = Lecture(
      title: title,
      pageWidth: width,
      pageHeight: height,
    );
    state = LectureState(lecture: lecture, currentPageIndex: 0);
  }

  void loadLecture(Lecture lecture) {
    state = LectureState(lecture: lecture, currentPageIndex: 0);
  }

  void setCurrentPage(int index) {
    if (state.lecture == null) return;
    if (index < 0 || index >= state.lecture!.pages.length) return;
    state = state.copyWith(currentPageIndex: index);
  }

  void addPage() {
    if (state.lecture == null) return;
    final newPage = PageData(order: state.lecture!.pages.length);
    final pages = [...state.lecture!.pages, newPage];
    state = state.copyWith(
      lecture: () => state.lecture!.copyWith(pages: pages),
      currentPageIndex: pages.length - 1,
    );
  }

  void deletePage(int index) {
    if (state.lecture == null) return;
    if (state.lecture!.pages.length <= 1) return; // Keep at least one page

    final deleted = state.lecture!.pages[index];
    final pages = [...state.lecture!.pages]..removeAt(index);
    final newIndex = index >= pages.length ? pages.length - 1 : index;

    state = state.copyWith(
      lecture: () => state.lecture!.copyWith(pages: pages),
      currentPageIndex: newIndex,
      deletedPages: [...state.deletedPages, deleted],
    );
  }

  void restoreDeletedPage() {
    if (state.lecture == null || state.deletedPages.isEmpty) return;
    final restored = state.deletedPages.last;
    final pages = [...state.lecture!.pages, restored.copyWith(order: state.lecture!.pages.length)];
    final newDeleted = state.deletedPages.sublist(0, state.deletedPages.length - 1);

    state = state.copyWith(
      lecture: () => state.lecture!.copyWith(pages: pages),
      deletedPages: newDeleted,
      currentPageIndex: pages.length - 1,
    );
  }

  /// Replace the current page in place (e.g. background change) without
  /// resetting the page index or the deleted-pages history.
  void updateCurrentPage(PageData page) {
    if (state.lecture == null) return;
    final idx = state.currentPageIndex;
    if (idx < 0 || idx >= state.lecture!.pages.length) return;
    final pages = [...state.lecture!.pages];
    pages[idx] = page;
    state = state.copyWith(
      lecture: () => state.lecture!.copyWith(pages: pages),
    );
  }

  void updateCurrentPageElements(List<CanvasElement> elements) {
    if (state.lecture == null || state.currentPage == null) return;
    final pages = [...state.lecture!.pages];
    pages[state.currentPageIndex] =
        state.currentPage!.copyWith(elements: elements);
    state = state.copyWith(
      lecture: () => state.lecture!.copyWith(pages: pages),
    );
  }

  void reorderPages(int oldIndex, int newIndex) {
    if (state.lecture == null) return;
    final pages = [...state.lecture!.pages];
    final page = pages.removeAt(oldIndex);
    pages.insert(newIndex, page);
    state = state.copyWith(
      lecture: () => state.lecture!.copyWith(pages: pages),
      currentPageIndex: newIndex,
    );
  }

  void closeLecture() {
    state = const LectureState();
  }
}

final lectureProvider =
    StateNotifierProvider<LectureNotifier, LectureState>((ref) {
  return LectureNotifier();
});
