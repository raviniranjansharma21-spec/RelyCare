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

  /// Updates an existing patient record.
  Future<bool> updatePatient(PatientsCompanion patient) =>
      update(patients).replace(patient);

  /// Deletes a patient by ID.
  Future<int> deletePatient(int id) =>
      (delete(patients)..where((tbl) => tbl.id.equals(id))).go();
}
