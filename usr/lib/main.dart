import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event QR Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const EventQRScreen(),
      },
    );
  }
}

class EventQRScreen extends StatefulWidget {
  const EventQRScreen({super.key});

  @override
  State<EventQRScreen> createState() => _EventQRScreenState();
}

class _EventQRScreenState extends State<EventQRScreen> {
  // Controllers for input fields
  final TextEditingController _emailController = TextEditingController(text: 'yourname@gmail.com');
  final TextEditingController _eventNameController = TextEditingController(text: 'Annual Gala 2024');
  final TextEditingController _dateController = TextEditingController(text: 'December 31, 2024');
  final TextEditingController _timeController = TextEditingController(text: '7:00 PM');
  final TextEditingController _venueController = TextEditingController(text: 'Grand Ballroom, City Hotel');
  final TextEditingController _rsvpController = TextEditingController(text: 'Please RSVP by Dec 20');

  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _updateQRData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _eventNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _venueController.dispose();
    _rsvpController.dispose();
    super.dispose();
  }

  void _updateQRData() {
    // Construct the mailto link
    // Format: mailto:email?subject=...&body=...
    
    final email = _emailController.text.trim();
    final subject = 'Event Invitation: ${_eventNameController.text}';
    
    final body = '''
You are cordially invited to:
${_eventNameController.text}

Date: ${_dateController.text}
Time: ${_timeController.text}
Venue: ${_venueController.text}

${_rsvpController.text}
''';

    // Encode components to ensure special characters work in the URL
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    setState(() {
      _qrData = uri.toString();
    });
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Invitation QR'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Code Display Area
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan to RSVP via Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Customize Invitation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Input Fields
            _buildTextField('Recipient Email', _emailController, icon: Icons.email),
            const SizedBox(height: 12),
            _buildTextField('Event Name', _eventNameController, icon: Icons.event),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Date', _dateController, icon: Icons.calendar_today)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Time', _timeController, icon: Icons.access_time)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField('Venue', _venueController, icon: Icons.location_on),
            const SizedBox(height: 12),
            _buildTextField('RSVP Note', _rsvpController, icon: Icons.note),
            
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _updateQRData,
              icon: const Icon(Icons.refresh),
              label: const Text('Update QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon}) {
    return TextField(
      controller: controller,
      onChanged: (_) => _updateQRData(), // Live updates
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
