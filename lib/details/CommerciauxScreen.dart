import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:emecexpo/model/app_theme_data.dart';
import 'package:emecexpo/model/commerciaux_model.dart';
import 'package:emecexpo/api_services/networking_api_service.dart';

class CommerciauxScreen extends StatefulWidget {
  final int exposantId;
  final String authToken;
  final AppThemeData theme;

  const CommerciauxScreen({Key? key, required this.exposantId, required this.authToken, required this.theme}) : super(key: key);

  @override
  _CommerciauxScreenState createState() => _CommerciauxScreenState();
}

class _CommerciauxScreenState extends State<CommerciauxScreen> {
  late Future<List<CommerciauxClass>> _commerciauxFuture;
  final NetworkingApiService _apiService = NetworkingApiService();

  @override
  void initState() {
    super.initState();
    _fetchCommerciaux();
  }

  void _fetchCommerciaux() {
    setState(() {
      _commerciauxFuture = _apiService.getCommerciaux(widget.authToken, widget.exposantId);
    });
  }

  Future<void> _handleBooking(Creneau slot) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: SpinKitCircle(color: Colors.white, size: 50)),
    );

    bool success = await _apiService.bookMeeting(widget.authToken, slot);

    if (!mounted) return;
    Navigator.pop(context); // Close Spinner

    if (success) {
      Navigator.pop(context); // Close BottomSheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ RDV réservé avec succès !"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
      );
      _fetchCommerciaux(); // Refresh list to grey out the button
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Échec de la réservation"), backgroundColor: Colors.red),
      );
    }
  }

  void _showCreneauxPicker(CommerciauxClass rep, AppThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Text("Planning de ${rep.fullName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: rep.availableCreneaux.length,
                  itemBuilder: (context, index) {
                    final slot = rep.availableCreneaux[index];
                    final bool isReserved = slot.isReserved == 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.access_time_filled, color: isReserved ? Colors.grey : theme.secondaryColor),
                        title: Text(slot.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${slot.debut} - ${slot.fin}"),
                        trailing: ElevatedButton(
                          onPressed: isReserved ? null : () => _handleBooking(slot),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.secondaryColor,
                            disabledBackgroundColor: Colors.grey.shade400, // Button turns grey when disabled
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(isReserved ? "Occupé" : "Réserver", style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: theme.primaryColor, iconTheme: const IconThemeData(color: Colors.white), title: const Text('Commerciaux', style: TextStyle(color: Colors.white))),
      body: FutureBuilder<List<CommerciauxClass>>(
        future: _commerciauxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: SpinKitThreeBounce(color: theme.secondaryColor, size: 30.0));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucun représentant trouvé"));
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final rep = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: rep.imagePath.isNotEmpty ? NetworkImage(rep.imagePath) : null, child: rep.imagePath.isEmpty ? const Icon(Icons.person) : null),
                  title: Text(rep.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(rep.email),
                  trailing: IconButton(icon: Icon(Icons.calendar_month, color: theme.secondaryColor), onPressed: () => _showCreneauxPicker(rep, theme)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}