// privacy_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Aviso de Privacidad',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: theme.colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduMentor AI',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha de vigencia: 13 de noviembre de 2025',
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'En EduMentor AI, nos comprometemos a proteger sus datos personales. A continuación, presentamos un aviso de privacidad simplificado que explica cómo manejamos su información de acuerdo con la normativa mexicana de protección de datos.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _buildDefinitionSection(
                title: 'Definiciones clave',
                theme: theme,
                textTheme: textTheme,
                children: [
                  _buildDefinitionItem(
                    term: 'Dato personal',
                    definition: 'cualquier información concerniente a una persona física, que la identifique o que la haga identificable, expresados en forma numérica, alfabética, gráfica, fotográfica, acústica o en cualquier otro tipo. Por ejemplo: nombre, grado de estudios, domicilio, cédula profesional, correo electrónico, número de seguro social, número de tarjeta de crédito, entre otros.',
                  ),
                  _buildDefinitionItem(
                    term: 'Datos personales sensibles',
                    definition: 'son aquellos datos personales que afectan a la esfera más íntima de su titular, o cuya utilización indebida pueda dar origen a discriminación o conlleve un riesgo grave para él, como por ejemplo: su origen racial o étnico; estado de salud pasado, presente y futuro; información genética; creencias religiosas, filosóficas y morales; afiliación sindical; opiniones políticas; preferencia sexual, entre otros.',
                  ),
                  _buildDefinitionItem(
                    term: 'Responsable',
                    definition: 'es la persona física o moral de carácter privado que decide sobre el tratamiento de datos personales, por ejemplo, una institución educativa, asociación civil, banco, tienda departamental, tienda de autoservicio, un médico, un contador, entre otros. El responsable es el obligado a emitir el aviso de privacidad.',
                  ),
                  _buildDefinitionItem(
                    term: 'Titular',
                    definition: 'es la persona física a quien corresponden los datos personales, por ejemplo, el señor Alejandro Flores Castañeda, la señorita María Allende Paz o el niño Raúl Montes de Oca Maldonado.',
                  ),
                  _buildDefinitionItem(
                    term: 'Tratamiento',
                    definition: 'es la obtención, uso, divulgación o almacenamiento de datos personales por cualquier medio. El uso abarca cualquier acción de acceso, manejo, aprovechamiento, transferencia o disposición de datos personales.',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Protegemos sus datos personales recolectados a través de la app (como nombre, email, fecha de nacimiento, lugar donde vive y nombre de la escuela) para proporcionar servicios personalizados. No recolectamos datos sensibles y no compartimos su información con terceros sin su consentimiento, salvo obligaciones legales.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _buildDefinitionSection(
                title: 'Eliminación de Cuenta',
                theme: theme,
                textTheme: textTheme,
                children: [
                  Text(
                    'La eliminación de su cuenta será manual y se realizará únicamente cuando usted lo solicite expresamente. Sus datos se mantendrán seguros hasta ese momento. Para solicitar la eliminación, contacte a soporte@edumentor.ai o use el formulario en la sección de Ayuda.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Para ejercer sus derechos ARCO (Acceso, Rectificación, Cancelación, Oposición), envíe una solicitud a privacidad@edumentor.ai.',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefinitionSection({
    required String title,
    required ThemeData theme,
    required TextTheme textTheme,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionItem({required String term, required String definition}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            definition,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}