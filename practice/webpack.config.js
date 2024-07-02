const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const HTMLWebpackPlugin = require('html-webpack-plugin');
const {CleanWebpackPlugin} = require('clean-webpack-plugin');
const YAML = require('yaml');
const fs = require('fs');

require('dotenv').config()

process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0

const config = YAML.parse(fs.readFileSync('./config.yaml', 'utf8'));

module.exports = (env, argv) => {
    let isDevelopment = (process.env.NODE_ENV = argv['mode']) !== 'production'

    return {
        entry: './app/index.tsx',

        mode: isDevelopment ? 'development' : 'production',

        output: {
            path: path.resolve(__dirname, 'public'),
            filename: '[contenthash].[name].js',
            publicPath: config.s3.public_s3_name,
        },

        resolve: {
            modules: ['node_modules', 'backend'],
            // Add '.ts' and '.tsx' as resolvable extensions.
            extensions: ['.js', '.ts', '.tsx', ".js", ".scss"]
        },

        module: {
            rules: [
                {
                    test: /\.ts(x?)$/,
                    use: [
                        {loader: 'ts-loader'}
                    ],
                    exclude: /node_modules|backend/
                },
                // All output '.js' files will have any sourcemaps re-processed by 'source-map-loader'.
                {
                    enforce: 'pre',
                    test: /\.js$/,
                    loader: 'source-map-loader',
                },
                // The following loader rules are necessary for s/css modules
                {
                    test: /\.module\.s(a|c)ss$/,
                    use: [
                        {loader: isDevelopment ? 'style-loader' : MiniCssExtractPlugin.loader},
                        {
                            loader: 'css-loader',
                            // As of css-loader 4, the options have changed
                            // https://github.com/webpack-contrib/css-loader
                            options: {
                                modules: {
                                    localIdentName: '[folder]__[local]__[hash:base64:5]',
                                    exportLocalsConvention: 'camelCase'
                                }
                            }
                        },
                        {loader: 'sass-loader'}
                    ]
                },
                {
                    test: /\.(sass|less|css)$/,
                    use: ['style-loader', 'css-loader']
                },
                {
                    test: /\.scss$/,
                    exclude: /\.module.(s(a|c)ss)$/,
                    use: [
                        isDevelopment ? 'style-loader' : MiniCssExtractPlugin.loader,
                        'css-loader',
                        'sass-loader'
                    ]
                },
                {
                    test: /\.(png|jpe?g|gif|svg)$/,
                    use: [
                        {
                            loader: 'url-loader',
                            options: {
                                fallback: 'file-loader'
                            }
                        }
                    ]
                }
            ]
        },

        plugins: [
            new CleanWebpackPlugin(),
            new MiniCssExtractPlugin({
                // Options similar to the same options in webpackOptions.output
                // both options are optional
                filename: '[name].[contenthash].css'
            }),
            new HTMLWebpackPlugin({
                template: path.join(__dirname, './app/index.html')
            })
        ],
    }
}
