const defaultTheme = require('tailwindcss/defaultTheme')
const path = require('path')

const engineRoot = path.resolve(__dirname, '../../..')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{erb,haml,html,slim,rb}',
    `${engineRoot}/app/components/**/*.{erb,haml,html,slim,rb}`,
    `${engineRoot}/app/assets/stylesheets/**/*.css`,
    `${engineRoot}/app/javascript/**/*.js`,
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: []
}
