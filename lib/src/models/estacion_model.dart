class Estacion {
    Estacion({
        this.id,
        this.idTestSombra,
        this.nestacion,
        this.cobertura = 0.0,
    });

    String id;
    String idTestSombra;
    int nestacion;
    double cobertura;

    factory Estacion.fromJson(Map<String, dynamic> json) => Estacion(
        id: json["id"],
        idTestSombra: json["idTestSombra"],
        nestacion: json["Nestacion"],
        cobertura: json["cobertura"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idTestSombra": idTestSombra,
        "Nestacion": nestacion,
        "cobertura": cobertura,
    };
}