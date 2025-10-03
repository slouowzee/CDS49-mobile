import 'package:flutter/material.dart';


class CategorieQuestion extends StatelessWidget {
  final String categorie;
  final int nombreQuestions;
  final VoidCallback onSelect;

  const CategorieQuestion({
    required this.categorie,
    required this.nombreQuestions,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  @override
   Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(categorie),
              subtitle: Text('$nombreQuestions questions'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child:  Text('Choisir $categorie'),
                  onPressed: () {
                    onSelect();
                  },
                ),
                const SizedBox(width: 8),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}