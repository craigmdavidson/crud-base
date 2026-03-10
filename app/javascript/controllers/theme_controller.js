import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.applyTheme(this.currentTheme)
  }

  switch(event) {
    const theme = event.currentTarget.dataset.theme
    localStorage.setItem("theme", theme)
    this.applyTheme(theme)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
  }

  get currentTheme() {
    return localStorage.getItem("theme") ||
      (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
  }
}
