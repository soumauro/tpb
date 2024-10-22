import 'dart:io';
import 'package:cobradortpb/infra/apiname.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:cobradortpb/infra/models/passinfo.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CreatingPassController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final TextEditingController nameController = TextEditingController();
  // final TextEditingController documentTypeController = TextEditingController(); // Removido
  final TextEditingController documentNumberController =
      TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  // Lista de tipos de documentos
  final List<String> documentTypes = [
    'B.I',
    'DIRE',
    'PASSAPORT',
    'CARTAO DE ELEITOR'
  ];

  // Documento selecionado
  var selectedDocumentType = ''.obs;

  // Variáveis para armazenar dados
  String? userUuid;
  String? photoUrl;
  XFile? capturedImage;
  var isLoading = false.obs;

  // Endpoint Externo
  final String apiUrl = '$passInfoUrl/insert'; // Adicionando protocolo correto

  // Obter UID do usuário autenticado
  Future<void> fetchUserUuid() async {
    User? user = _auth.currentUser;
    userUuid = user?.uid;
    update(); // Atualiza a UI se necessário
  }

  // Função para gerar UUID único para o pass
  String generatePassUuid() {
    return _uuid.v4();
  }

  // Função para capturar a imagem usando a câmera e detectar rosto
  Future<void> captureImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        // Detectar rosto na imagem capturada
        bool hasFace = await _detectFace(File(image.path));
        if (hasFace) {
          capturedImage = image;
          Get.snackbar('Sucesso', 'A imagem foi capturada com sucesso.');
        } else {
          Get.snackbar('Erro',
              'Nenhum rosto detectado na imagem. Por favor, tente novamente.');
        }
        update(); // Atualiza a UI para mostrar a imagem capturada ou erro
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao capturar a imagem: $e');
    }
  }

  // Função para detectar rosto usando Google ML Kit
  Future<bool> _detectFace(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);
    // ignore: deprecated_member_use
    final FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
          enableContours: false,
          enableLandmarks: false,
          performanceMode: FaceDetectorMode.accurate

          ///mode: FaceDetectorMode.accurate,
          ),
    );

    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      faceDetector.close();
      return faces.isNotEmpty;
    } catch (e) {
      Get.snackbar('Erro', 'Falha na detecção de rosto: $e');
      return false;
    }
  }

  // Função para fazer upload da imagem para o Firebase Storage
  Future<String?> uploadPhoto() async {
    if (capturedImage == null) return null;

    try {
      final String fileName = _uuid.v4();
      final Reference storageRef =
          _storage.ref().child('userPhotos/$fileName.jpg');

      // Iniciar o upload e aguardar sua conclusão
      UploadTask uploadTask = storageRef.putFile(File(capturedImage!.path));
      await uploadTask; // Aguarda a conclusão do upload

      // Verificar se o upload foi bem-sucedido
      final TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        // Obter a URL de download
        String downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl;
      } else {
        Get.snackbar('Erro', 'Falha no upload da imagem.');
        return null;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao enviar a imagem: $e');
      return null;
    }
  }

  // Função para validar e enviar o formulário
Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar('Erro', 'Por favor, preencha todos os campos corretamente.');
      return;
    }

    if (capturedImage == null) {
      Get.snackbar('Erro', 'Por favor, capture uma foto.');
      return;
    }

    isLoading.value = true; // Ativa o estado de carregamento
    update(); 

    try {
      // Upload da foto
      photoUrl = await uploadPhoto();
      if (photoUrl == null) {
        // O erro já foi tratado na função uploadPhoto
        return;
      }

      // Obter UID do usuário
      await fetchUserUuid();
      if (userUuid == null) {
        Get.snackbar('Erro', 'Usuário não autenticado.');
        return;
      }

      // Criar objeto PassInfo
      PassInfo passInfo = PassInfo(
        uuid: generatePassUuid(),
        name: nameController.text.trim(),
        userUuid: userUuid,
        documentType: selectedDocumentType.value, // Usar o tipo selecionado
        documentNumber: documentNumberController.text.trim(),
        photoUrl: photoUrl,
        birthday: DateTime.parse(birthdayController.text.trim()),
        status: 0, // Exemplo de status
        createdAt: DateTime.now(),
      );

      // Salvar no Endpoint Externo
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(passInfo.toJson()), // Usar toJson()
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Sucesso', 'Passo criado com sucesso!');
        clearForm();
      } else {
        Get.snackbar('Erro', 'Falha ao inserir o usuário. Código: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao inserir o usuário: $e');
    } finally {
      isLoading.value = false; // Desativa o estado de carregamento após a operação
    }
  }
  // Função para limpar o formulário após o envio
  void clearForm() {
    nameController.clear();
    selectedDocumentType.value = '';
    documentNumberController.clear();
    birthdayController.clear();
    capturedImage = null;
    photoUrl = null;
    update(); // Atualiza a UI para refletir as mudanças
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserUuid();
  }

  @override
  void onClose() {
    nameController.dispose();
    documentNumberController.dispose();
    birthdayController.dispose();
    super.onClose();
  }
}
