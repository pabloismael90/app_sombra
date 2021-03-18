class Finca {
    Finca({
        this.id,
        this.userid = 1,
        this.nombreFinca = '',
        this.nombreProductor = '',
        this.areaFinca = 0.0,
        this.tipoMedida = 1,
        this.nombreTecnico = '',
    });

    String id;
    int userid;
    String nombreFinca;
    String nombreProductor;
    double areaFinca;
    int tipoMedida;
    String nombreTecnico;

    factory Finca.fromJson(Map<String, dynamic> json) => Finca(
        id: json["id"],
        userid: json["userid"],
        nombreFinca: json["nombreFinca"],
        nombreProductor: json["nombreProductor"],
        areaFinca: json["areaFinca"].toDouble(),
        tipoMedida: json["tipoMedida"],
        nombreTecnico: json["nombreTecnico"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "userid": userid,
        "nombreFinca": nombreFinca,
        "nombreProductor": nombreProductor,
        "areaFinca": areaFinca,
        "tipoMedida": tipoMedida,
        "nombreTecnico": nombreTecnico,
    };
}