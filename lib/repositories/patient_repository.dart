import '../models/patient.dart';
import '../services/local_storage/local_storage_service.dart';
import '../services/api/api_service.dart';
import '../services/connectivity/connectivity_service.dart';

/// Repository responsible for patient data access and persistence.
class PatientRepository {
  final LocalStorageService localStorage;
  final ApiService apiService;
  final ConnectivityService connectivityService;

  PatientRepository({
    required this.localStorage,
    required this.apiService,
    required this.connectivityService,
  });

  /// Saves or creates a patient in the local database first.
  Future<void> savePatient(Patient patient) async {
    // 1. Save locally
    await localStorage.savePatient(patient);

    // 2. If online, sync to backend
    final isOnline = await connectivityService.checkConnectivity();
    if (isOnline) {
      try {
        await apiService.requestIdentityMatches(patient);
      } catch (_) {}
    }
  }

  /// Retrieves a patient by ID from local cache or API.
  Future<Patient?> getPatientById(String id) async {
    final localPatient = await localStorage.getDomainPatientById(id);
    if (localPatient != null) return localPatient;

    return null;
  }

  /// Retrieves all local patients.
  Future<List<Patient>> getAllPatients() async {
    return await localStorage.getAllDomainPatients();
  }
}
