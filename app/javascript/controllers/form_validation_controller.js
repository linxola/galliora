import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  validateUsername() {
    const usernameField = document.querySelector('#username > input');
    const errorsDiv = document.querySelector('#username + .invalid-feedback');
    let isValid = true;

    this.#cleanErrors(usernameField, errorsDiv);

    if (usernameField.value && usernameField.value.length < 2) {
      this.#displayErrors(usernameField, errorsDiv, I18n.username.too_short);
      isValid = false;
    } else if (usernameField.value.length > 32) {
      this.#displayErrors(usernameField, errorsDiv, I18n.username.too_long);
      isValid = false;
    }
    if (!/^\w?$|^\w[\w.-]+$/.test(usernameField.value)) {
      this.#displayErrors(usernameField, errorsDiv, I18n.username.invalid);
      isValid = false;
    }

    return isValid;
  }

  validateEmail() {
    const emailField = document.querySelector('#email > input');
    const errorsDiv = document.querySelector('#email + .invalid-feedback');
    let isValid = true;

    this.#cleanErrors(emailField, errorsDiv)

    if (emailField.value && !/^[^@\s]+@[^@\s]+$/.test(emailField.value)) {
      this.#displayErrors(emailField, errorsDiv, I18n.email.invalid);
      isValid = false;
    }

    return isValid;
  }

  validatePassword() {
    const passwordField = document.querySelector('#password > input');
    const errorsDiv = document.querySelector('#password + .invalid-feedback');
    let isValid = true;

    this.#cleanErrors(passwordField, errorsDiv)

    if (passwordField.value && passwordField.value.length < 8) {
      this.#displayErrors(passwordField, errorsDiv, I18n.password.too_short);
      isValid = false;
    } else if (passwordField.value.length > 128) {
      this.#displayErrors(passwordField, errorsDiv, I18n.password.too_long);
      isValid = false;
    }

    return isValid;
  }

  submitRegistrationForm(event) {
    const validations = [this.validateUsername(), this.validateEmail(), this.validatePassword()];

    validations.forEach(validation => {
      if (!validation) { event.preventDefault(); }
    })
  }

  submitEmailForm(event) {
    if (!this.validateEmail()) { event.preventDefault(); }
  }

  submitPasswordForm(event) {
    if (!this.validatePassword()) { event.preventDefault(); }
  }

  #displayErrors(target, errorsDiv, errorText) {
    target.classList.add('is-invalid');
    errorsDiv.innerHTML += `<i class="bi bi-exclamation-circle"></i> ${errorText} <br>`;
  }

  #cleanErrors(target, errorsDiv) {
    target.classList.remove('is-invalid');
    errorsDiv.replaceChildren();
  }
}
