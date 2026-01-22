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
  ],
  safelist: [
    'p-1.5',
    'p-2',
    'p-3',
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
