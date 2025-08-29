import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/config/app_config.dart';

class SupabaseConnectionTest extends StatefulWidget {
  const SupabaseConnectionTest({super.key});

  @override
  State<SupabaseConnectionTest> createState() => _SupabaseConnectionTestState();
}

class _SupabaseConnectionTestState extends State<SupabaseConnectionTest> {
  bool _isConnected = false;
  bool _isLoading = false;
  String _status = 'Not tested';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
      _error = '';
    });

    try {
      // Test configuration
      if (!AppConfig.isValidSupabaseConfig) {
        throw Exception(
            'Invalid Supabase configuration. Please check your .env file.');
      }

      // Test basic connection
      final response = await Supabase.instance.client
          .from('users')
          .select('count')
          .count(CountOption.exact);

      setState(() {
        _isConnected = true;
        _status =
            'Connected successfully! Found ${response.count} users in database.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _status = 'Connection failed';
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: _isConnected ? Colors.green : Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Supabase URL',
                      AppConfig.supabaseUrl,
                      AppConfig.supabaseUrl.contains('demo.supabase.co')
                          ? 'Demo'
                          : 'Real',
                    ),
                    _buildStatusRow(
                      'Anon Key',
                      '${AppConfig.supabaseAnonKey.substring(0, 20)}...',
                      AppConfig.supabaseAnonKey == 'demo-key' ? 'Demo' : 'Real',
                    ),
                    _buildStatusRow(
                      'Configuration Valid',
                      AppConfig.isValidSupabaseConfig.toString(),
                      AppConfig.isValidSupabaseConfig ? 'Valid' : 'Invalid',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Test',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Testing connection...'),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isConnected ? Icons.check_circle : Icons.error,
                                color: _isConnected ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_status)),
                            ],
                          ),
                          if (_error.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Error: $_error',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testConnection,
                      child: const Text('Test Again'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!AppConfig.isValidSupabaseConfig)
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Required',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Create a Supabase project at https://supabase.com\n'
                        '2. Run the database schema from supabase_schema.sql\n'
                        '3. Update the .env file with your real credentials:\n'
                        '   - SUPABASE_URL\n'
                        '   - SUPABASE_ANON_KEY\n'
                        '4. Restart the app',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, String status) {
    final isValid = status == 'Real' || status == 'Valid';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isValid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
