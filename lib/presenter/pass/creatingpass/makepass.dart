import 'dart:io';

import 'package:cobradortpb/presenter/pass/creatingpass/creatingpasscontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreatingPassPage extends StatefulWidget {
  const CreatingPassPage({super.key});
  static const router = '/creatingPass';

  @override
  CreatingPassPageState createState() => CreatingPassPageState();
}

class CreatingPassPageState extends State<CreatingPassPage> {
  final CreatingPassController _controller = Get.put(CreatingPassController());

  // Função para selecionar data de aniversário
  Future<void> _selectBirthday(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _controller.birthdayController.text = formattedDate;
    }
  }

  // Função para capturar a imagem
  Future<void> _captureImage() async {
    await _controller.captureImage();
    setState(() {}); // Atualiza a UI para mostrar a imagem capturada ou erro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Passo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo Nome
              TextFormField(
                controller: _controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Tipo de Documento (Dropdown)
              Obx(() => DropdownButtonFormField<String>(
                    value: _controller.selectedDocumentType.value.isEmpty
                        ? null
                        : _controller.selectedDocumentType.value,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Documento',
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.documentTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _controller.selectedDocumentType.value = newValue;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, selecione o tipo de documento.';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16.0),

              // Campo Número do Documento
              TextFormField(
                controller: _controller.documentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número do Documento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o número do documento.';
                  }
                  // Adicione validação específica do documento aqui, se necessário
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo Aniversário
              TextFormField(
                controller: _controller.birthdayController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectBirthday(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, selecione sua data de nascimento.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Botão para Capturar Foto
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capturar Foto'),
                  ),
                  const SizedBox(width: 16.0),
                  _controller.photoUrl != null
                      ? Image.network(
                          _controller.photoUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : _controller.capturedImage != null
                          ? Image.file(
                              File(_controller.capturedImage!.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : const Text('Nenhuma foto capturada'),
                ],
              ),
              const SizedBox(height: 32.0),

              // Botão de Envio
              Obx((){ return 
              _controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _controller.submitForm();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                              double.infinity, 50), // Botão de largura total
                        ),
                        child: const Text('Enviar'),
                      ),
                    ); 
              })
            ],
          ),  
        ),
      ),

      
    );
  }
}
