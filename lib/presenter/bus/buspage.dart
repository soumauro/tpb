import 'package:cobradortpb/presenter/bus/buscontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class Buspage extends StatelessWidget {
  static const router = "/Buspage";
  const Buspage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotas: Baixa - Munhava'),
        backgroundColor: Colors.blueAccent,
      ),
      body: GetBuilder<Buscontroller>(
        builder: (ctl) {
          if (ctl.busList == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exibe o título das rotas
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rotas disponíveis:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                        const Row(
                          children: [
                            Icon(Icons.directions_bus, color: Colors.blue),
                            SizedBox(width: 8.0),
                            Text('Baixa - Munhava: 3 autocarros'),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        const Row(
                          children: [
                            Icon(Icons.directions_bus, color: Colors.red),
                            SizedBox(width: 8.0),
                            Text('Munhava - Baixa: 2 autocarros'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 1.0),

                  // Google Map Widget
                  Container(
                    height: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.blueAccent, width: 2.0),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: ctl.kGooglePlex,
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('baixa-munhava'),
                          points: ctl.bus.paragem
                                  ?.map((loc) => LatLng(loc.x, loc.y))
                                  .toList() ??
                              <LatLng>[],
                          width: 5,
                          color: Colors.blue,
                        ),
                      },
                      markers: {
                        // Marcador do usuário
                        if (ctl.userPosition != null)
                          Marker(
                            markerId: const MarkerId("usuario"),
                            position: LatLng(
                                ctl.userPosition!.latitude,
                                ctl.userPosition!.longitude),
                          ),
                        // Marcador para o ônibus
                        Marker(
                          icon: ctl.busIcon,
                          markerId: const MarkerId('busMarker'),
                          position: LatLng(
                            ctl.bus.location?.first.x ?? 0,
                            ctl.bus.location?.first.y ?? 0,
                          ),
                        ),
                        // Marcadores para paragens
                        if (ctl.bus.paragem != null)
                          ...ctl.bus.paragem!.map(
                            (paragem) => Marker(
                              icon: ctl.paragemIcon,
                              markerId:
                                  MarkerId('paragem_${paragem.x}_${paragem.y}'),
                              position: LatLng(paragem.x, paragem.y),
                            ),
                          ).toSet(),

                        // Destaca a paragem mais próxima
                        if (ctl.nearestParagem != null)
                          Marker(
                            markerId: const MarkerId('paragem_mais_proxima'),
                            position: ctl.nearestParagem!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                            infoWindow: const InfoWindow(
                              title: 'Paragem Mais Próxima',
                            ),
                          ),
                      },
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Botão para encontrar a paragem mais próxima
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.place),
                      label: const Text('Paragem Mais Próxima'),
                      onPressed: () {
                        ctl.findNearestParagem(); // Chama o método para encontrar a paragem mais próxima
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

