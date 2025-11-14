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
  DateTime? _dateDebut;
  DateTime? _dateFin;

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
      final response = await ScoreService.getScores(
        dateDebut: _dateDebut,
        dateFin: _dateFin,
      );
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateDebut != null && _dateFin != null
          ? DateTimeRange(start: _dateDebut!, end: _dateFin!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _dateDebut = picked.start;
        _dateFin = picked.end;
      });
      _loadScores();
    }
  }

  void _clearFilter() {
    setState(() {
      _dateDebut = null;
      _dateFin = null;
    });
    _loadScores();
  }

  bool _isTop3(int idresultat) {
    if (_scoreResponse == null) return false;
    return _scoreResponse!.statistics.top3
        .any((topScore) => topScore.idresultat == idresultat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes scores'),
        actions: [
          if (_dateDebut != null && _dateFin != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
              tooltip: 'Effacer le filtre',
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Filtrer par période',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Erreur: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadScores,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _scoreResponse == null || _scoreResponse!.scores.isEmpty
                  ? const Center(child: Text('Aucun score'))
                  : Column(
                      children: [
                        // RÈGLE 3: Afficher le score moyen sur 40 points
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.blue.shade50,
                          child: Column(
                            children: [
                              const Text(
                                'Score moyen',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_scoreResponse!.statistics.moyenne.toStringAsFixed(1)}/40',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                '${_scoreResponse!.statistics.total} test${_scoreResponse!.statistics.total > 1 ? "s" : ""} réalisé${_scoreResponse!.statistics.total > 1 ? "s" : ""}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Afficher le filtre actif
                        if (_dateDebut != null && _dateFin != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: Colors.amber.shade50,
                            child: Row(
                              children: [
                                const Icon(Icons.filter_alt, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Du ${DateFormat('dd/MM/yyyy').format(_dateDebut!)} au ${DateFormat('dd/MM/yyyy').format(_dateFin!)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // RÈGLE 1 & 2: Liste des scores avec date et heure
                        Expanded(
                          child: ListView.builder(
                            itemCount: _scoreResponse!.scores.length,
                            itemBuilder: (context, index) {
                              final score = _scoreResponse!.scores[index];
                              final isTop = _isTop3(score.idresultat);
                              
                              // RÈGLE 2: Afficher date ET heure
                              final dateTime = DateFormat('dd/MM/yyyy à HH:mm')
                                  .format(score.dateresultat);
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                // RÈGLE 4: Mettre en valeur les top 3
                                color: isTop ? Colors.amber.shade50 : null,
                                child: ListTile(
                                  leading: isTop
                                      ? Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber.shade700,
                                          size: 32,
                                        )
                                      : Icon(
                                          Icons.quiz,
                                          color: Colors.grey.shade600,
                                        ),
                                  title: Row(
                                    children: [
                                      Text(
                                        '${score.score}/${score.nbquestions}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isTop
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${score.scoreSur40.toStringAsFixed(1)}/40)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(dateTime),
                                  trailing: isTop
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade700,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'TOP 3',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
