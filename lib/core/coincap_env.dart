class CoinCapEnv {
  static const baseUrl = String.fromEnvironment(
    'COINCAP_BASE_URL',
    defaultValue: 'https://rest.coincap.io/v3', 
  );

  static const apiKey = String.fromEnvironment(
    'COINCAP_API_KEY',

    defaultValue: '5fe9bf362a8a0b9ebc653de287919aba81a3a7b667ffad4b2073cc7e9a903b6b',
  );

  static const wsUrl = String.fromEnvironment(
    'COINCAP_WS_URL',
    defaultValue: 'wss://wss.coincap.io',
  );
}

