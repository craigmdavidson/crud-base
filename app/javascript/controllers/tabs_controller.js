import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn", "panel"]

  connect() {
    const tab = new URLSearchParams(window.location.search).get("tab") || window.location.hash.slice(1)
    if (tab) {
      const panel = this.panelTargets.find(p => p.id === `tab-${tab}`)
      if (panel) {
        const index = this.panelTargets.indexOf(panel)
        this.select(index)
        return
      }
    }
    this.select(0)
  }

  switch(event) {
    const index = this.btnTargets.indexOf(event.currentTarget)
    this.select(index)
    const panelId = this.panelTargets[index]?.id?.replace("tab-", "")
    if (panelId) {
      history.replaceState(null, "", `#${panelId}`)
    }
  }

  select(index) {
    this.btnTargets.forEach((btn, i) => {
      if (i === index) {
        btn.classList.add("border-base-content", "text-base-content")
        btn.classList.remove("border-transparent", "text-base-content/60")
      } else {
        btn.classList.remove("border-base-content", "text-base-content")
        btn.classList.add("border-transparent", "text-base-content/60")
      }
    })
    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })
  }
}
