import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/patients.dart';

part 'patient_dao.g.dart';

@DriftAccessor(tables: [Patients])
class PatientDao extends DatabaseAccessor<AppDatabase> with _$PatientDaoMixin {
  PatientDao(super.db);

  /// Inserts a new patient and returns the auto-incremented primary key.
  Future<int> insertPatient(PatientsCompanion patient) =>
      into(patients).insert(patient);

  /// Retrieves a patient by integer primary key ID.
  Future<PatientData?> getPatientById(int id) =>
      (select(patients)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Retrieves all patients sorted by newest first.
  Future<List<PatientData>> getAllPatients() =>
      (select(patients)..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();

  /// Searches for an existing patient with matching phone number (ignoring spaces/dashes/country code).
  /// Returns the patient only if exactly ONE unambiguous match is found; returns null if 0 or >1 patients match.
  Future<PatientData?> findPatientByPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '').trim();
    if (cleanPhone.isEmpty) return null;

    final all = await (select(patients)..orderBy([(tbl) => OrderingTerm.asc(tbl.id)])).get();
    final matchingPatients = <PatientData>[];

    for (final p in all) {
      if (p.phone != null) {
        final candidateClean = p.phone!.replaceAll(RegExp(r'[\s\-\(\)\+]'), '').trim();
        if (candidateClean == cleanPhone ||
            (cleanPhone.length >= 10 && candidateClean.endsWith(cleanPhone.substring(cleanPhone.length - 10))) ||
            (candidateClean.length >= 10 && cleanPhone.endsWith(candidateClean.substring(candidateClean.length - 10)))) {
          matchingPatients.add(p);
        }
      }
    }

    if (matchingPatients.length == 1) {
      return matchingPatients.first;
    }
    return null;
  }

  /// Searches for an existing patient matching deterministic demographic criteria
  /// (normalized name + age + gender + optional location).
  /// Returns the patient only if exactly ONE unambiguous match is found; returns null if 0 or >1 patients match.
  Future<PatientData?> findPatientByDemographics({
    required String name,
    required int age,
    required String gender,
    String? location,
  }) async {
    final cleanName = name.trim().toLowerCase();
    final cleanGender = gender.trim().toLowerCase();
    final cleanLoc = location?.trim().toLowerCase();

    if (cleanName.isEmpty) return null;

    final all = await (select(patients)..orderBy([(tbl) => OrderingTerm.asc(tbl.id)])).get();
    final matchingCandidates = <PatientData>[];

    for (final p in all) {
      final pName = p.name.trim().toLowerCase();
      final pGender = p.gender.trim().toLowerCase();
      final pLoc = p.location?.trim().toLowerCase();

      final matchesName = pName == cleanName;
      final matchesAge = p.age == age;
      final matchesGender = pGender == cleanGender ||
          (pGender.isNotEmpty && cleanGender.isNotEmpty && (pGender[0] == cleanGender[0]));

      if (matchesName && matchesAge && matchesGender) {
        if (cleanLoc != null && cleanLoc.isNotEmpty) {
          if (pLoc != null && pLoc.isNotEmpty && pLoc == cleanLoc) {
            matchingCandidates.add(p);
          }
        } else {
          matchingCandidates.add(p);
        }
      }
    }

    if (matchingCandidates.length == 1) {
      return matchingCandidates.first;
    }
    return null;
  }


  /// Updates an existing patient record.
  Future<bool> updatePatient(PatientsCompanion patient) =>
      update(patients).replace(patient);

  /// Deletes a patient by ID.
  Future<int> deletePatient(int id) =>
      (delete(patients)..where((tbl) => tbl.id.equals(id))).go();
}
