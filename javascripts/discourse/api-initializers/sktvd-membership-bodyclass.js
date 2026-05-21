// Tags <body> with `sktvd-membership-route` while the /membership page is
// open, so the theme CSS can turn it into a standalone full-width marketing
// page — no Discourse sidebar, no guest-landing / admin-banner connectors,
// no #main-outlet max-width. The /membership route itself is served by the
// sktvd-club-bridge plugin; this is the theme-side chrome adjustment.

import { apiInitializer } from "discourse/lib/api";

const ROUTE_CLASS = "sktvd-membership-route";

export default apiInitializer((api) => {
  api.onPageChange((url) => {
    const path = (url || "").split("?")[0].replace(/\/+$/, "");
    document.body.classList.toggle(ROUTE_CLASS, path === "/membership");
  });
});
