import 'package:flutter/material.dart';

class AppBarPrincipal extends StatefulWidget implements PreferredSizeWidget {
  /// Custom AppBar 
  final List<Widget> actions;
  const AppBarPrincipal({super.key, this.actions = const []});
  @override

  State<AppBarPrincipal> createState() => _AppBarPrincipalState();
  @override
  // Gestion de la taille préférée de l'AppBar
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarPrincipalState extends State<AppBarPrincipal> {
  // Méthode de construction de l'AppBar
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: Image.asset('assets/images/logo_cds49_transparent.png', width: 50, height: 50, fit: BoxFit.cover),
      actions: <Widget>[        
        ...widget.actions,
      ],
    );
  }
}