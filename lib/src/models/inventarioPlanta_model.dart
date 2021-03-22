class InventacioPlanta {
    InventacioPlanta({
        this.id,
        this.idEstacion,
        this.idPlanta,
        this.pequeno,
        this.mediano,
        this.grande,
        this.uso,
    });

    String id;
    String idEstacion;
    int idPlanta;
    int pequeno;
    int mediano;
    int grande;
    int uso;

    factory InventacioPlanta.fromJson(Map<String, dynamic> json) => InventacioPlanta(
        id: json["id"],
        idEstacion: json["idEstacion"],
        idPlanta: json["idPlanta"],
        pequeno: json["pequeno"],
        mediano: json["mediano"],
        grande: json["grande"],
        uso: json["uso"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idEstacion": idEstacion,
        "idPlanta": idPlanta,
        "pequeno": pequeno,
        "mediano": mediano,
        "grande": grande,
        "uso": uso,
    };
}