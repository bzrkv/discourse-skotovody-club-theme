// Sets the in-header search field placeholder to the spec copy
// (HOMEPAGE_SPEC §3.B1) without overriding the global js.search.title string
// (which is reused for button tooltips and the full-page search title).

import { apiInitializer } from "discourse/lib/api";

const PLACEHOLDER = "Поиск по темам, тегам, людям...";

export default apiInitializer((api) => {
  const apply = () => {
    document
      .querySelectorAll(".floating-search-input input, .search-banner input")
      .forEach((input) => input.setAttribute("placeholder", PLACEHOLDER));
  };

  api.onPageChange(apply);
  apply();
});
