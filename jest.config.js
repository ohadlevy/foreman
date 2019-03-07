module.exports = {
  automock: true,
  verbose: true,
  testMatch: ['**/*.test.js'],
  testURL: 'http://localhost/',
  collectCoverage: true,
  collectCoverageFrom: [
    'webpack/**/*.js',
    '!webpack/**/bundle*',
    '!webpack/stories/**',
    '!webpack/**/*stories.js',
  ],
  coverageReporters: ['lcov'],
  unmockedModulePathPatterns: ['react', 'node_modules/'],
  moduleNameMapper: {
    '^.+\\.(png|gif|css|scss)$': 'identity-obj-proxy',
  },
  globals: {
    __testing__: true,
    URL_PREFIX: '/',
  },
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  moduleDirectories: ['node_modules', 'webpack', 'script'],
  setupFiles: [
    'raf/polyfill',
    'jest-prop-type-error',
    './webpack/test_setup.js',
  ],
};
