import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.sidebar = document.getElementById('sidebar')
    this.overlay = document.getElementById('overlay')
    this.content = document.getElementById('content')
    this.profileMenu = document.getElementById('profileMenu')
    this.themeToggle = document.getElementById('themeToggle')

    this.desktopBreakpoint = 768
    this.isOpen = false

    this.setupTheme()
    this.setupLayout()
    this.setupEvents()
  }

  setupLayout() {
    if (!this.sidebar || !this.overlay || !this.content) return

    if (window.innerWidth >= this.desktopBreakpoint) {
      this.openSidebar()
      this.overlay.classList.add('hidden')
    } else {
      this.closeSidebar()
    }
  }

  setupEvents() {
    document.getElementById('menuBtn')?.addEventListener('click', () => {
      this.toggleSidebar()
    })

    document.getElementById('sidebarCloseBtn')?.addEventListener('click', () => {
      this.closeSidebar()
    })

    this.themeToggle?.addEventListener('click', () => {
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
    window.addEventListener('resize', () => this.handleResize())
  }

  toggleSidebar() {
    if (!this.sidebar || !this.overlay || !this.content) return

    this.isOpen ? this.closeSidebar() : this.openSidebar()
  }

  openSidebar() {
    this.sidebar.classList.remove('-translate-x-full')

    if (window.innerWidth < this.desktopBreakpoint) {
      this.overlay.classList.remove('hidden')
    } else {
      this.overlay.classList.add('hidden')
      this.content.classList.add('ml-64')
    }

    this.isOpen = true
  }

closeSidebar(force = false) {
    if (window.innerWidth >= this.desktopBreakpoint && !force) return
    this.sidebar.classList.add('-translate-x-full')
    this.overlay.classList.add('hidden')
    this.content.classList.remove('ml-64')
    this.isOpen = false
  }

  handleResize() {
    if (!this.sidebar || !this.overlay || !this.content) return

    if (window.innerWidth >= this.desktopBreakpoint) {
      this.overlay.classList.add('hidden')

      if (this.isOpen) {
        this.content.classList.add('ml-64')
      }
    } else if (!this.isOpen) {
      this.content.classList.remove('ml-64')
    }
  }

  toggleTheme() {
    document.documentElement.classList.toggle('dark')

    const isDark = document.documentElement.classList.contains('dark')
    localStorage.setItem('theme', isDark ? 'dark' : 'light')
    this.updateThemeToggle(isDark)
  }

  setupTheme() {
    if (localStorage.getItem('theme') === 'dark') {
      document.documentElement.classList.add('dark')
    }

    this.updateThemeToggle(document.documentElement.classList.contains('dark'))
  }

  updateThemeToggle(isDark) {
    this.themeToggle?.classList.toggle('is-active', isDark)
    this.themeToggle?.setAttribute('aria-pressed', isDark.toString())
  }
}
