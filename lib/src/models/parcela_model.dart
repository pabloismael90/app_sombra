class Parcela {
    Parcela({
        this.id,
        this.idFinca,
        this.nombreLote = '',
        this.areaLote = 0.0,
        this.variedadCacao = 1,
        this.numeroPlanta = 0,
    });

    String id;
    String idFinca;
    String nombreLote;
    double areaLote;
    int variedadCacao;
    int numeroPlanta;

    factory Parcela.fromJson(Map<String, dynamic> json) => Parcela(
        id: json["id"],
        idFinca: json["idFinca"],
        nombreLote: json["nombreLote"],
        areaLote: json["areaLote"].toDouble(),
        variedadCacao: json["variedadCacao"],
        numeroPlanta: json["numeroPlanta"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idFinca": idFinca,
        "nombreLote": nombreLote,
        "areaLote": areaLote,
        "variedadCacao": variedadCacao,
        "numeroPlanta": numeroPlanta,
    };
} 