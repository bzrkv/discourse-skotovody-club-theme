// Connector for the `before-header-panel` plugin outlet. Renders the
// Регистрация + Вход buttons for anonymous visitors.
//
// "Вход" MUST go through Discourse's own /session/sso entrypoint — that is
// what mints the signed DiscourseConnect nonce + return_sso_url. Linking
// straight to the WP login modal skips the handshake: the user logs into
// WordPress but no Discourse session is ever created. A <button> with an
// explicit window.location assignment guarantees a full page load, so Ember
// never tries to client-route this server-only path.

export default {
  shouldRender(args, component) {
    return !component.currentUser;
  },

  setupComponent(args, component) {
    // Registration happens on skotovody.com (WordPress owns accounts). Once
    // the account exists the WP side redirects the browser to the club's SSO
    // entrypoint, so the freshly-registered user lands authenticated inside
    // the club instead of on an anonymous home page.
    component.set(
      "registerUrl",
      "https://skotovody.com/?auth=register&redirect_to=" +
        encodeURIComponent("https://club.skotovody.com/session/sso")
    );
  },

  actions: {
    login() {
      window.location.href =
        "/session/sso?return_path=" +
        encodeURIComponent(window.location.pathname);
    },
  },
};
