import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_lots/view_model.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppViewModel(),
      child: const MaterialApp(
        home: Scaffold(
          body: _Body(),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({super.key});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppViewModel>();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FormField(
                label: 'Широта',
                onSaved: (val) {
                  model.lat = double.parse(val!);
                },
                validator: (lat) {
                  if (!model.regExp.hasMatch(lat)) {
                    return 'Некорректная широта';
                  }
                },
              ),
              _FormField(
                label: 'Долгота',
                onSaved: (val) {
                  model.lon = double.parse(val!);
                },
                validator: (lon) {
                  if (!model.regExp.hasMatch(lon)) {
                    return 'Некорректная долгота';
                  }
                },
              ),
              _FormField(
                label: 'Приближение',
                onSaved: (val) {
                  model.z = int.parse(val!);
                },
                validator: (val) {
                  final zoom = int.parse(val);
                  if (zoom < 0 || zoom > 30) {
                    return 'Приближение должно быть в пределах от 0 до 30';
                  }
                },
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    model.loadTile().then(
                          (v) => showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(
                                      model.imageURL,
                                      errorBuilder: (error, data, st) {
                                        return const Text(
                                            'Произошла ошибка при загрузке данных');
                                      },
                                    ),
                                    Text('x - ${model.x}'),
                                    Text('y - ${model.y}'),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                  }
                },
                child: const Text('Отправить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String? Function(String) validator;
  final void Function(String?) onSaved;

  const _FormField({
    super.key,
    required this.label,
    required this.validator,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Поле должно быть заполнено';
        }
        return validator(val);
      },
      decoration: InputDecoration(label: Text(label)),
    );
  }
}
