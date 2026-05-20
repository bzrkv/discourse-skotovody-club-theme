// Connector object for the "КЛУБ" logo badge (markup in the paired .hbs).
//
// Lives on `before-header-panel` — a normal append outlet — NOT on
// `home-logo-wrapper`, which is a wrapper outlet and warns ("Multiple
// connectors registered ... Using the first") when anything else also targets
// it. The numeric prefix sorts this connector before sktvd-club-auth-buttons
// so the badge renders right after the logo.

export default {
  shouldRender() {
    return true;
  },
};
