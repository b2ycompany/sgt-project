import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestaoDocumentosScreen extends StatefulWidget {
  final String terrenoId;
  final String terrenoNome;

  const GestaoDocumentosScreen({
    super.key,
    required this.terrenoId,
    required this.terrenoNome,
  });

  @override
  State<GestaoDocumentosScreen> createState() => _GestaoDocumentosScreenState();
}

class _GestaoDocumentosScreenState extends State<GestaoDocumentosScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Função para selecionar e fazer upload do contrato/documento
  Future<void> _uploadDocumento() async {
    // 1. Selecionar o arquivo
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      try {
        PlatformFile file = result.files.first;
        String fileName =
            'documentos/${widget.terrenoId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

        // 2. Referência no Firebase Storage
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        // 3. Iniciar o Upload (Tecnologia de ponta com monitorização)
        UploadTask uploadTask = storageRef.putData(file.bytes!);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        });

        // 4. Obter a URL pública após o término
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // 5. Vincular a URL ao terreno no Firestore (Conforme Escopo SGT)
        await FirebaseFirestore.instance
            .collection('terrenos')
            .doc(widget.terrenoId)
            .collection('documentos')
            .add({
              'nome': file.name,
              'url': downloadUrl,
              'dataUpload': FieldValue.serverTimestamp(),
              'tipo': file.extension,
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Documento vinculado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro no upload: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Documentos: ${widget.terrenoNome}"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isUploading)
            LinearProgressIndicator(
              value: _uploadProgress,
              color: Colors.green,
            ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('terrenos')
                  .doc(widget.terrenoId)
                  .collection('documentos')
                  .orderBy('dataUpload', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text("Nenhum documento anexado a este terreno."),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Color(0xFF1A237E),
                        ),
                        title: Text(doc['nome']),
                        subtitle: Text("Tipo: ${doc['tipo']}"),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.cloud_download,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // Lógica para abrir/baixar documento
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadDocumento,
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text(
          "ADICIONAR DOCUMENTO",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
