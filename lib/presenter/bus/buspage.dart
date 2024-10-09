import 'package:cobradortpb/presenter/bus/buscontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Buspage extends StatelessWidget {
  static const router = '/buspage';
  const Buspage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Pages'),
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
                  // Exibe a primeira localização (latitude)
                  Text("Latitude: ${ctl.bus.location?.first.x ?? 'N/A'}"),
                  // Exibe a direção do ônibus
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ctl.bus.direction == 1
                        ? const Text('Saindo da baixa para o destino')
                        : ctl.bus.direction == 2
                            ? const Text('Voltando à baixa')
                            : const Text('Parado no terminal'),
                  ),
                  // Exibe o registro do ônibus
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Bus: ${ctl.bus.registration}'),
                  ),
                  // Exibe as localizações
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                        'Localizações: ${ctl.bus.location?.map((loc) => "(${loc.x}, ${loc.y})").join(", ") ?? 'Sem localizações'}'),
                  ),
                  // Botão para encerrar ou atualizar a localização
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        ctl.updateBusLocation();
                      },
                      child: const Text("Encerrar"),
                    ),
                  ),
                  // Google Map widget
                  Container(
                    height: 300, // Defina a altura conforme necessário
                    margin: const EdgeInsets.all(16.0),
                    child: GoogleMap(
                      initialCameraPosition: ctl.kGooglePlex,
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('baixa-Munhava'),
                          points: ctl.bus.paragem
                                  ?.map((loc) => LatLng(loc.x, loc.y))
                                  .toList() ?? <LatLng>[], // Converte a lista de localizações para LatLng
                          width: 5,
                          color: Colors.blue,
                        )
                      },
                      markers: {
                        // Marcador para o ônibus
                        Marker(
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                          markerId: const MarkerId('busMarker'),
                          position: LatLng(
                            ctl.bus.location?.first.x ?? 0,
                            ctl.bus.location?.first.y ?? 0,
                          ),
                        ),
                        // Marcadores para paragens
                        if (ctl.bus.paragem != null) 
                          ...ctl.bus.paragem!.map((paragem) => Marker(
                           
                            markerId: MarkerId('paragem_${paragem.x}_${paragem.y}'),
                            position: LatLng(paragem.x, paragem.y),
                          )).toSet(),
                      },
                      // Adicione outras propriedades necessárias
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
