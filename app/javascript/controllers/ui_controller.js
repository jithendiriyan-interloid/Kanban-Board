import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.sidebar = document.getElementById('sidebar')
    this.overlay = document.getElementById('overlay')
    this.content = document.getElementById('content')
    this.profileMenu = document.getElementById('profileMenu')

    this.isOpen = false

    this.setupTheme()
    this.setupEvents()
  }

  setupEvents() {
    document.getElementById('menuBtn')?.addEventListener('click', () => {
      this.toggleSidebar()
    })

    document.getElementById('themeToggle')?.addEventListener('click', () => {
      this.toggleTheme()
    })

    document.getElementById('profileBtn')?.addEventListener('click', (e) => {
      e.stopPropagation()
      this.profileMenu?.classList.toggle('hidden')
    })

    document.addEventListener('click', () => {
      this.profileMenu?.classList.add('hidden')
    })

    this.overlay?.addEventListener('click', () => this.closeSidebar())
  }

  toggleSidebar() {
    if (!this.sidebar || !this.overlay || !this.content) return

    this.isOpen ? this.closeSidebar() : this.openSidebar()
  }

  openSidebar() {
    this.sidebar.classList.remove('-translate-x-full')

    if (window.innerWidth < 768) {
      this.overlay.classList.remove('hidden')
    } else {
      this.content.classList.add('ml-64')
    }

    this.isOpen = true
  }

  closeSidebar() {
    this.sidebar.classList.add('-translate-x-full')
    this.overlay.classList.add('hidden')
    this.content.classList.remove('ml-64')
    this.isOpen = false
  }

  toggleTheme() {
    document.documentElement.classList.toggle('dark')

    const isDark = document.documentElement.classList.contains('dark')
    localStorage.setItem('theme', isDark ? 'dark' : 'light')
  }

  setupTheme() {
    if (localStorage.getItem('theme') === 'dark') {
      document.documentElement.classList.add('dark')
    }
  }
}
