import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/providers/citizen_tracking_entry_provider.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/providers/citizen_tracking_provider.dart';

class TrackingModule {
  final AppContainer _appContainer;

  TrackingModule(this._appContainer);

  CitizenTrackingProvider provideCitizenTrackingProvider() {
    return CitizenTrackingProvider(
      socketFactory: _appContainer.trackingSocketClientFactory,
      repository: _appContainer.routesRepository,
    );
  }

  CitizenTrackingEntryProvider provideTrackingEntryProvider() {
    return CitizenTrackingEntryProvider(
      repository: _appContainer.routesRepository,
    );
  }
}
