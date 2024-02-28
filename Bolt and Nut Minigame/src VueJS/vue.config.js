module.exports = {
    publicPath: './',
    productionSourceMap: false, // Desabilitar Source Maps em produção

    configureWebpack:{
        performance: {
          hints: false
        },
        optimization: {
          splitChunks: {
            minSize: 10000,
            maxSize: 250000,
          }
        }
    },

    chainWebpack: config => {
      config.optimization
        .minimize(true)
        .splitChunks({
          chunks: 'all'
        });
  
      config.optimization.minimizer('terser').tap((args) => {
        args[0].terserOptions.compress.drop_console = true; // Remover console.logs
        return args;
      });
    }
}

