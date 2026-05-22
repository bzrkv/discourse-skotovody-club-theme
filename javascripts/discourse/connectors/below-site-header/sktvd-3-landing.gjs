// Connector for `below-site-header` — renders the full guest landing on
// the site root for anonymous visitors. Replaces the Этап-1 single-hero
// connector (was .js + .hbs). The landing must show ONLY on the root path
// `/`, not on /latest etc. — hence the currentURL check, not just a route
// name (both map to discovery.latest).

import Component from "@glimmer/component";
import { service } from "@ember/service";
import ClubLanding from "../../components/club-landing";

export default class SktvdLanding extends Component {
  @service currentUser;
  @service router;

  get show() {
    const path = (this.router.currentURL || "")
      .split("?")[0]
      .replace(/\/+$/, "");
    return !this.currentUser && path === "";
  }

  <template>
    {{#if this.show}}
      <ClubLanding />
    {{/if}}
  </template>
}
