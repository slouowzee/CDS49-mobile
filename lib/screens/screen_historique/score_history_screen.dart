import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobil_cds49/models/score.dart';
import 'package:mobil_cds49/models/score_response.dart';
import 'package:mobil_cds49/services/api/gestionScore/score_service.dart';

class ScoreHistoryScreen extends StatefulWidget {
  const ScoreHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScoreHistoryScreen> createState() => _ScoreHistoryScreenState();
}

class _ScoreHistoryScreenState extends State<ScoreHistoryScreen> {
  ScoreResponse? _scoreResponse;
  bool _isLoading = true;
  String? _error;
  DateTimeRange? _selectedDateRange;

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
        dateDebut: _selectedDateRange?.start,
        dateFin: _selectedDateRange?.end,
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
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = DateTimeRange(
          start: DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0),
          end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
        );
      });
      _loadScores();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    _loadScores();
  }

  bool _isTop3(int idresultat) {
    if (_scoreResponse == null) return false;
    return _scoreResponse!.statistics.top3
        .any((score) => score.idresultat == idresultat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des scores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Filtrer par période',
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: 'Effacer le filtre',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
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
                  ? const Center(
                      child: Text('Aucun score enregistré'),
                    )
                  : Column(
                      children: [
                        // Carte des statistiques
                        _buildStatisticsCard(),
                        
                        // Filtre de période actif
                        if (_selectedDateRange != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.blue.shade50,
                            child: Row(
                              children: [
                                const Icon(Icons.filter_alt, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Du ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} '
                                  'au ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        
                        // Liste des scores
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadScores,
                            child: ListView.builder(
                              itemCount: _scoreResponse!.scores.length,
                              itemBuilder: (context, index) {
                                final score = _scoreResponse!.scores[index];
                                final isTop3 = _isTop3(score.idresultat);
                                return _buildScoreCard(score, isTop3);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStatisticsCard() {
    final stats = _scoreResponse!.statistics;
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Score moyen',
                  '${stats.moyenne.toStringAsFixed(1)}/40',
                  Icons.trending_up,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Total',
                  '${stats.total}',
                  Icons.assessment,
                  Colors.green,
                ),
                _buildStatItem(
                  'Meilleur',
                  stats.top3.isNotEmpty ? '${stats.top3.first.score}/40' : '-',
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildScoreCard(Score score, bool isTop3) {
    final percentage = score.percentage;
    final dateFormatted = DateFormat('dd/MM/yyyy à HH:mm').format(score.dateresultat);
    
    // Couleur selon le score
    Color scoreColor;
    if (percentage >= 90) {
      scoreColor = Colors.green;
    } else if (percentage >= 75) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isTop3 ? 8 : 2,
      color: isTop3 ? Colors.amber.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTop3
            ? BorderSide(color: Colors.amber.shade700, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                strokeWidth: 6,
              ),
            ),
            Text(
              '${score.score}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scoreColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              '${score.score}/${score.nbquestions}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scoreColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(color: scoreColor),
            ),
            if (isTop3) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormatted),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ],
        ),
        trailing: isTop3
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TOP 3',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
