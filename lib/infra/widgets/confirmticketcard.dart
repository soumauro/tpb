import 'package:cobradortpb/infra/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

void confirmtiketCard(TicketModel ticket) {
  Get.bottomSheet(
    SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(Get.context!).size.height * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Detalhes do Bilhete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),
            const Divider(
              color: Colors.blueGrey,
              thickness: 1,
              height: 20,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  title: 'Origem',
                  value: ticket.startAt,
                  icon: Icons.location_on,
                ),
                _buildInfoColumn(
                  title: 'Destino',
                  value: ticket.endAt,
                  icon: Icons.flag,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'Data',
              value: ticket.createdAt.toIso8601String(),
            ),
            _buildInfoRow(
              icon: Icons.person,
              title: 'Pessoas',
              value: '${ticket.pessoas}',
            ),
            _buildInfoRow(
              icon: Icons.monetization_on,
              title: 'Preço',
              value: '${ticket.price} MZN',
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'QR Code do Bilhete',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  QrImageView(
                    data: ticket.uuid,
                    size: 150,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Mostre ao cobrador para autenticar seu bilhete',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // Fecha o bottom sheet
                },
                icon: const Icon(Icons.close),
                label: const Text("Fechar"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.blueGrey[800]),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blueGrey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoColumn({required String title, required String value, required IconData icon}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: Colors.blueGrey[800]),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueGrey[800],
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Colors.blueGrey[600],
        ),
      ),
    ],
  );
}
