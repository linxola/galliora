import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { siteKey: String }

  initialize() {
    grecaptcha.render("recaptcha_v2", { sitekey: this.siteKeyValue } )
  }
}
