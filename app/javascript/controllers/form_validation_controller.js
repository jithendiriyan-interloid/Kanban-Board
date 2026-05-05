import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  validateForm(event) {
    let firstInvalidInput = null

    this.inputTargets.forEach((input) => {
      const valid = this.validateInput(input)

      if (!valid && !firstInvalidInput) {
        firstInvalidInput = input
      }
    })

    if (firstInvalidInput) {
      event.preventDefault()
      firstInvalidInput.focus()
    }
  }

  validateField(event) {
    this.validateInput(event.target)
  }

  handleInput(event) {
    const input = event.target

    if (input.dataset.touched === "true") {
      this.validateInput(input)
    } else {
      this.clearError(input)
    }

    this.revalidateMatchingInputs(input)
  }

  validateInput(input) {
    input.dataset.touched = "true"

    const value = input.value
    const normalizedValue = input.dataset.validationType === "email" ? value.trim() : value
    const label = input.dataset.validationLabel || "This field"

    if (input.dataset.validationRequired === "true" && normalizedValue === "") {
      return this.showError(input, `${label} is required.`)
    }

    if (normalizedValue === "") {
      this.clearError(input)
      return true
    }

    if (input.dataset.validationType === "email" && !this.isValidEmail(normalizedValue)) {
      return this.showError(input, "Enter a valid email address.")
    }

    const minLength = Number.parseInt(input.dataset.validationMinLength || "", 10)
    if (Number.isInteger(minLength) && value.length < minLength) {
      return this.showError(input, `${label} must be at least ${minLength} characters.`)
    }

    if (input.dataset.validationSpecialCharacter === "true" && !/[!@#$%^&*(),.?":{}|<>]/.test(value)) {
      return this.showError(input, `${label} must include at least one special character.`)
    }

    if (input.dataset.validationMatch) {
      const matchInput = this.element.querySelector(input.dataset.validationMatch)

      if (matchInput && value !== matchInput.value) {
        return this.showError(input, `${label} does not match.`)
      }
    }

    this.clearError(input)
    return true
  }

  showError(input, message) {
    const errorElement = this.errorElementFor(input)

    input.setAttribute("aria-invalid", "true")
    input.classList.remove("border-gray-300")
    input.classList.add("border-red-400")

    if (errorElement) {
      errorElement.textContent = message
      errorElement.classList.remove("hidden")
    }

    return false
  }

  clearError(input) {
    const errorElement = this.errorElementFor(input)

    input.removeAttribute("aria-invalid")
    input.classList.remove("border-red-400")
    input.classList.add("border-gray-300")

    if (errorElement) {
      errorElement.textContent = ""
      errorElement.classList.add("hidden")
    }
  }

  errorElementFor(input) {
    if (!input.dataset.validationErrorId) return null

    return document.getElementById(input.dataset.validationErrorId)
  }

  revalidateMatchingInputs(changedInput) {
    const selector = `input[data-validation-match="#${changedInput.id}"]`

    this.element.querySelectorAll(selector).forEach((input) => {
      if (input.dataset.touched === "true") {
        this.validateInput(input)
      }
    })
  }

  isValidEmail(value) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
  }
}
