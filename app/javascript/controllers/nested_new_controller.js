import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "frame", "select"]
  static values = { url: String }

  open() {
    this.frameTarget.src = this.urlValue
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  dialogClosed() {
    this.frameTarget.removeAttribute("src")
    this.frameTarget.innerHTML = ""
  }

  handleFrameLoad() {
    const success = this.frameTarget.querySelector("[data-created-id]")
    if (success) {
      const option = new Option(success.dataset.createdDisplay, success.dataset.createdId, true, true)
      this.selectTarget.add(option)
      this.selectTarget.value = success.dataset.createdId
      this.close()
    }
  }
}
