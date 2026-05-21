// Connector for the `below-site-header` plugin outlet — the guest landing
// hero (.sktvd-landing), block E0 of HOMEPAGE_SPEC.
//
// Lives in `below-site-header` (not `discovery-list-container-top`) so it
// spans the FULL content width — over both the sidebar and the main column,
// as the spec requires ("до dc-shell-sidebar, поверх обеих колонок").
// Order among the below-site-header connectors: sktvd-1-nav → sktvd-2-banner
// → sktvd-3-landing, i.e. view-nav → banner → hero.
//
// Gated by `enable_guest_landing`; logged-in members never see it. The
// "подать заявку" CTA points at the application form on skotovody.com
// (`application_url` setting); the "войти" CTA goes through the
// skotovody.com SSO login, carrying a return URL.

export default {
  shouldRender(args, component) {
    return settings.enable_guest_landing && !component.currentUser;
  },

  setupComponent(args, component) {
    component.setProperties({
      applicationUrl: settings.application_url,
      loginUrl:
        "https://skotovody.com/?auth=login&from=club&redirect_to=" +
        encodeURIComponent(window.location.href),
    });
  },
};
