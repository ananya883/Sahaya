import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FullscreenMap extends StatefulWidget {
  final LatLng? currentPosition;
  final List camps;

  const FullscreenMap({
    super.key,
    required this.currentPosition,
    required this.camps,
  });

  @override
  State<FullscreenMap> createState() => _FullscreenMapState();
}

class _FullscreenMapState extends State<FullscreenMap> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Center map on user location after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentPosition != null) {
        mapController.move(widget.currentPosition!, 15);
      }
    });
  }

  void _recenterMap() {
    if (widget.currentPosition != null) {
      mapController.move(widget.currentPosition!, 15);
    }
  }

  void _showCampDetails(Map<String, dynamic> camp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.green, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    camp['name'] ?? 'Camp',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (camp['location'] != null) ...[
              _detailRow(Icons.place, 'Location', camp['location']),
              const SizedBox(height: 8),
            ],
            if (camp['capacity'] != null) ...[
              _detailRow(Icons.people, 'Capacity', '${camp['capacity']} people'),
              const SizedBox(height: 8),
            ],
            if (camp['status'] != null) ...[
              _detailRow(
                Icons.info_outline,
                'Status',
                camp['status'],
                color: camp['status'] == 'active' ? Colors.green : Colors.orange,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color ?? Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Camp Locations'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: widget.currentPosition ?? const LatLng(11.8, 76.0),
              zoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              // User location marker
              if (widget.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.currentPosition!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              // Camp markers
              if (widget.camps.isNotEmpty)
                MarkerLayer(
                  markers: widget.camps.map((camp) {
                    final lat = camp['latitude'];
                    final lng = camp['longitude'];
                    if (lat == null || lng == null) return null;

                    return Marker(
                      point: LatLng(
                        lat is double ? lat : double.parse(lat.toString()),
                        lng is double ? lng : double.parse(lng.toString()),
                      ),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _showCampDetails(camp),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.location_city,
                              color: Colors.green,
                              size: 40,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                camp['name'] ?? 'Camp',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).whereType<Marker>().toList(),
                ),
            ],
          ),
          // Recenter button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: _recenterMap,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
