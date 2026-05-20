// Connector for the `extra-nav-item` plugin outlet — adds a "Теги" tab to the
// discovery navigation pills. The mockup nav has a Tags item, but "tags" is
// not a valid `top_menu` site-setting value, so it is added here as a custom
// nav item linking to /tags. CSS (nav-item_bookmarks { order: 1 }) keeps it
// just before "Закладки", matching the mockup order.

import Component from "@glimmer/component";
import { service } from "@ember/service";

export default class SktvdTagsNavItem extends Component {
  @service router;

  get active() {
    return (this.router.currentURL || "").startsWith("/tag");
  }

  <template>
    <li class="nav-item_tags sktvd-nav-tags">
      <a href="/tags" class={{if this.active "active"}}>Теги</a>
    </li>
  </template>
}
