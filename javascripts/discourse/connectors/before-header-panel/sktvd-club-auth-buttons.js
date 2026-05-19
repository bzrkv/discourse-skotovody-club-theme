// Connector for `before-header-panel` plugin outlet. Renders two buttons
// (Регистрация + Вход) in the Discourse header for non-logged-in users,
// linking to skotovody.com modal with appropriate auth=register|login param.
//
// Hides the default Discourse login/signup buttons via CSS (see common.scss).

export default {
  setupComponent(args, component) {
    // Capture current page URL so user returns to it after login on skotovody.com
    component.set(
      "returnUrl",
      encodeURIComponent(window.location.href)
    );
  },

  shouldRender(args, component) {
    return !component.currentUser;
  },
};
