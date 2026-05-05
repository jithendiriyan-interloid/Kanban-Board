import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password-visibility"
export default class extends Controller {
  static targets = ["input", "showIcon", "hideIcon"];

  toggle() {
    const isHidden = this.inputTarget.type === "password";

    this.inputTarget.type = isHidden ? "text" : "password";

    this.showIconTarget.classList.toggle("hidden", isHidden);
    this.hideIconTarget.classList.toggle("hidden", !isHidden);
  }
}
