import 'package:cloud_firestore/cloud_firestore.dart';

class Condominio {
  final String id;
  final String terrenoId;
  final double valor;
  final String dataVencimento;
  final String instrucoesPagamento;
  final String status; // Ex: 'Pendente', 'Pago'

  Condominio({
    required this.id,
    required this.terrenoId,
    required this.valor,
    required this.dataVencimento,
    required this.instrucoesPagamento,
    this.status = 'Pendente',
  });

  // Converte JSON do Firestore para Objeto Dart
  factory Condominio.fromMap(Map<String, dynamic> map, String id) {
    return Condominio(
      id: id,
      terrenoId: map['terrenoId'] ?? '',
      valor: (map['valor'] ?? 0.0).toDouble(),
      dataVencimento: map['dataVencimento'] ?? '',
      instrucoesPagamento: map['instrucoesPagamento'] ?? '',
      status: map['status'] ?? 'Pendente',
    );
  }

  // Converte Objeto Dart para JSON do Firestore
  Map<String, dynamic> toMap() {
    return {
      'terrenoId': terrenoId,
      'valor': valor,
      'dataVencimento': dataVencimento,
      'instrucoesPagamento': instrucoesPagamento,
      'status': status,
    };
  }
}
