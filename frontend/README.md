# ERP-NEW · Frontend
### Nuxt 4 · Vue · TypeScript · Nuxt UI

The **ERP-NEW frontend** is a work-in-progress web interface for a modular business ERP system. It currently contains the initial login flow, shared layout and dashboard prototype.

> **Development status:** Screens are under construction. Login is a **mock flow** and dashboard figures are **sample data**. This repository is not a deployed or authenticated production ERP frontend.

[![Nuxt](https://img.shields.io/badge/Nuxt-4-00DC82?style=flat-square)](https://nuxt.com/)
[![TypeScript](https://img.shields.io/badge/Language-TypeScript-3178C6?style=flat-square)](https://www.typescriptlang.org/)
[![UI](https://img.shields.io/badge/UI-Nuxt%20UI-00DC82?style=flat-square)](https://ui.nuxt.com/)

## Current screens and structure

| Area | Description | Status |
| --- | --- | --- |
| `/login` | Login form and navigation to dashboard | Mock sign-in only |
| `/dashboard` | ERP summary cards, purchasing overview, PO status and recent activity panels | Prototype / example values |
| Shared layout | Sidebar, header and page container | UI foundation |
| Authorization | Permission-filtered navigation and API access control | Planned; not wired to live authentication |

Relevant files:

```text
app/
  app.vue
  pages/
    index.vue                  # Existing Nuxt starter landing page
    login.vue                  # Mock login
    dashboard/index.vue        # ERP dashboard prototype
  layouts/default.vue
  components/
    dashboard/                # Dashboard widgets
    layout/                   # Shared navigation and header
```

**Important:** `app/pages/index.vue` still contains the upstream Nuxt UI starter landing page; it is not a custom ERP homepage yet.

## Tech stack

- Nuxt 4 / Vue
- TypeScript
- Nuxt UI and Tailwind CSS
- `@nuxtjs/i18n`
- pnpm

## Local development

```bash
cd frontend
pnpm install
pnpm dev
```

Open the localhost address shown by Nuxt. The interface currently uses mock data and does not require a running ERP database for UI preview.

Useful checks:

```bash
pnpm lint
pnpm typecheck
pnpm build
```

These commands describe how to run checks; **no passing CI or deployment result is claimed** in this README.

## Design documentation

- [Dashboard UI specification](../docs/ERP-NEW_DASHBOARD_UI_SPEC.md)
- [Frontend structure and intended authorization flow](../docs/ERP-NEW_FRONTEND_STRUCTURE.md)
- [User, role, permission and multi-company model](../docs/USER_MODULE_1.0.md)
- [Purchasing workflow](../docs/Purchasing_Status_Workflow.md)

## Next steps

- Replace the starter landing page with an ERP-specific entry experience.
- Connect login/session handling to the backend.
- Connect dashboard widgets to real, authorized API endpoints.
- Apply permission-based menu visibility **and** independent server-side authorization.
- Add integration tests, accessibility checks and error handling.

## Credits

The initial frontend was bootstrapped from the [Nuxt UI starter template](https://github.com/nuxt-ui-templates/starter). Nuxt UI is developed by the Nuxt team. The upstream project is used as a starting point; ERP-specific screens and specifications are part of this personal project.

---

[← Back to ERP-NEW overview](../README.md)
