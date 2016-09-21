'use strict';

var path = require('path');
var GlobalConfig = require('../config/webpack.common.config');

// must match config.webpack.dev_server.port
var devServerPort = 3808;

var config = {
  entry: {
    // Sources are expected to live in $app_root/webpack
    'bundle': './webpack/assets/javascripts/bundle.js'
  },

  output: {
    // Build assets directly in to public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.output_dir
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',

    filename: GlobalConfig.production ? '[name]-[chunkhash].js' : '[name].js'
  },

}

config = Object.assign(GlobalConfig, config);

if (config.production) {
  config.plugins.push(
    new webpack.NoErrorsPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false },
      sourceMap: false
    }),
    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') }
    }),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin()
  );
} else {
  config.devServer = {
    host: config.bindOn,
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  };
  // Source maps
  config.devtool = 'cheap-module-eval-source-map';
}

module.exports = config;
