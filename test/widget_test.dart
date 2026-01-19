import 'package:flutter_test/flutter_test.dart';
import 'package:sgt_projeto/main.dart';

void main() {
  testWidgets('Verificação de carregamento inicial', (
    WidgetTester tester,
  ) async {
    // Alterado de MyApp() para SGTApp() para coincidir com o nosso código
    await tester.pumpWidget(const SGTApp());

    // Verifica se a aplicação inicia corretamente
    expect(find.byType(SGTApp), findsOneWidget);
  });
}
