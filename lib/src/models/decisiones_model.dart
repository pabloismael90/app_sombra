class Decisiones {
    Decisiones({
        this.id,
        this.idPregunta,
        this.idItem,
        this.repuesta,
        this.idTest,
    });

    String id;
    int idPregunta;
    int idItem;
    int repuesta;
    String idTest;

    factory Decisiones.fromJson(Map<String, dynamic> json) => Decisiones(
        id: json["id"],
        idPregunta: json["idPregunta"],
        idItem: json["idItem"],
        repuesta: json["repuesta"],
        idTest: json["idTest"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idPregunta": idPregunta,
        "idItem": idItem,
        "repuesta": repuesta,
        "idTest": idTest,
    };
}