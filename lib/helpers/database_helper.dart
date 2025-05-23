import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/visit.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'octaklinik.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS visits');
        await db.execute('DROP TABLE IF EXISTS patients');
        await _onCreate(db, newVersion);
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients(
        id TEXT PRIMARY KEY,
        fullName TEXT,
        dateOfBirth TEXT,
        gender TEXT,
        phoneNumber TEXT,
        address TEXT,
        medicalHistory TEXT,
        createdAt TEXT,
        userId TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE visits(
        id TEXT PRIMARY KEY,
        patientId TEXT,
        chiefComplaint TEXT,
        diagnosis TEXT,
        doctorNotes TEXT,
        visitDate TEXT,
        userId TEXT,
        FOREIGN KEY(patientId) REFERENCES patients(id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD untuk Patient
  Future<void> insertPatient(Patient patient) async {
    final db = await database;
    await db.insert('patients', patient.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Patient>> getPatients(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('patients', where: 'userId = ?', whereArgs: [userId]);
    return List.generate(maps.length, (i) {
      return Patient.fromJson(maps[i]);
    });
  }

  Future<void> updatePatient(Patient patient) async {
    final db = await database;
    await db.update('patients', patient.toJson(),
        where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<void> deletePatient(String id) async {
    final db = await database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Visit
  Future<void> insertVisit(Visit visit, String patientId) async {
    final db = await database;
    final data = visit.toJson();
    data['patientId'] = patientId;
    await db.insert('visits', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Visit>> getVisits(String patientId, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('visits',
        where: 'patientId = ? AND userId = ?', whereArgs: [patientId, userId]);
    return List.generate(maps.length, (i) {
      return Visit.fromJson(maps[i]);
    });
  }

  Future<void> updateVisit(Visit visit) async {
    final db = await database;
    await db.update('visits', visit.toJson(),
        where: 'id = ?', whereArgs: [visit.id]);
  }

  Future<void> deleteVisit(String id) async {
    final db = await database;
    await db.delete('visits', where: 'id = ?', whereArgs: [id]);
  }

  // Ambil pasien berdasarkan rentang tanggal createdAt
  Future<List<Patient>> getPatientsByDateRange(
      DateTime start, DateTime end, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'createdAt >= ? AND createdAt <= ? AND userId = ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String(), userId],
    );
    return List.generate(maps.length, (i) {
      return Patient.fromJson(maps[i]);
    });
  }

  // Ambil visit berdasarkan rentang tanggal visitDate
  Future<List<Visit>> getVisitsByDateRange(
      DateTime start, DateTime end, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'visits',
      where: 'visitDate >= ? AND visitDate <= ? AND userId = ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String(), userId],
    );
    return List.generate(maps.length, (i) {
      return Visit.fromJson(maps[i]);
    });
  }

  // Ambil semua pasien untuk user tertentu
  Future<List<Patient>> getAllPatients(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('patients', where: 'userId = ?', whereArgs: [userId]);
    return List.generate(maps.length, (i) {
      return Patient.fromJson(maps[i]);
    });
  }

  // Ambil tanggal last visit untuk pasien tertentu
  Future<DateTime> getLastVisitDate(
      String patientId, DateTime createdAt) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'visits',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'visitDate DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return DateTime.parse(maps.first['visitDate']);
    } else {
      return createdAt;
    }
  }
}
