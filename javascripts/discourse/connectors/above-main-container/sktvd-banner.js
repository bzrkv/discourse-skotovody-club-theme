// Connector for the `above-main-container` plugin outlet. Renders a global,
// dismissable announcement banner (.sktvd-banner).
//
// Visibility is gated by the `enable_admin_banner` theme setting; the text and
// CTA come from settings too. Dismissal is persisted in localStorage so the
// banner stays hidden for that browser until the admin changes the text.

const STORAGE_KEY = "sktvd_banner_dismissed";

export default {
  shouldRender() {
    if (!settings.enable_admin_banner) {
      return false;
    }
    try {
      return localStorage.getItem(STORAGE_KEY) !== "1";
    } catch (e) {
      // localStorage blocked (private mode) — still show the banner
      return true;
    }
  },

  setupComponent(args, component) {
    component.setProperties({
      bannerText: settings.admin_banner_text,
      ctaText: settings.admin_banner_cta_text,
      ctaUrl: settings.admin_banner_cta_url,
      dismissed: false,
    });
  },

  actions: {
    dismiss() {
      try {
        localStorage.setItem(STORAGE_KEY, "1");
      } catch (e) {
        // localStorage unavailable — hide for this page view only
      }
      this.set("dismissed", true);
    },
  },
};
