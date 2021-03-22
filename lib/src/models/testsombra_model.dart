import 'dart:convert';

TestSombra testSombraFromJson(String str) => TestSombra.fromJson(json.decode(str));

String testSombraToJson(TestSombra data) => json.encode(data.toJson());

class TestSombra {
    TestSombra({
        this.id,
        this.idFinca = '',
        this.idLote = '',
        this.estaciones = 3,
        this.fechaTest,
        this.surcoDistancia = 0.0,
        this.plantaDistancia = 0.0,
    });

    String id;
    String idFinca;
    String idLote;
    int estaciones;
    String fechaTest;
    double surcoDistancia;
    double plantaDistancia;

    factory TestSombra.fromJson(Map<String, dynamic> json) => TestSombra(
        id: json["id"],
        idFinca: json["idFinca"],
        idLote: json["idLote"],
        estaciones: json["estaciones"],
        fechaTest: json["fechaTest"],
        surcoDistancia: json["surcoDistancia"].toDouble(),
        plantaDistancia: json["plantaDistancia"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idFinca": idFinca,
        "idLote": idLote,
        "estaciones": estaciones,
        "fechaTest": fechaTest,
        "surcoDistancia": surcoDistancia,
        "plantaDistancia": plantaDistancia,
    };
}