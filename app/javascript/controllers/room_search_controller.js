
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "results", "count", "status"]

  connect() {
    this.timer = null
    this.request = null
    this.search()
  }

  disconnect() {
    clearTimeout(this.timer)
    this.request?.abort()
  }

  schedule() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.search(), 300)
  }

  submit(event) {
    event.preventDefault()
    clearTimeout(this.timer)
    this.search()
  }

  async search() {
    this.request?.abort()
    this.request = new AbortController()

    const params = new URLSearchParams()

    for (const [key, value] of new FormData(this.formTarget)) {
      if (value.toString().trim() !== "") {
        params.append(key, value)
      }
    }

    const query = params.toString()
    const url = `/api/v1/listings${query ? `?${query}` : ""}`

    this.statusTarget.textContent = "Searching rooms..."

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "application/json"
        },
        signal: this.request.signal
      })

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`)
      }

      const result = await response.json()
      const listings = result.data

      this.resultsTarget.replaceChildren()

      this.countTarget.textContent =
        `${listings.length} ${listings.length === 1 ? "room" : "rooms"}`

      if (listings.length === 0) {
        const message = document.createElement("div")
        message.className = "col-12"

        const alert = document.createElement("div")
        alert.className = "alert alert-info"
        alert.textContent = "No rooms match your filters."

        message.appendChild(alert)
        this.resultsTarget.appendChild(message)
      } else {
        listings.forEach(listing => this.renderCard(listing))
      }

      this.statusTarget.textContent = ""

    } catch (error) {
      if (error.name === "AbortError") return

      this.statusTarget.textContent =
        "Could not load rooms. Please try again."

      console.error("Room search failed:", error)
    }
  }

  renderCard(listing) {
    const column = document.createElement("div")
    column.className = "col"

    const card = document.createElement("div")
    card.className = "card h-100 shadow-sm"

    const body = document.createElement("div")
    body.className = "card-body d-flex flex-column"

    const title = document.createElement("h2")
    title.className = "h5 card-title"
    title.textContent =
      `Room in ${listing.property.neighborhood.name}`

    const propertyType = document.createElement("p")
    propertyType.className = "text-muted"
    propertyType.textContent =
      `Property type: ${listing.property.type}`

    const price = document.createElement("p")
    price.className = "fs-4 fw-bold text-primary"

    price.textContent = new Intl.NumberFormat("es-CL", {
      style: "currency",
      currency: "CLP",
      maximumFractionDigits: 0
    }).format(Number(listing.monthly_rent))

    const features = document.createElement("p")
    features.className = "small text-muted"

    features.textContent = [
      listing.furnished ? "Furnished" : "Unfurnished",
      listing.private_bathroom
        ? "Private bathroom"
        : "Shared bathroom"
    ].join(" · ")

    const availability = document.createElement("p")
    availability.className = "small"

    availability.textContent =
      `Available from: ${listing.availability_date}`

    const link = document.createElement("a")
    link.href = `/listings/${encodeURIComponent(listing.id)}`
    link.className = "btn btn-outline-primary mt-auto"
    link.textContent = "View room"

    body.append(
      title,
      propertyType,
      price,
      features,
      availability,
      link
    )

    card.appendChild(body)
    column.appendChild(card)
    this.resultsTarget.appendChild(column)
  }
}
