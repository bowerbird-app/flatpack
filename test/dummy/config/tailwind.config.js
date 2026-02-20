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
  safelist: [
    'hover:bg-[var(--color-muted)]',
    'hover:border-[var(--color-primary)]',
    '-space-x-1',
    '-space-x-2',
    '-space-x-3',
    'bg-white',
    'text-black',
    'border',
    'border-black/20',
    'bg-green-700',
    'dark:bg-green-600',
    'bg-red-500',
    'dark:bg-red-400',
    'bg-red-700',
    'dark:bg-red-600',
    'text-white',
    'dark:text-white',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      boxShadow: {
        'sm': 'var(--shadow-sm)',
        'md': 'var(--shadow-md)',
        'lg': 'var(--shadow-lg)',
      },
    },
  },
  plugins: []
}
