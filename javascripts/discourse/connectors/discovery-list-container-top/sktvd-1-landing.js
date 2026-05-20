// Connector for the `discovery-list-container-top` plugin outlet. Renders the
// guest landing hero (.sktvd-landing) above the topic list for anonymous
// visitors only — logged-in members never see it.
//
// Gated by the `enable_guest_landing` theme setting. The "подать заявку" CTA
// points at the pricing page on skotovody.com (`pricing_url` setting); the
// "войти" CTA goes through the skotovody.com SSO login, carrying a return URL.

export default {
  shouldRender(args, component) {
    return settings.enable_guest_landing && !component.currentUser;
  },

  setupComponent(args, component) {
    component.setProperties({
      pricingUrl: settings.pricing_url,
      loginUrl:
        "https://skotovody.com/?auth=login&from=club&redirect_to=" +
        encodeURIComponent(window.location.href),
    });
  },
};
