import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.element.style.transition = "opacity 0.5s ease, transform 0.5s ease"
      this.element.style.opacity = "0"
      this.element.style.transform = "translateY(-1rem)"
      this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
    }, 2500)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
