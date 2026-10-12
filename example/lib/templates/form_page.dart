import 'package:flutter/material.dart';
import 'package:platform_design_system/platform_design_system.dart';

/// Template: Cadastro. Sections in cards, two columns, inline validation,
/// actions pinned at the bottom with the primary action last.
class FormPage extends StatefulWidget {
  const FormPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _saving = false;
  bool _submitted = false;
  DateTime? _birthDate;

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Preencha este campo.' : null;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _saving = false);
    DsToast.success(context, 'Pessoa cadastrada.');
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return DsPage(
      maxWidth: DsSizes.formMaxWidth,
      header: DsPageHeader(
        title: 'Nova pessoa',
        onBack: widget.onDone,
        breadcrumbs: <DsBreadcrumbItem>[
          const DsBreadcrumbItem('Cadastros'),
          DsBreadcrumbItem('Pessoas', onTap: widget.onDone),
          const DsBreadcrumbItem('Nova pessoa'),
        ],
      ),
      footer: DsFormActions(
        onSubmit: _submit,
        onCancel: widget.onDone,
        loading: _saving,
      ),
      child: Form(
        key: _form,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DsSectionCard(
              title: 'Identificação',
              child: DsFormGrid(
                children: <Widget>[
                  DsFormFull(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: DsFieldLabel('Nome completo', required: true),
                      ),
                      validator: _required,
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: DsFieldLabel('CPF', required: true),
                      hintText: '000.000.000-00',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _required,
                  ),
                  DsDateField(
                    label: 'Data de nascimento',
                    value: _birthDate,
                    lastDate: DateTime.now(),
                    onChanged: (DateTime? value) =>
                        setState(() => _birthDate = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DsSpacing.s24),
            DsSectionCard(
              title: 'Contato',
              description: 'Usado para lembretes de cobrança.',
              child: DsFormGrid(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      label: DsFieldLabel('Telefone', required: true),
                      hintText: '(00) 00000-0000',
                    ),
                    validator: _required,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: DsFieldLabel('E-mail'),
                      helperText: 'Opcional.',
                    ),
                  ),
                  DsFormFull(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: DsFieldLabel('Observações'),
                        alignLabelWithHint: true,
                      ),
                      minLines: 3,
                      maxLines: 6,
                    ),
                  ),
                  const DsFormFull(
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Código interno',
                        hintText: 'Gerado ao salvar',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
