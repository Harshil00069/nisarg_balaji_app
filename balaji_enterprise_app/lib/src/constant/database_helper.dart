import 'package:flutter/foundation.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/location_data_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/location_track_by_company_data_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  static Database? _database;

  factory DatabaseHelper() => _instance;

  // ============================================================
  // DATABASE
  // ============================================================

  static const String _databaseName = 'common_database.db';
  static const int _databaseVersion = 9;

  // ============================================================
  // LOCATION TABLE
  // ============================================================

  static const String table = 'location';

  static const String columnId = '_id';
  static const String columnName = 'name';
  static const String credentialColumUserID = 'userid';
  static const String credentialColumEmpID = 'empid';
  static const String columnLatitude = 'latitude';
  static const String columLongitude = 'longitude';
  static const String columCreatedAt = 'createdAt';
  static const String columBatteryLevel = 'batteryLevel';

  // ============================================================
  // USER TABLE
  // ============================================================

  static const String userTable = 'userDetail';

  static const String columnEmpId = 'loginEmpId';
  static const String columnUserId = 'loginUserId';
  static const String columnCompanyId = 'companyId';
  static const String columnToken = 'token';
  static const String columnBaseURL = 'baseUrl';

  // ============================================================
  // LOCATION TRACKING STATE TABLE
  // ============================================================

  /// This table stores the last location that was processed.
  ///
  /// We use this location to calculate distance before deciding
  /// whether another location/API request is required.
  static const String locationTrackingStateTable = 'locationTrackingState';

  static const String trackingStateId = 'id';
  static const String trackingStateLatitude = 'latitude';
  static const String trackingStateLongitude = 'longitude';
  static const String trackingStateUpdatedAt = 'updatedAt';


  // admin save range
  static const String tableAdminRange = 'admin_range';
  static const String columnRangeId = 'range_id';
  static const String columnLongitude = 'longitude';
  static const String columnCreatedAt = 'created_at';


  //  check user is in range
  static const String tableRangeExitState = 'range_exit_state';

  static const String rangeExitEmployeeId = 'employee_id';
  static const String rangeExitLatitude = 'latitude';
  static const String rangeExitLongitude = 'longitude';
  static const String rangeExitCreatedAt = 'created_at';

  // ============================================================
  // PENDING RANGE EVENTS TABLE
  // ============================================================

  static const String tablePendingRangeEvents = 'pending_range_events';
  static const String pendingEventId = 'id';
  static const String pendingEventEmployeeId = 'employee_id';
  static const String pendingEventRangeId = 'range_id';
  static const String pendingEventLatitude = 'latitude';
  static const String pendingEventLongitude = 'longitude';
  static const String pendingEventIsUserOut = 'is_user_out';
  static const String pendingEventGpsStatus = 'gps_status';
  static const String pendingEventBatteryStatus = 'battery_status';
  static const String pendingEventAddress = 'address';
  static const String pendingEventCreatedAt = 'created_at';

  // ============================================================
  // DATABASE INSTANCE
  // ============================================================

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  // ============================================================
  // INITIALIZE DATABASE
  // ============================================================

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    // final path = join(
    //   dbPath,
    //   _databaseName,
    // );

    final dbFilePath = p.join(
      dbPath,
      _databaseName,
    );

    return openDatabase(
      dbFilePath,
      version: _databaseVersion,

      // --------------------------------------------------------
      // CREATE DATABASE
      // --------------------------------------------------------

      onCreate: (db, version) async {
        await _createAllTables(db);

        if (kDebugMode) {
          debugPrint(
            'Database created successfully. Version: $version',
          );
        }
      },

      // --------------------------------------------------------
      // DATABASE UPGRADE
      // --------------------------------------------------------

      onUpgrade: (db, oldVersion, newVersion) async {
        if (kDebugMode) {
          debugPrint(
            'Database upgrade: $oldVersion -> $newVersion',
          );
        }

        await _createAllTables(db);
      },

      // --------------------------------------------------------
      // DATABASE OPEN
      // --------------------------------------------------------

      onOpen: (db) async {
        await _createAllTables(db);

        if (kDebugMode) {
          debugPrint(
            'Database opened successfully.',
          );
        }
      },
    );
  }

  // ============================================================
  // CREATE ALL TABLES
  // ============================================================

  Future<void> _createAllTables(Database db) async {
    await _createUserDetailTable(db);
    await _createAdminRangeTable(db);
    await _createRangeExitStateTable(db);
    await _createPendingRangeEventsTable(db);
    // await _createLocationTable(db);
    // await _createLocationTrackingStateTable(db);

  }

  // ============================================================
  // CREATE LOCATION TABLE
  // ============================================================

/*  Future<void> _createLocationTable(Database db) async {
    final columns = {
      columnId: 'INTEGER PRIMARY KEY AUTOINCREMENT',
      columnName: 'TEXT NOT NULL',
      columnLatitude: 'TEXT NOT NULL',
      columLongitude: 'TEXT NOT NULL',
      columCreatedAt: 'TEXT NOT NULL',
      columBatteryLevel: 'TEXT NOT NULL',
    };

    await createTableIfNotExists(
      table,
      columns,
      databaseConfig: db,
    );

    if (kDebugMode) {
      debugPrint(
        'Table verified: $table',
      );
    }
  }*/


  Future<void> _createAdminRangeTable(Database db) async {
    final columns = {
      columnId: 'INTEGER PRIMARY KEY AUTOINCREMENT',
      columnRangeId: 'INTEGER NOT NULL',
      columnName: 'TEXT NOT NULL',
      columnLatitude: 'TEXT NOT NULL',
      columnLongitude: 'TEXT NOT NULL',
      columnCreatedAt: 'TEXT NOT NULL',
    };

    await createTableIfNotExists(
      tableAdminRange,
      columns,
      databaseConfig: db,
    );

    if (kDebugMode) {
      debugPrint('Table verified: $tableAdminRange');
    }
  }

// Save Admin lat long range
  Future<void> saveAdminRange({
    required int rangeId,
    required String name,
    required List<LocationDatum> rangePoints,
  }) async {
    try {
      final db = await database;

      await db.transaction((txn) async {
        // Remove old points when updating the same range.
        await txn.delete(
          tableAdminRange,
          where: '$columnRangeId = ?',
          whereArgs: [rangeId],
        );

        // Insert the updated points.
        for (final point in rangePoints) {
          await txn.insert(
            tableAdminRange,
            {
              columnRangeId: rangeId,
              columnName: name,
              columnLatitude: point.lat.toString(),
              columnLongitude: point.long.toString(),
              columnCreatedAt: DateTime.now().toIso8601String(),
            },
          );
        }
      });

      if (kDebugMode) {
        debugPrint(
          'Saved ${rangePoints.length} points for range $rangeId',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Save admin range error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _createRangeExitStateTable(Database db) async {
    final columns = {
      columnId: 'INTEGER PRIMARY KEY AUTOINCREMENT',
      rangeExitEmployeeId: 'TEXT NOT NULL',
      columnRangeId: 'INTEGER NOT NULL',
      rangeExitLatitude: 'REAL NOT NULL',
      rangeExitLongitude: 'REAL NOT NULL',
      rangeExitCreatedAt: 'TEXT NOT NULL',
    };

    await createTableIfNotExists(
      tableRangeExitState,
      columns,
      databaseConfig: db,
    );
  }



  Future<void> _createPendingRangeEventsTable(Database db) async {
    final columns = {
      pendingEventId: 'INTEGER PRIMARY KEY AUTOINCREMENT',
      pendingEventEmployeeId: 'TEXT NOT NULL',
      pendingEventRangeId: 'INTEGER NOT NULL',
      pendingEventLatitude: 'REAL NOT NULL',
      pendingEventLongitude: 'REAL NOT NULL',
      pendingEventIsUserOut: 'INTEGER NOT NULL',
      pendingEventGpsStatus: 'INTEGER NOT NULL DEFAULT 1',
      pendingEventBatteryStatus: "TEXT NOT NULL DEFAULT '0'",
      pendingEventAddress: "TEXT NOT NULL DEFAULT ''",
      pendingEventCreatedAt: 'TEXT NOT NULL',
    };

    await createTableIfNotExists(
      tablePendingRangeEvents,
      columns,
      databaseConfig: db,
    );

    if (kDebugMode) {
      debugPrint('Table verified: $tablePendingRangeEvents');
    }
  }

  /// Stores one geofence transition while offline or when the API fails.
  /// isUserOut: 1 = outside/exit, 0 = inside/return.
  Future<int> insertPendingRangeEvent({
    required String employeeId,
    required int rangeId,
    required double latitude,
    required double longitude,
    required int isUserOut,
    required int gpsStatus,
    required String batteryStatus,
    required String address,
  }) async {
    try {
      final db = await database;

      return await db.insert(
        tablePendingRangeEvents,
        {
          pendingEventEmployeeId: employeeId,
          pendingEventRangeId: rangeId,
          pendingEventLatitude: latitude,
          pendingEventLongitude: longitude,
          pendingEventIsUserOut: isUserOut,
          pendingEventGpsStatus: gpsStatus,
          pendingEventBatteryStatus: batteryStatus,
          pendingEventAddress: address,
          pendingEventCreatedAt: DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e, stackTrace) {
      debugPrint('Insert pending range event error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return 0;
    }
  }

  /// Returns pending events in insertion order.
  Future<List<Map<String, dynamic>>> getPendingRangeEvents() async {
    try {
      final db = await database;
      return await db.query(
        tablePendingRangeEvents,
        orderBy: '$pendingEventId ASC',
      );
    } catch (e, stackTrace) {
      debugPrint('Get pending range events error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  /// Deletes one event only after its API upload succeeds.
  Future<int> deletePendingRangeEvent(int eventId) async {
    try {
      final db = await database;
      return await db.delete(
        tablePendingRangeEvents,
        where: '$pendingEventId = ?',
        whereArgs: [eventId],
      );
    } catch (e, stackTrace) {
      debugPrint('Delete pending range event error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return 0;
    }
  }

  Future<bool> hasActiveRangeExit({
    required String employeeId,
    required int rangeId,
  }) async {
    final db = await database;

    final rows = await db.query(
      tableRangeExitState,
      where: '$rangeExitEmployeeId = ? AND $columnRangeId = ?',
      whereArgs: [employeeId, rangeId],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  // save when user go outside only 1 time
  Future<void> saveActiveRangeExit({
    required String employeeId,
    required int rangeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final db = await database;

      debugPrint('📌 Database path: ${db.path}');
      debugPrint('📌 Employee ID: $employeeId');
      debugPrint('📌 Range ID: $rangeId');

      await db.transaction((txn) async {
        final existing = await txn.query(
          tableRangeExitState,
          where: '$rangeExitEmployeeId = ? AND $columnRangeId = ?',
          whereArgs: [employeeId, rangeId],
          limit: 1,
        );

        debugPrint('📌 Existing records: ${existing.length}');
        debugPrint('📌 Existing data: $existing');

        if (existing.isNotEmpty) {
          debugPrint('⚠️ Record already exists. Insert skipped.');
          return;
        }

        final insertedId = await txn.insert(
          tableRangeExitState,
          {
            rangeExitEmployeeId: employeeId,
            columnRangeId: rangeId,
            rangeExitLatitude: latitude,
            rangeExitLongitude: longitude,
            rangeExitCreatedAt: DateTime.now().toIso8601String(),
          },
        );

        debugPrint('✅ Inserted row ID: $insertedId');

        final rows = await txn.query(tableRangeExitState);
        debugPrint('📌 Total exit records: ${rows.length}');
        debugPrint('📌 Exit records: $rows');
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Save range exit failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  // Future<void> saveActiveRangeExit({
  //   required String employeeId,
  //   required int rangeId,
  //   required double latitude,
  //   required double longitude,
  // }) async {
  //   final db = await database;
  //
  //   await db.transaction((txn) async {
  //     final existing = await txn.query(
  //       tableRangeExitState,
  //       where: '$rangeExitEmployeeId = ? AND $columnRangeId = ?',
  //       whereArgs: [employeeId, rangeId],
  //       limit: 1,
  //     );
  //
  //     if (existing.isNotEmpty) return;
  //
  //     await txn.insert(tableRangeExitState, {
  //       rangeExitEmployeeId: employeeId,
  //       columnRangeId: rangeId,
  //       rangeExitLatitude: latitude,
  //       rangeExitLongitude: longitude,
  //       rangeExitCreatedAt: DateTime.now().toIso8601String(),
  //     });
  //   });
  // }

  // clear when user come in range
  Future<void> clearActiveRangeExit({
    required String employeeId,
    required int rangeId,
  }) async {
    final db = await database;

    await db.delete(
      tableRangeExitState,
      where: '$rangeExitEmployeeId = ? AND $columnRangeId = ?',
      whereArgs: [employeeId, rangeId],
    );
  }



  //  Fetch location list (range)
  Future<List<LatLng>> fetchAdminRange(int rangeId) async {
    try {
      final db = await database;

      final result = await db.query(
        tableAdminRange,
        where: '$columnRangeId = ?',
        whereArgs: [rangeId],
        orderBy: '$columnId ASC',
      );

      return result.map((row) {
        return LatLng(
          double.parse(row[columnLatitude].toString()),
          double.parse(row[columnLongitude].toString()),
        );
      }).toList();
    } catch (e) {
      debugPrint('Fetch admin range error: $e');
      return [];
    }
  }

// delete admin range when user log out
  Future<void> clearAdminRangeTable() async {
    try {
      final db = await database;

      await db.delete(tableAdminRange);

      if (kDebugMode) {
        debugPrint('Admin range table cleared successfully');
      }
    } catch (e, stackTrace) {
      debugPrint('Clear admin range table error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // CREATE USER TABLE
  // ============================================================

  Future<void> _createUserDetailTable(Database db) async {
    final columns = {
      columnEmpId: 'TEXT NOT NULL',
      columnUserId: 'TEXT NOT NULL',
      columnCompanyId: 'TEXT NOT NULL',
      columnToken: 'TEXT NOT NULL',
      columnBaseURL: 'TEXT',
    };

    await createTableIfNotExists(
      userTable,
      columns,
      databaseConfig: db,
    );

    if (kDebugMode) {
      debugPrint(
        'Table verified: $userTable',
      );
    }
  }

  // ============================================================
  // CREATE LOCATION TRACKING STATE TABLE
  // ============================================================

  // Future<void> _createLocationTrackingStateTable(
  //     Database db,
  //     ) async {
  //   final columns = {
  //     trackingStateId: 'INTEGER PRIMARY KEY',
  //     trackingStateLatitude: 'REAL NOT NULL',
  //     trackingStateLongitude: 'REAL NOT NULL',
  //     trackingStateUpdatedAt: 'TEXT NOT NULL',
  //   };
  //
  //   await createTableIfNotExists(
  //     locationTrackingStateTable,
  //     columns,
  //     databaseConfig: db,
  //   );
  //
  //   if (kDebugMode) {
  //     debugPrint(
  //       'Table verified: $locationTrackingStateTable',
  //     );
  //   }
  // }

  // ============================================================
  // TABLE CHECK
  // ============================================================

  Future<bool> isTableExists(
      String tableName,
      ) async {
    final db = await database;

    return _isTableExists(
      db,
      tableName,
    );
  }

  Future<bool> _isTableExists(
      Database db,
      String tableName,
      ) async {
    final result = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name = ?
      ''',
      [tableName],
    );

    return result.isNotEmpty;
  }

  // ============================================================
  // GENERIC CREATE TABLE
  // ============================================================

  Future<void> createTableIfNotExists(
      String tableName,
      Map<String, String> columns, {
        Database? databaseConfig,
      }) async {
    final db = databaseConfig ?? await database;

    final columnsString = columns.entries
        .map(
          (entry) => '${entry.key} ${entry.value}',
    )
        .join(', ');

    await db.execute(
      'CREATE TABLE IF NOT EXISTS $tableName ($columnsString)',
    );

    // ----------------------------------------------------------
    // Check and add missing columns
    // ----------------------------------------------------------

    final existingColumns = await db.rawQuery(
      'PRAGMA table_info($tableName)',
    );

    final existingColumnNames = existingColumns
        .map(
          (column) => column['name'] as String,
    )
        .toSet();

    for (final column in columns.keys) {
      if (!existingColumnNames.contains(column)) {
        await addColumnIfNotExists(
          db,
          tableName,
          column,
          columns[column]!,
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
        'Table verified: $tableName',
      );
    }
  }

  // ============================================================
  // ADD COLUMN
  // ============================================================

  Future<void> addColumnIfNotExists(
      Database db,
      String tableName,
      String columnName,
      String columnType,
      ) async {
    final result = await db.rawQuery(
      'PRAGMA table_info($tableName)',
    );

    final columnExists = result.any(
          (column) => column['name'] == columnName,
    );

    if (columnExists) {
      return;
    }

    await db.execute(
      'ALTER TABLE $tableName '
          'ADD COLUMN $columnName $columnType',
    );

    if (kDebugMode) {
      debugPrint(
        'Column $columnName added to $tableName',
      );
    }
  }

  // ============================================================
  // GENERIC INSERT
  // ============================================================

  Future<int> insertData(
      String tableName,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    if (!await _isTableExists(db, tableName)) {
      debugPrint(
        'Insert failed. Table does not exist: $tableName',
      );

      return 0;
    }

    return db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // GENERIC GET DATA
  // ============================================================

  Future<List<Map<String, dynamic>>> getData(
      String tableName,
      ) async {
    final db = await database;

    if (!await _isTableExists(db, tableName)) {
      debugPrint(
        'Table does not exist: $tableName',
      );

      return [];
    }

    return db.query(tableName);
  }

  // // ============================================================
  // // GET DATA WITH CONDITION
  // // ============================================================
  //
  // Future<List<Map<String, dynamic>>> getDataWithCondition(
  //     String tableName,
  //     String whereClause,
  //     List<dynamic> whereArgs,
  //     ) async {
  //   final db = await database;
  //
  //   if (!await _isTableExists(db, tableName)) {
  //     debugPrint(
  //       'Table does not exist: $tableName',
  //     );
  //
  //     return [];
  //   }
  //
  //   return db.query(
  //     tableName,
  //     where: whereClause,
  //     whereArgs: whereArgs,
  //   );
  // }

  // ============================================================
  // DELETE DATA
  // ============================================================

  Future<int> deleteData(
      String tableName,
      String whereClause,
      List<dynamic> whereArgs,
      ) async {
    final db = await database;

    if (!await _isTableExists(db, tableName)) {
      debugPrint(
        'Delete failed. Table does not exist: $tableName',
      );

      return 0;
    }

    return db.delete(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  // ============================================================
  // CLEAR TABLE
  // ============================================================

  Future<void> clearTable(
      String tableName,
      ) async {
    final db = await database;

    if (!await _isTableExists(db, tableName)) {
      debugPrint(
        'Cannot clear. Table does not exist: $tableName',
      );

      return;
    }

    await db.delete(tableName);

    if (kDebugMode) {
      debugPrint(
        'All data cleared from table: $tableName',
      );
    }
  }

  // ============================================================
  // SAVE USER
  // ============================================================

  Future<int> createEmpInfoTable({
    int empId = 0,
    int userId = 0,
    int companyId = 0,
    String baseUrl = '',
    String columnToken = '',
  }) async {
    try {
      final db = await database;

      await _createUserDetailTable(db);

      await db.delete(userTable);

      final result = await db.insert(
        userTable,
        LocationUserDataModel(
          token: columnToken,
          companyId: '$companyId' ,
          empId: '$empId',
          userId: '$userId',
          baseUrl: baseUrl,

        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return result;
    } catch (e, stackTrace) {
      debugPrint(
        'Save user error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  // ============================================================
  // GET STORED USER
  // ============================================================

  Future<LocationUserDataModel> fetchStoredUser() async {
    try {
      final db = await database;

      await _createUserDetailTable(db);

      final result = await db.query(
        userTable,
        limit: 1,
      );

      if (result.isEmpty) {
        return LocationUserDataModel.fromMap({});
      }

      return LocationUserDataModel.fromMap(
        result.first,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Fetch stored user error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return LocationUserDataModel.fromMap({});
    }
  }


  Future<bool> updateBaseUrl(String baseUrl) async {
    try {
      final db = await database;

      await _createUserDetailTable(db);

      final result = await db.update(
        userTable,
        {
          'baseUrl': baseUrl,
        },
      );

      debugPrint('BaseUrl updated: $baseUrl');

      return result > 0;
    } catch (e, stackTrace) {
      debugPrint('Update baseUrl error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  // ============================================================
  // GET OFFLINE LOCATIONS
  // ============================================================

/*  Future<List<LocationDataModel>> fetchOfflineLocationData() async {
    try {
      final db = await database;

      await _createLocationTable(db);

      final result = await db.query(
        table,
        orderBy: '$columnId ASC',
      );

      return result
          .map(
            (e) => LocationDataModel.fromMap(e),
      )
          .toList();
    } catch (e, stackTrace) {
      debugPrint(
        'Fetch location error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }*/

  // ============================================================
  // DELETE ALL LOCATIONS
  // ============================================================

/*  Future<void> deleteLocationData() async {
    try {
      final db = await database;

      await _createLocationTable(db);

      await db.delete(table);

      if (kDebugMode) {
        debugPrint(
          'All location data deleted.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Delete location error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }*/

  // ============================================================
  // DELETE USER DATA
  // ============================================================

  Future<void> deleteUserData() async {
    try {
      final db = await database;

      await _createUserDetailTable(db);

      await db.delete(userTable);

      // Also clear previous tracking location.
      // await clearLastTrackingLocation();

      if (kDebugMode) {
        debugPrint(
          'All User data cleared.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Delete User Data error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // INSERT LOCATION
  // ============================================================

  Future<int> insert(
      Map<String, dynamic> row,
      ) async {
    try {
      final db = await database;

      // await _createLocationTable(db);

      return await db.insert(
        table,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Insert location error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  // ============================================================
  // LAST TRACKING LOCATION
  // ============================================================

  /// Returns the last location that was processed/queued.
  ///
  /// This is NOT necessarily the last API request.
  /// It is the last location which crossed our movement threshold.
  ///
  // Future<Map<String, dynamic>?> getLastTrackingLocation() async {
  //   try {
  //     final db = await database;
  //
  //     await _createLocationTrackingStateTable(db);
  //
  //     final result = await db.query(
  //       locationTrackingStateTable,
  //       where: '$trackingStateId = ?',
  //       whereArgs: [1],
  //       limit: 1,
  //     );
  //
  //     if (result.isEmpty) {
  //       return null;
  //     }
  //
  //     return result.first;
  //   } catch (e, stackTrace) {
  //     debugPrint(
  //       'Get last tracking location error: $e',
  //     );
  //
  //     debugPrintStack(
  //       stackTrace: stackTrace,
  //     );
  //
  //     return null;
  //   }
  // }

  // // ============================================================
  // // SAVE LAST TRACKING LOCATION
  // // ============================================================
  //
  // Future<void> saveLastTrackingLocation({
  //   required double latitude,
  //   required double longitude,
  //   required String updatedAt,
  // }) async {
  //   try {
  //     final db = await database;
  //
  //     await _createLocationTrackingStateTable(db);
  //
  //     await db.insert(
  //       locationTrackingStateTable,
  //       {
  //         trackingStateId: 1,
  //         trackingStateLatitude: latitude,
  //         trackingStateLongitude: longitude,
  //         trackingStateUpdatedAt: updatedAt,
  //       },
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //
  //     if (kDebugMode) {
  //       debugPrint(
  //         '📍 Last tracking location saved: '
  //             '$latitude, $longitude',
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint(
  //       'Save tracking location error: $e',
  //     );
  //
  //     debugPrintStack(
  //       stackTrace: stackTrace,
  //     );
  //   }
  // }

  // // ============================================================
  // // CLEAR LAST TRACKING LOCATION
  // // ============================================================
  //
  // Future<void> clearLastTrackingLocation() async {
  //   try {
  //     final db = await database;
  //
  //     await _createLocationTrackingStateTable(db);
  //
  //     await db.delete(
  //       locationTrackingStateTable,
  //     );
  //
  //     if (kDebugMode) {
  //       debugPrint(
  //         '📍 Last tracking location cleared.',
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint(
  //       'Clear tracking location error: $e',
  //     );
  //
  //     debugPrintStack(
  //       stackTrace: stackTrace,
  //     );
  //   }
  // }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();

      _database = null;

      if (kDebugMode) {
        debugPrint(
          'Database closed.',
        );
      }
    }
  }

  // ============================================================
  // DEBUG: PRINT TABLES
  // ============================================================

  Future<void> printDatabaseTables() async {
    if (!kDebugMode) return;

    final db = await database;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    debugPrint(
      'Database tables: $tables',
    );
  }
}
