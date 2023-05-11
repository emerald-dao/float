const autoprefixer = require('autoprefixer');
const cssnano = require('cssnano');

const config = {
	plugins: [autoprefixer, cssnano]
};

module.exports = config;
