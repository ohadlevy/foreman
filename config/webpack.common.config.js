'use strict';

require('es6-promise').polyfill(); // needed for compatibility with older node versions

var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

// set TARGETNODE_ENV=production on the environment to add asset fingerprints
var production = process.env.RAILS_ENV === 'production' || process.env.NODE_ENV === 'production';
var bindOn = process.env.BIND || '127.0.0.1';

var config = {
  production: production,
  bindOn: bindOn,
  resolve: {
    extensions: ['', '.js'],
    root: path.join(__dirname, '..', 'webpack')
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader'
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css-loader')
      },
      {
        test: /(\.png|\.gif)$/,
        loader: 'url-loader?limit=32767'
      }
    ]
  },

  plugins: [
    // must match config.webpack.manifest_filename
    new StatsPlugin('manifest.json', {
      // We only need assetsByChunkName
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery'
    }),
    new ExtractTextPlugin(production ? '[name]-[chunkhash].css' : '[name].css', {
            allChunks: true
    })
  ]
};

module.exports = config;
