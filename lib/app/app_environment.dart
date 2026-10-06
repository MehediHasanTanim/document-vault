enum AppEnvironment { dev, test, prod }

abstract final class AppEnvironmentConfig {
  static AppEnvironment get current =>
      switch (const String.fromEnvironment('APP_ENV', defaultValue: 'dev')) {
        'prod' => AppEnvironment.prod,
        'test' => AppEnvironment.test,
        _ => AppEnvironment.dev,
      };
}
