import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobil_cds49/models/score_response.dart';
import 'package:mobil_cds49/services/api/gestionScore/score_service.dart';

class HistoriqueScoreQcm extends StatefulWidget {
  const HistoriqueScoreQcm({Key? key}) : super(key: key);

  @override
  State<HistoriqueScoreQcm> createState() => _HistoriqueScoreQcmState();
}

class _HistoriqueScoreQcmState extends State<HistoriqueScoreQcm> {
  ScoreResponse? _scoreResponse;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ScoreService.getScores();
      setState(() {
        _scoreResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes scores'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : _scoreResponse == null || _scoreResponse!.scores.isEmpty
                  ? const Center(child: Text('Aucun score'))
                  : ListView.builder(
                      itemCount: _scoreResponse!.scores.length,
                      itemBuilder: (context, index) {
                        final score = _scoreResponse!.scores[index];
                        final date = DateFormat('dd/MM/yyyy').format(score.dateresultat);
                        
                        return ListTile(
                          title: Text('${score.score}/${score.nbquestions}'),
                          subtitle: Text(date),
                        );
                      },
                    ),
    );
  }
}
