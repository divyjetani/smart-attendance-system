import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subject.dart';
import '../../domain/usecases/fetch_subjects_usecase.dart';

class SubjectState {
  final bool isLoading;
  final List<SubjectEntity> subjects;
  final String? error;

  SubjectState({
    required this.isLoading,
    required this.subjects,
    this.error,
  });

  factory SubjectState.initial() => SubjectState(isLoading: false, subjects: []);
  factory SubjectState.loading() => SubjectState(isLoading: true, subjects: []);
  factory SubjectState.success(List<SubjectEntity> list) => SubjectState(isLoading: false, subjects: list);
  factory SubjectState.error(String error) => SubjectState(isLoading: false, subjects: [], error: error);
}

class SubjectNotifier extends StateNotifier<SubjectState> {
  final FetchSubjectsBySemesterUseCase _semesterUseCase;
  final FetchSubjectsByProfessorUseCase _professorUseCase;

  SubjectNotifier(this._semesterUseCase, this._professorUseCase) : super(SubjectState.initial());

  Future<void> fetchSubjectsBySemester(int semester, String studentId) async {
    state = SubjectState.loading();
    try {
      final list = await _semesterUseCase(semester, studentId);
      state = SubjectState.success(list);
    } catch (e) {
      state = SubjectState.error(e.toString());
    }
  }

  Future<void> fetchSubjectsByProfessor(String professorId) async {
    state = SubjectState.loading();
    try {
      final list = await _professorUseCase(professorId);
      state = SubjectState.success(list);
    } catch (e) {
      state = SubjectState.error(e.toString());
    }
  }
}

final subjectProvider = StateNotifierProvider<SubjectNotifier, SubjectState>((ref) {
  final semesterUseCase = ref.watch(fetchSubjectsBySemesterUseCaseProvider);
  final professorUseCase = ref.watch(fetchSubjectsByProfessorUseCaseProvider);
  return SubjectNotifier(semesterUseCase, professorUseCase);
});