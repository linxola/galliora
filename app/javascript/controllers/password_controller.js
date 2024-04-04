import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['visibilityIcon']

  switchVisibility(e) {
    const passwordField = e.srcElement.closest('.password-form').querySelector('input');

    if (passwordField.type === "password") {
      passwordField.type = "text";
      this.visibilityIconTarget.classList.remove('bi-eye');
      this.visibilityIconTarget.classList.add('bi-eye-slash');
    } else {
      passwordField.type = "password";
      this.visibilityIconTarget.classList.remove('bi-eye-slash');
      this.visibilityIconTarget.classList.add('bi-eye');
    }
  }
}
