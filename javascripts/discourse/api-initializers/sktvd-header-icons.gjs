// Adds the "bell" (notifications) and "bookmark" header icons next to the
// chat icon and avatar — HOMEPAGE_SPEC §3.B1 (bell · chat · bookmark · avatar).
//
// Modern Discourse keeps notifications and bookmarks inside the avatar
// user-menu; the spec/mockup wants them as standalone header icons, so we
// register them through the headerIcons API. The bell shows the unread
// notification count; both navigate to the matching personal pages.

import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { apiInitializer } from "discourse/lib/api";

class BellIcon extends Component {
  @service currentUser;

  get count() {
    const u = this.currentUser;
    if (!u) {
      return 0;
    }
    return (
      u.all_unread_notifications_count ||
      (u.unread_notifications || 0) +
        (u.unread_high_priority_notifications || 0)
    );
  }

  <template>
    <li class="header-dropdown-toggle sktvd-header-icon">
      <a
        href="/my/notifications"
        class="btn no-text icon btn-flat sktvd-header-icon-link"
        title="Уведомления"
      >
        {{icon "bell"}}
        {{#if this.count}}
          <span class="sktvd-header-icon-badge">{{this.count}}</span>
        {{/if}}
      </a>
    </li>
  </template>
}

const BookmarkIcon = <template>
  <li class="header-dropdown-toggle sktvd-header-icon">
    <a
      href="/my/activity/bookmarks"
      class="btn no-text icon btn-flat sktvd-header-icon-link"
      title="Закладки"
    >
      {{icon "bookmark"}}
    </a>
  </li>
</template>;

export default apiInitializer((api) => {
  if (!api.getCurrentUser()) {
    return;
  }

  api.headerIcons.add("sktvd-bell", BellIcon, { before: "chat" });
  api.headerIcons.add("sktvd-bookmark", BookmarkIcon, {
    after: "chat",
    before: "user-menu",
  });
});
