// Connector object for the "КЛУБ" logo badge. The visible markup lives in
// templates/connectors/home-logo-wrapper/sktvd-club-logo-badge.hbs — but a
// classic connector under templates/connectors/ still needs this paired .js
// file for Discourse to register it into the home-logo-wrapper outlet.

export default {
  shouldRender() {
    return true;
  },
};
