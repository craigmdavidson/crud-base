import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar"]

  toggle() {
    this.sidebarTarget.classList.toggle("-translate-x-full")
  }

  close(event) {
    if (!this.sidebarTarget.contains(event.target)) {
      this.sidebarTarget.classList.add("-translate-x-full")
    }
  }
}
