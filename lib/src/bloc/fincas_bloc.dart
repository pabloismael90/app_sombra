
import 'dart:async';


import 'package:app_sombra/src/models/estacion_model.dart';
import 'package:app_sombra/src/models/inventarioPlanta_model.dart';
import 'package:app_sombra/src/models/testsombra_model.dart';
import 'package:app_sombra/src/providers/db_provider.dart';

class FincasBloc {

    static final FincasBloc _singleton = new FincasBloc._internal();

    factory FincasBloc() {
        return _singleton;
        
    }

    FincasBloc._internal() {
        obtenerFincas();
        obtenerParcelas();
    }

    final _fincasController = StreamController<List<Finca>>.broadcast();
    final _parcelasController = StreamController<List<Parcela>>.broadcast();
    final _podaController = StreamController<List<TestSombra>>.broadcast();
    final _estacionController = StreamController<Estacion>.broadcast();
    final _inventarioController = StreamController<List<InventacioPlanta>>.broadcast();

    

    final _fincasSelectControl = StreamController<List<Map<String, dynamic>>>.broadcast();
    final _parcelaSelectControl = StreamController<List<Map<String, dynamic>>>.broadcast();

    Stream<List<Finca>> get fincaStream => _fincasController.stream;
    Stream<List<Parcela>> get parcelaStream => _parcelasController.stream;
    Stream<List<TestSombra>> get podaStream => _podaController.stream;
    Stream<Estacion> get estacionStream => _estacionController.stream;
    Stream<List<InventacioPlanta>> get inventarioStream => _inventarioController.stream;



    Stream<List<Map<String, dynamic>>> get fincaSelect => _fincasSelectControl.stream;
    Stream<List<Map<String, dynamic>>> get parcelaSelect => _parcelaSelectControl.stream;

    
    //fincas
    obtenerFincas() async {
        _fincasController.sink.add( await DBProvider.db.getTodasFincas() );
    }

    addFinca( Finca finca ) async{
        await DBProvider.db.nuevoFinca(finca);
        obtenerFincas();
    }

    actualizarFinca( Finca finca ) async{
        await DBProvider.db.updateFinca(finca);
        obtenerFincas();
    }

    borrarFinca( String id ) async {
        await DBProvider.db.deleteFinca(id);
        obtenerFincas();
    }

    selectFinca() async{
        _fincasSelectControl.sink.add( await DBProvider.db.getSelectFinca());
    }
    

    //Parcelas
    obtenerParcelas() async {
        _parcelasController.sink.add( await DBProvider.db.getTodasParcelas() );
    }
    
    obtenerParcelasIdFinca(String idFinca) async {
        _parcelasController.sink.add( await DBProvider.db.getTodasParcelasIdFinca(idFinca) );
    }

    addParcela( Parcela parcela, String idFinca ) async{
        await DBProvider.db.nuevoParcela(parcela);
        obtenerParcelasIdFinca(idFinca);
    }

    actualizarParcela( Parcela parcela, String idFinca ) async{
        await DBProvider.db.updateParcela(parcela);
        obtenerParcelasIdFinca(idFinca);
    }
    
    borrarParcela( String id ) async {
        await DBProvider.db.deleteParcela(id);
        obtenerParcelas();
    }

    selectParcela(String idFinca) async{
        _parcelaSelectControl.sink.add( await DBProvider.db.getSelectParcelasIdFinca(idFinca));
    }

    //Sombra
    obtenerSombra() async {
        _podaController.sink.add( await DBProvider.db.getTodasTestSombra() );
    }
    
    addTestSombra( TestSombra nuevoTest) async{
        await DBProvider.db.nuevoTestSombra(nuevoTest);
        obtenerSombra();
    }

    borrarTestSombra( String idTest) async{
        await DBProvider.db.deleteTestSombra(idTest);
        obtenerSombra();
    }

    //Estacion
    obtenerEstacion(String idTestSombra, int nEstacion) async {
        _estacionController.sink.add( await DBProvider.db.getEstacionIdSombra(idTestSombra, nEstacion) );
    }

    addEstacion( Estacion nuevoEstacion, String idTestSombra, int nEstacion) async{
        await DBProvider.db.nuevoEstacion(nuevoEstacion);
        obtenerEstacion(idTestSombra, nEstacion);
    }


    //Inventario Plantas
    obtenerInventario( String idEstacion) async {
        _inventarioController.sink.add( await DBProvider.db.getInventarioIdEstacion(idEstacion) );
    }

    addInventario( InventacioPlanta nuevoInventario, String idEstacion) async{
        await DBProvider.db.nuevoInventario(nuevoInventario);
        obtenerInventario(idEstacion);
    }


    //deciones
    


    


    //Cerrar stream
    dispose() {
        _fincasController?.close();
        _parcelasController?.close();
        _fincasSelectControl?.close();
        _estacionController?.close();
        _inventarioController?.close();

        _parcelaSelectControl?.close();
        _podaController?.close();

    }



}