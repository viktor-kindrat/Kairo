import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationState {
  final int selectedIndex;

  const NavigationState({required this.selectedIndex});
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(selectedIndex: 0));

  void selectTab(int index) => emit(NavigationState(selectedIndex: index));
}
