class Terreno {
  String id;
  String nome;
  String localizacao;
  double preco;
  String status; // Ex: Disponível, Em Negociação, Vendido
  String documentoUrl;

  Terreno({
    required this.id,
    required this.nome,
    required this.localizacao,
    required this.preco,
    required this.status,
    this.documentoUrl = "",
  });

  // Converte de JSON (Firebase) para Objeto
  factory Terreno.fromMap(Map<String, dynamic> map, String id) {
    return Terreno(
      id: id,
      nome: map['nome'] ?? '',
      localizacao: map['localizacao'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Disponível',
      documentoUrl: map['documentoUrl'] ?? '',
    );
  }

  // Converte de Objeto para JSON (Firebase)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'localizacao': localizacao,
      'preco': preco,
      'status': status,
      'documentoUrl': documentoUrl,
    };
  }
}
