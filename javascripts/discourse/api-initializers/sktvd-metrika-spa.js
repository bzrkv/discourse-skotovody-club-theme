// Yandex.Metrika SPA page-view tracking.
//
// The counter snippet in common/head_tag.html fires a single `ym('init')`
// on full page load. Discourse is a single-page app — client-side route
// changes never reload the page, so without an explicit `hit` Metrika only
// ever counts the first page of each session.
//
// `api.onPageChange` also fires for that very first route, which `init`
// already counted — so the first invocation is skipped to avoid a double
// hit on the entry page.

import { apiInitializer } from "discourse/lib/api";

const COUNTER_ID = 109366833;

export default apiInitializer((api) => {
  let firstSkipped = false;

  api.onPageChange((url) => {
    if (!firstSkipped) {
      firstSkipped = true;
      return;
    }
    if (typeof window.ym === "function") {
      window.ym(COUNTER_ID, "hit", url, { referer: document.referrer });
    }
  });
});
