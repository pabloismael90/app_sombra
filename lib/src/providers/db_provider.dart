import 'dart:io';


import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/inventarioPlanta_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


import 'package:app_sombra/src/models/finca_model.dart';
export 'package:app_sombra/src/models/finca_model.dart';
import 'package:app_sombra/src/models/parcela_model.dart';
export 'package:app_sombra/src/models/parcela_model.dart';

class DBProvider {

    static Database _database; 
    static final DBProvider db = DBProvider._();

    DBProvider._();

    Future<Database> get database async {

        if ( _database != null ) return _database;

        _database = await initDB();
        return _database;
    }

    initDB() async {

        Directory documentsDirectory = await getApplicationDocumentsDirectory();

        final path = join( documentsDirectory.path, 'poda.db' );

        print(path);

        return await openDatabase(
            path,
            version: 1,
            onOpen: (db) {},
            onConfigure: _onConfigure,
            onCreate: ( Database db, int version ) async {
                await db.execute(
                    'CREATE TABLE Finca ('
                    ' id TEXT PRIMARY KEY,'
                    ' userid INTEGER,'
                    ' nombreFinca TEXT,'
                    ' nombreProductor TEXT,'
                    ' areaFinca REAL,'
                    ' tipoMedida INTEGER,'
                    ' nombreTecnico TEXT'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE Parcela ('
                    ' id TEXT PRIMARY KEY,'
                    ' idFinca TEXT,'
                    ' nombreLote TEXT,'
                    ' areaLote REAL,'
                    ' variedadCacao INTEGER,'
                    ' numeroPlanta INTEGER,'
                    'CONSTRAINT fk_parcela FOREIGN KEY(idFinca) REFERENCES Finca(id) ON DELETE CASCADE'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE TestSombra ('
                    ' id TEXT PRIMARY KEY,'
                    ' idFinca TEXT,'
                    ' idLote TEXT,'
                    ' estaciones INTEGER,'
                    ' surcoDistancia REAL,'
                    ' plantaDistancia REAL,'
                    ' fechaTest TEXT,'
                    ' CONSTRAINT fk_fincaTest FOREIGN KEY(idFinca) REFERENCES Finca(id) ON DELETE CASCADE,'
                    ' CONSTRAINT fk_parcelaTest FOREIGN KEY(idLote) REFERENCES Parcela(id) ON DELETE CASCADE'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE Estacion ('
                    ' id TEXT PRIMARY KEY,'
                    ' idTestSombra TEXT,'
                    ' Nestacion INTEGER,'
                    ' cobertura REAL,'
                    ' CONSTRAINT fk_TestSombra FOREIGN KEY(idTestSombra) REFERENCES TestSombra(id) ON DELETE CASCADE'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE InventacioPlanta ('
                    ' id TEXT PRIMARY KEY,'
                    ' idEstacion TEXT,'
                    ' idPlanta INTEGER,'
                    ' pequeno INTEGER,'
                    ' mediano INTEGER,'
                    ' grande INTEGER,'
                    ' uso INTEGER,'
                    ' CONSTRAINT fk_Estacion FOREIGN KEY(idEstacion) REFERENCES Estacion(id) ON DELETE CASCADE'
                    ')'
                );



                   
            }
        
        );

    }

    static Future _onConfigure(Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
    }

    

    //ingresar Registros
    nuevoFinca( Finca nuevaFinca ) async {
        final db  = await database;
        final res = await db.insert('Finca',  nuevaFinca.toJson() );
        return res;
    }

    nuevoParcela( Parcela nuevaParcela ) async {
        final db  = await database;
        final res = await db.insert('Parcela',  nuevaParcela.toJson() );
        return res;
    }

    nuevoTestSombra( TestSombra nuevaPlaga ) async {
        final db  = await database;
        final res = await db.insert('TestSombra',  nuevaPlaga.toJson() );
        return res;
    }

    nuevoEstacion( Estacion nuevaEstacion ) async {
        final db  = await database;
        final res = await db.insert('Estacion',  nuevaEstacion.toJson() );
        return res;
    }

    nuevoInventario( InventacioPlanta nuevoInventario ) async {
        final db  = await database;
        final res = await db.insert('InventacioPlanta',  nuevoInventario.toJson() );
        return res;
    }

    




    
    
    //Obtener registros
    Future<List<Finca>> getTodasFincas() async {

        final db  = await database;
        final res = await db.query('Finca');

        List<Finca> list = res.isNotEmpty 
                                ? res.map( (c) => Finca.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<List<Parcela>> getTodasParcelas() async {

        final db  = await database;
        final res = await db.query('Parcela');

        List<Parcela> list = res.isNotEmpty 
                                ? res.map( (c) => Parcela.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<List<TestSombra>> getTodasTestSombra() async {

        final db  = await database;
        final res = await db.query('TestSombra');

        List<TestSombra> list = res.isNotEmpty 
                                ? res.map( (c) => TestSombra.fromJson(c) ).toList()
                                : [];
        return list;
    }


    
    
    //REgistros por id
    Future<Finca> getFincaId(String id) async{
        final db = await database;
        final res = await db.query('Finca', where: 'id = ?', whereArgs: [id]);
        return res.isNotEmpty ? Finca.fromJson(res.first) : null;
    }

    Future<Parcela> getParcelaId(String id) async{
        final db = await database;
        final res = await db.query('Parcela', where: 'id = ?', whereArgs: [id]);
        return res.isNotEmpty ? Parcela.fromJson(res.first) : null;
    }

    Future<TestSombra> getTestId(String id) async{
        final db = await database;
        final res = await db.query('TestSombra', where: 'id = ?', whereArgs: [id]);
        return res.isNotEmpty ? TestSombra.fromJson(res.first) : null;
    }

    Future<List<Parcela>> getTodasParcelasIdFinca(String idFinca) async{

        final db = await database;
        final res = await db.query('Parcela', where: 'idFinca = ?', whereArgs: [idFinca]);
        List<Parcela> list = res.isNotEmpty 
                    ? res.map( (c) => Parcela.fromJson(c) ).toList() 
                    : [];
        
        return list;            
    }

    Future<Estacion> getEstacionIdSombra(String idTestSombra, int nEstacion) async{
        Estacion errorEstacion = Estacion();
        final db = await database;
        final res = await db.query('Estacion', where: 'idTestSombra = ? and Nestacion = ?', whereArgs: [idTestSombra, nEstacion]);

        return res.isNotEmpty ? Estacion.fromJson(res.first) : errorEstacion;            
    }

    Future<List<InventacioPlanta>> getInventarioIdEstacion(String idEstacion) async{
        final db = await database;
        final res = await db.query('InventacioPlanta', where: 'idEstacion = ?', whereArgs: [idEstacion]);
        List<InventacioPlanta> list = res.isNotEmpty 
                    ? res.map( (c) => InventacioPlanta.fromJson(c) ).toList() 
                    : [];
        
        return list;          
    }




    //List Select
    Future<List<Map<String, dynamic>>> getSelectFinca() async {
       
        final db  = await database;
        final res = await db.rawQuery(
            "SELECT id AS value, nombreFinca AS label FROM Finca"
        );
        List<Map<String, dynamic>> list = res.isNotEmpty ? res : [];

        //print(list);

        return list; 
    }
    
    Future<List<Map<String, dynamic>>> getSelectParcelasIdFinca(String idFinca) async{
        final db = await database;
        final res = await db.rawQuery(
            "SELECT id AS value, nombreLote AS label FROM Parcela WHERE idFinca = '$idFinca'"
        );
        List<Map<String, dynamic>> list = res.isNotEmpty ? res : [];

        return list;
                    
    }


    // Actualizar Registros
    Future<int> updateFinca( Finca nuevaFinca ) async {

        final db  = await database;
        final res = await db.update('Finca', nuevaFinca.toJson(), where: 'id = ?', whereArgs: [nuevaFinca.id] );
        return res;

    }

    Future<int> updateParcela( Parcela nuevaParcela ) async {

        final db  = await database;
        final res = await db.update('Parcela', nuevaParcela.toJson(), where: 'id = ?', whereArgs: [nuevaParcela.id] );
        return res;

    }

  


    //Conteos analisis
    

    // Eliminar registros
    Future<int> deleteFinca( String idFinca ) async {

        final db  = await database;
        final res = await db.delete('Finca', where: 'id = ?', whereArgs: [idFinca]);
        return res;
    }
    Future<int> deleteParcela( String idParcela ) async {

        final db  = await database;
        final res = await db.delete('Parcela', where: 'id = ?', whereArgs: [idParcela]);
        return res;
    }

    Future<int> deleteTestSombra( String idTest ) async {

        final db  = await database;
        final res = await db.delete('TestSombra', where: 'id = ?', whereArgs: [idTest]);
        return res;
    }

    Future<int> deleteEspecie( int idPlanta, String  idEstacion) async {

        final db  = await database;
        final res = await db.delete('InventacioPlanta', where: 'idPlanta = ? and idEstacion = ?', whereArgs: [idPlanta, idEstacion]);
        return res;
    }


}