// Toggles per-route <body> classes the theme CSS keys off:
//   sktvd-membership-route — the /membership plugin page
//   sktvd-landing-route    — the guest landing (root path only, anonymous)
// Renamed from sktvd-membership-bodyclass.js — now handles both routes.

import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();

  api.onPageChange((url) => {
    const path = (url || "").split("?")[0].replace(/\/+$/, "");
    document.body.classList.toggle(
      "sktvd-membership-route",
      path === "/membership"
    );
    document.body.classList.toggle(
      "sktvd-landing-route",
      path === "" && !currentUser
    );
  });
});
