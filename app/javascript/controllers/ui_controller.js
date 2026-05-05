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

  disconnect() {
    this.menuButtonHandler && document.getElementById('menuBtn')?.removeEventListener('click', this.menuButtonHandler)
    this.sidebarCloseHandler && document.getElementById('sidebarCloseBtn')?.removeEventListener('click', this.sidebarCloseHandler)
    this.themeToggleHandler && this.themeToggle?.removeEventListener('click', this.themeToggleHandler)
    this.profileButtonHandler && document.getElementById('profileBtn')?.removeEventListener('click', this.profileButtonHandler)
    this.documentClickHandler && document.removeEventListener('click', this.documentClickHandler)
    this.overlayClickHandler && this.overlay?.removeEventListener('click', this.overlayClickHandler)
    this.resizeHandler && window.removeEventListener('resize', this.resizeHandler)
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
    this.menuButtonHandler = () => this.toggleSidebar()
    document.getElementById('menuBtn')?.addEventListener('click', this.menuButtonHandler)

    this.sidebarCloseHandler = () => this.closeSidebar()
    document.getElementById('sidebarCloseBtn')?.addEventListener('click', this.sidebarCloseHandler)

    this.themeToggleHandler = () => this.toggleTheme()
    this.themeToggle?.addEventListener('click', this.themeToggleHandler)

    this.profileButtonHandler = (e) => {
      e.stopPropagation()
      this.profileMenu?.classList.toggle('hidden')
    }
    document.getElementById('profileBtn')?.addEventListener('click', this.profileButtonHandler)

    this.documentClickHandler = () => {
      this.profileMenu?.classList.add('hidden')
    }
    document.addEventListener('click', this.documentClickHandler)

    this.overlayClickHandler = () => this.closeSidebar()
    this.overlay?.addEventListener('click', this.overlayClickHandler)

    this.resizeHandler = () => this.handleResize()
    window.addEventListener('resize', this.resizeHandler)
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
      this.content.classList.add('ml-55')
    }

    this.isOpen = true
  }

  closeSidebar(force = false) {
    this.sidebar.classList.add('-translate-x-full')
    this.overlay.classList.add('hidden')

    if (window.innerWidth < this.desktopBreakpoint || force) {
      this.content.classList.remove('ml-55')
    } else {
      this.content.classList.add('ml-55')
    }

    this.isOpen = false
  }

  handleResize() {
    if (!this.sidebar || !this.overlay || !this.content) return

    if (window.innerWidth >= this.desktopBreakpoint) {
      this.overlay.classList.add('hidden')
      this.content.classList.add('ml-55')
    } else if (!this.isOpen) {
      this.content.classList.remove('ml-55')
    }
  }

  setupTheme() {
    const savedTheme = localStorage.getItem('theme')
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    const isDark = savedTheme ? savedTheme === 'dark' : prefersDark

    this.applyTheme(isDark)
  }

  toggleTheme() {
    const isDark = !document.documentElement.classList.contains('dark')
    localStorage.setItem('theme', isDark ? 'dark' : 'light')
    this.applyTheme(isDark)
  }

  applyTheme(isDark) {
    document.documentElement.classList.toggle('dark', isDark)
    document.documentElement.style.colorScheme = isDark ? 'dark' : 'light'
    this.updateThemeToggle(isDark)
  }

  updateThemeToggle(isDark) {
    this.themeToggle?.classList.toggle('is-active', isDark)
    this.themeToggle?.setAttribute('aria-pressed', isDark.toString())
  }
}
