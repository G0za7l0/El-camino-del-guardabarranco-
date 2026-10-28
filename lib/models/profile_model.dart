class ProfileModel {
  final int idUsuario;
  final String alias;
  final String nombreRol;
  final String fechaNacimiento;
  final String gradoEscolar;
  final int puntosAcumulados;
  final int monedasVirtuales;
  final int rachaActualDias;
  final int mejorRachaDias;
  final String nivelTitulo;
  final int nivelNumero;
  final String? avatarElegido;
  final String? avatarUrl1;
  final bool altoContraste;
  final bool lecturaVozActiva;
  final int tamanoFuente;
  final List<dynamic> insignias;

  ProfileModel({
    required this.idUsuario,
    required this.alias,
    required this.nombreRol,
    required this.fechaNacimiento,
    required this.gradoEscolar,
    required this.puntosAcumulados,
    required this.monedasVirtuales,
    required this.rachaActualDias,
    required this.mejorRachaDias,
    required this.nivelTitulo,
    required this.nivelNumero,
    required this.avatarElegido,
    required this.avatarUrl1,
    required this.altoContraste,
    required this.lecturaVozActiva,
    required this.tamanoFuente,
    required this.insignias,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      idUsuario: json['idUsuario'] ?? 0,
      alias: json['alias'] ?? '',
      nombreRol: json['nombreRol'] ?? '',
      fechaNacimiento: json['fechaNacimiento'] ?? '',
      gradoEscolar: json['gradoEscolar'] ?? '',
      puntosAcumulados: json['puntosAcumulados'] ?? 0,
      monedasVirtuales: json['monedasVirtuales'] ?? 0,
      rachaActualDias: json['rachaActualDias'] ?? 0,
      mejorRachaDias: json['mejorRachaDias'] ?? 0,
      nivelTitulo: json['nivelTitulo'] ?? '',
      nivelNumero: json['nivelNumero'] ?? 1,
      avatarElegido: json['avatarElegido'],
      avatarUrl1: json['avatarUrl1'],
      altoContraste: json['altoContraste'] ?? false,
      lecturaVozActiva: json['lecturaVozActiva'] ?? false,
      tamanoFuente: json['tamanoFuente'] ?? 2,
      insignias: json['insignias'] ?? [],
    );
  }
}