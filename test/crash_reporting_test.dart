import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/controllers/goal_controller.dart';
import 'package:goal_tracker/observability/crash_reporting.dart';
import 'package:goal_tracker/screens/profile_screen.dart';
import 'package:goal_tracker/services/goal_store.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('crashReportingEnabled', () {
    test('is off without a DSN', () {
      expect(crashReportingEnabled(''), isFalse);
      expect(crashReportingEnabled('   '), isFalse);
    });

    test('is on with a DSN', () {
      expect(crashReportingEnabled('https://key@example.invalid/1'), isTrue);
    });
  });

  group('configureCrashReporting', () {
    test('sends errors only, with no default PII and no tracing', () {
      final options = SentryFlutterOptions();
      configureCrashReporting(options, dsn: 'https://key@example.invalid/1');

      expect(options.dsn, 'https://key@example.invalid/1');
      expect(options.sendDefaultPii, isFalse);
      expect(options.tracesSampleRate, isNull);
      expect(options.tracesSampler, isNull);
      expect(options.attachScreenshot, isFalse);
      // ignore: experimental_member_use
      expect(options.attachViewHierarchy, isFalse);
      expect(options.beforeSend, isNotNull);
      expect(options.beforeBreadcrumb, isNotNull);
    });

    test('drops every breadcrumb before it is recorded', () {
      final options = SentryFlutterOptions();
      configureCrashReporting(options, dsn: 'https://key@example.invalid/1');

      final kept = options.beforeBreadcrumb!(
        Breadcrumb(message: 'Opened goal "Run a marathon"'),
        Hint(),
      );
      expect(kept, isNull);
    });
  });

  group('scrubEvent', () {
    SentryEvent eventWithPersonalData() => SentryEvent(
          message: SentryMessage('Could not save goals'),
          user: SentryUser(id: 'u-1', email: 'me@example.com'),
          request: SentryRequest(url: 'https://example.com/?goal=marathon'),
          breadcrumbs: [Breadcrumb(message: 'typed "Run a marathon"')],
          // ignore: deprecated_member_use
          extra: {'goalTitle': 'Run a marathon'},
          serverName: 'device-name',
          exceptions: [
            SentryException(
              type: 'FormatException',
              value: 'Unexpected character in [{"title":"Run a marathon"}]',
            ),
          ],
        );

    test('strips user, request, breadcrumbs, extra and server name', () {
      final scrubbed = scrubEvent(eventWithPersonalData(), Hint())!;

      expect(scrubbed.user, isNull);
      expect(scrubbed.request, isNull);
      expect(scrubbed.breadcrumbs, anyOf(isNull, isEmpty));
      // ignore: deprecated_member_use
      expect(scrubbed.extra, anyOf(isNull, isEmpty));
      expect(scrubbed.serverName, isNull);
    });

    test(
        'keeps the exception type but drops its value, which can quote '
        'stored goals', () {
      final scrubbed = scrubEvent(eventWithPersonalData(), Hint())!;

      expect(scrubbed.exceptions, hasLength(1));
      expect(scrubbed.exceptions!.single.type, 'FormatException');
      expect(scrubbed.exceptions!.single.value, isNull);
      expect(scrubbed.message?.formatted, 'Could not save goals');
    });
  });

  group('Settings privacy copy', () {
    Future<void> pumpSettings(WidgetTester tester,
        {required bool enabled}) async {
      final controller = GoalController(MemoryGoalStore());
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(
        home: ProfileScreen(controller: controller, crashReporting: enabled),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('promises nothing leaves the device when reporting is off',
        (tester) async {
      await pumpSettings(tester, enabled: false);
      expect(find.textContaining('There is no account, advertising, analytics'),
          findsOneWidget);
      expect(find.textContaining('crash report'), findsNothing);
    });

    testWidgets('discloses crash reports when they are on', (tester) async {
      await pumpSettings(tester, enabled: true);
      expect(find.textContaining('sends a crash report to Sentry'),
          findsOneWidget);
      expect(find.textContaining('never your goals'), findsOneWidget);
    });
  });
}
