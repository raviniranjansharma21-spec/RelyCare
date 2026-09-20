import '../models/patient.dart';
import '../services/local_storage/local_storage_service.dart';
import '../services/api/api_service.dart';
import '../services/connectivity/connectivity_service.dart';

/// Repository responsible for patient data access and persistence.
class PatientRepository {
  final LocalStorageService _localStorage;
  final ApiService _apiService;
  final ConnectivityService _connectivityService;

  PatientRepository({
    required this._localStorage,
    required ApiService apiService,
    required this._connectivityService,
  })  : _apiService = apiService;

  /// Saves or creates a patient in the local database first.
  Future<void> savePatient(Patient patient) async {
    // 1. Save locally
    await _localStorage.savePatient(patient);

    // 2. If online, sync to backend
    final isOnline = await _connectivityService.checkConnectivity();
    if (isOnline) {
      // TODO (Backend Specialist): Call _apiService to register patient on FastAPI backend
    }
  }

  /// Retrieves a patient by ID from local cache or API.
  Future<Patient?> getPatientById(String id) async {
    final localPatient = await _localStorage.getPatientById(id);
    if (localPatient != null) return localPatient;

    // TODO: If not found locally and online, fetch from backend
    return null;
  }

  /// Retrieves all local patients.
  Future<List<Patient>> getAllPatients() async {
    return await _localStorage.getAllPatients();
  }
}
