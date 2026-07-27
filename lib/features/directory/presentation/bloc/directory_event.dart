part of 'directory_bloc.dart';

sealed class DirectoryEvent {
  const DirectoryEvent();
}

class DirectoryStarted extends DirectoryEvent {
  const DirectoryStarted();
}

class DirectorySearchChanged extends DirectoryEvent {
  final String query;

  const DirectorySearchChanged(this.query);
}

class DirectoryFilterApplied extends DirectoryEvent {
  final DirectoryFilter filter;

  const DirectoryFilterApplied(this.filter);
}

class DirectoryFiltersCleared extends DirectoryEvent {
  const DirectoryFiltersCleared();
}

class DirectoryNodeToggled extends DirectoryEvent {
  final String nodeId;

  const DirectoryNodeToggled(this.nodeId);
}

class DirectoryNodeSelected extends DirectoryEvent {
  final String? nodeId;

  const DirectoryNodeSelected(this.nodeId);
}

class DirectoryViewModeChanged extends DirectoryEvent {
  final DirectoryViewMode mode;

  const DirectoryViewModeChanged(this.mode);
}

class DirectoryBranchExpandedAll extends DirectoryEvent {
  const DirectoryBranchExpandedAll();
}

class DirectoryBranchCollapsedAll extends DirectoryEvent {
  const DirectoryBranchCollapsedAll();
}

/// Asks the chart canvas to centre on a node (search hit, carousel swipe).
class DirectoryFocusRequested extends DirectoryEvent {
  final String nodeId;

  const DirectoryFocusRequested(this.nodeId);
}

class DirectoryFocusHandled extends DirectoryEvent {
  const DirectoryFocusHandled();
}
