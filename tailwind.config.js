module.exports = {
  content: [
    "./*.html",
    "./_posts/**/*.md",
    "./_layouts/*.html",
    "./_includes/*.html",
  ],
  darkMode: 'class',
  theme: {
    extend: {},
  },
  plugins: [require('@tailwindcss/typography'), require('@tailwindcss/line-clamp')],
}
