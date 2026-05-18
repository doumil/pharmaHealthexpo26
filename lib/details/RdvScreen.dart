// lib/details/RdvScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:emecexpo/model/app_theme_data.dart';
import 'package:emecexpo/model/rdv_model.dart';
import 'package:emecexpo/api_services/networking_api_service.dart';

class RdvScreen extends StatefulWidget {
  final String authToken;
  final AppThemeData theme;

  const RdvScreen({
    Key? key,
    required this.authToken,
    required this.theme,
  }) : super(key: key);

  @override
  _RdvScreenState createState() => _RdvScreenState();
}

class _RdvScreenState extends State<RdvScreen> {
  late Future<List<RdvClass>> _rdvFuture;
  final NetworkingApiService _apiService = NetworkingApiService();

  @override
  void initState() {
    super.initState();
    _fetchRdv();
  }

  void _fetchRdv() {
    setState(() {
      //_rdvFuture = _apiService.getMyRdv(widget.authToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'My Appointments (RDV)',
          style: TextStyle(color: theme.whiteColor),
        ),
      ),
      body: FutureBuilder<List<RdvClass>>(
        future: _rdvFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitThreeBounce(
                color: theme.secondaryColor,
                size: 30.0,
              ),
            );
          } else if (snapshot.hasError) {
            final String errorMessage = snapshot.error.toString().replaceFirst('Exception: ', '');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: theme.redColor, size: 50),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Failed to load appointments: \n$errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.blackColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _fetchRdv,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondaryColor,
                    ),
                    child: Text('Retry', style: TextStyle(color: theme.whiteColor)),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined, color: Colors.grey, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'You have no scheduled appointments.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final appointments = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return _buildRdvCard(appointments[index], theme);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildRdvCard(RdvClass rdv, AppThemeData theme) {
    Color statusColor;
    String statusText;

    switch (rdv.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'cancelled':
        statusColor = theme.redColor;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      color: theme.whiteColor,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: ClipOval(
          child: rdv.commercialImage.isNotEmpty
              ? Image.network(
            rdv.commercialImage,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: Colors.grey, size: 50),
          )
              : Icon(Icons.person, color: Colors.grey, size: 50),
        ),
        title: Text(
          'Meeting with ${rdv.commercialName}',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${rdv.rdvDate}', style: TextStyle(color: theme.blackColor)),
            Text('Time: ${rdv.rdvTime}', style: TextStyle(color: theme.blackColor)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // Optional: Navigate to a detailed RDV view
          print('View details for RDV ID: ${rdv.id}');
        },
      ),
    );
  }
}